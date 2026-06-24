import os
os.environ["TOKENIZERS_PARALLELISM"] = "false"

import asyncio
import contextlib
import threading
import time

from fastapi import FastAPI, Body
from pydantic import BaseModel
from transformers import AutoModel
import torch
import uvicorn


MODEL_PATH = os.environ["JINA_MODEL_PATH"]
IDLE_TIMEOUT = int(os.environ.get("IDLE_TIMEOUT", 300))
SERVICE_PORT = int(os.environ.get("SERVER_PORT", 8000))
SERVICE_HOST = os.environ.get("SERVER_HOST", "127.0.0.1")

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

model = None
model_lock = threading.Lock()
last_access = 0.0


class RerankRequest(BaseModel):
    model: str = "jina-reranker-v3"
    query: str
    documents: list[str]
    top_n: int | None = None
    return_documents: bool = False


class RerankResult(BaseModel):
    index: int
    relevance_score: float
    document: str | None = None


class RerankResponse(BaseModel):
    model: str
    usage: dict
    results: list[RerankResult]


def _init_model():
    global model
    m = AutoModel.from_pretrained(
        MODEL_PATH,
        trust_remote_code=True,
        local_files_only=True,
        torch_dtype="auto",
    )
    m.eval()
    m.to(DEVICE)
    model = m


def _ensure_model():
    global last_access
    last_access = time.time()
    with model_lock:
        if model is None:
            _init_model()
        elif model.device.type != DEVICE:
            model.to(DEVICE)
    return model


async def _idle_loop():
    while True:
        await asyncio.sleep(60)
        with model_lock:
            if (
                model is not None
                and model.device.type == DEVICE
                and time.time() - last_access > IDLE_TIMEOUT
            ):
                model.to("cpu")
                if DEVICE == "cuda":
                    torch.cuda.empty_cache()


@contextlib.asynccontextmanager
async def lifespan(app: FastAPI):
    task = asyncio.create_task(_idle_loop())
    yield
    task.cancel()


app = FastAPI(lifespan=lifespan)


def _token_count(query, documents):
    total = len(query) + sum(len(d) for d in documents)
    return max(1, total * len(documents) // 4)

@app.post("/v1/rerank", response_model=RerankResponse)
def rerank(body: RerankRequest = Body(...)):
    m = _ensure_model()
    with model_lock:
        raw = m.rerank(body.query, body.documents, return_embeddings=False)

    ranked = sorted(raw, key=lambda r: r["relevance_score"], reverse=True)
    if body.top_n is not None:
        ranked = ranked[: body.top_n]

    results = []
    for r in ranked:
        item = RerankResult(
            index=r["index"],
            relevance_score=float(r["relevance_score"]),
        )
        if body.return_documents:
            item.document = body.documents[r["index"]]
        results.append(item)

    return RerankResponse(
        model=body.model,
        usage={"total_tokens": _token_count(body.query, body.documents)},
        results=results,
    )


@app.get("/health")
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    uvicorn.run(app, host=SERVICE_HOST, port=SERVICE_PORT)
