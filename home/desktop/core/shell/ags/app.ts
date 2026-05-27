import app from "ags/gtk4/app"
import { Astal } from "ags/gtk4"
import { For, createBinding } from "ags"
import Hyprland from "gi://AstalHyprland"

function Workspaces() {
  const hypr = Hyprland.get_default()
  const workspaces = createBinding(hypr, "workspaces")

  return (
    <box spacing={6}>
      <For each={workspaces((list) => [...list].sort((a, b) => a.id - b.id))}>
        {(ws) => (
          <button onClicked={() => ws.focus()}>
            <label label={String(ws.id)} />
          </button>
        )}
      </For>
    </box>
  )
}

app.start({
  main() {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return (
      <window visible anchor={TOP | LEFT | RIGHT}>
        <box spacing={6}>
          <Workspaces />
        </box>
      </window>
    )
  },
})
