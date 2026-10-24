import QtQuick
import Quickshell
import Quickshell.Io

// Watches ~/.local/share/applications for launchers written by
// omarchy-webapp-install and hands each one to pin-profile, which asks for a
// Chrome profile and rewrites the launcher's Exec line to use it.
Item {
  id: root

  readonly property string applicationsDir: Quickshell.env("HOME") + "/.local/share/applications"
  readonly property string pinScript: decodeURIComponent(String(Qt.resolvedUrl("pin-profile")).replace(/^file:\/\//, ""))

  function pin(fileName) {
    if (!fileName.endsWith(".desktop")) return
    // Detached, so the profile prompt outlives a plugin reload.
    Quickshell.execDetached(["bash", root.pinScript, root.applicationsDir + "/" + fileName])
  }

  Process {
    id: watcher
    running: true
    command: ["bash", "-c",
      "mkdir -p \"$1\" && exec inotifywait -m -q -e close_write -e moved_to --format %f \"$1\"",
      "_", root.applicationsDir]
    stdout: SplitParser {
      onRead: function(line) { root.pin(String(line)) }
    }
    onExited: restartTimer.start()
  }

  // inotifywait only exits on error (e.g. inotify-tools missing); retry slowly.
  Timer {
    id: restartTimer
    interval: 10000
    onTriggered: watcher.running = true
  }
}
