# Task: Use spilehx-core

Use this task when the user asks how to use, configure, import, or troubleshoot `spilehx-core` in a Haxe project.

## Steps

1. Read `README.md` first.
2. Read the relevant source in `src/` before giving API-specific advice.
3. Give a short answer with the exact imports, `.hxml` lines, or Haxe snippet needed.
4. Mention target limits when relevant, especially macro-only helpers and non-JavaScript file logging.
5. Avoid undocumented behavior and long tutorials.

## Common References

- Logging helpers: `spilehx.core.logging.GlobalLogger`
- Logging settings: `spilehx.core.logging.GlobalLoggingSettings.settings`
- Optional import setup: `--macro spilehx.core.logging.GlobalLogger.ensureImport()`
- Compile-time file helpers: `spilehx.core.macrotools.MacroTools`
- Archive helpers: `spilehx.core.projectmanagement.Archive`
- Folder fingerprints: `spilehx.core.projectmanagement.FolderFingerprint`
