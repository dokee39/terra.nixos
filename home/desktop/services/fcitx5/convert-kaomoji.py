import json
import sys
from pathlib import Path

from pypinyin import lazy_pinyin

records = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
seen = set()

for record in records:
    text = record["text"]
    value = json.dumps(text, ensure_ascii=False)
    for language in ("zh", "en"):
        for label in record["keywords"].get(language, []):
            key = "".join(lazy_pinyin(label)) if language == "zh" else label
            key = "".join(key.split())
            entry = (key, text)
            if entry not in seen:
                seen.add(entry)
                print(f"{key} {value}")
