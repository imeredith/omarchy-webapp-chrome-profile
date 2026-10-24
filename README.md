# Web app Chrome profile

When you install a web app with `omarchy-webapp-install` (or the Omarchy menu),
this plugin asks which Chrome profile the app should use and pins its launcher
to that profile. After that the app always opens signed in as that profile,
whatever profile you last used in the browser.

It works with whichever Chromium-based browser `omarchy-launch-webapp` opens
web apps in: the default browser if it's Chrome, Brave, Edge or Vivaldi, and
Chromium otherwise. Dismissing the picker leaves the launcher as it was, on the
browser's last-used profile. With only one profile there's nothing to ask, so
launchers are left alone.

A launcher only changes after you choose a profile for it. The plugin never
touches other `.desktop` files or any other configuration.

## Requirements

- Omarchy with `omarchy-shell`
- A Chromium-based browser with more than one profile
- `inotify-tools` and `jq`, which Omarchy installs by default

## How it works

`Service.qml` runs `inotifywait` on `~/.local/share/applications`. Each new
`.desktop` file goes to `pin-profile`, which skips anything that isn't a plain
`Exec=omarchy-launch-webapp ...` launcher or already has
`--profile-directory`. Otherwise it reads the profiles from the browser's
`Local State`, shows a picker and adds `--profile-directory=<dir>` to the
launcher's `Exec` line. When several web apps arrive at once, for example from
`omarchy-refresh-applications`, it shows one picker at a time.

To change a pinned app's profile, remove `--profile-directory=...` from its
launcher in `~/.local/share/applications/` and save it. The picker then asks
again.

## Install

```bash
omarchy plugin add https://github.com/imeredith/omarchy-webapp-chrome-profile.git --enable
```

To work on the plugin from a local checkout, symlink it in instead:

```bash
ln -s ~/personal/omarchy-webapp-chrome-profile ~/.config/omarchy/plugins/imeredith.webapp-chrome-profile
omarchy-shell shell rescanPlugins
omarchy plugin enable imeredith.webapp-chrome-profile
```

## Remove

```bash
omarchy plugin remove imeredith.webapp-chrome-profile
```

Launchers that already pin a profile keep it. To unpin one, delete
`--profile-directory=...` from its `Exec` line in
`~/.local/share/applications/`.

## License

MIT. See [LICENSE](LICENSE).
