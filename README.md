# spilehx-core

Core utilities shared by the Spilehx framework.

## About

`spilehx-core` contains small framework-level helpers that are useful across Spilehx projects. The current public API focuses on global logging, compile-time project file helpers, archive utilities, and folder fingerprinting.

The library is intentionally lightweight and has no haxelib dependencies.

## Inbuilt Features

### Logging

The logging API is exposed through `GlobalLogger`. Projects can call the uppercase helpers directly when the generated `import.hx` imports are enabled.

```haxe
GlobalLoggingSettings.settings.verbose = true;
GlobalLoggingSettings.settings.toFile = true;

LOG("message");
LOG_INFO("info message");
LOG_WARN("warning message");
LOG_ERROR("error message");

LOG_OBJECT(obj);
```

`LOG`, `LOG_INFO`, `LOG_WARN`, and `LOG_OBJECT` only write normal output when verbose logging is enabled. `LOG_ERROR` always writes an error message.

Use the user-message helpers for messages intended for people running the program:

```haxe
USER_MESSAGE("user message");
USER_MESSAGE_INFO("user info message");
USER_MESSAGE_WARN("user warning message");
USER_MESSAGE_ERROR("user error message");
```

These helpers print by default. Pass `false` as the second argument to suppress the message unless verbose logging is enabled:

```haxe
USER_MESSAGE("only shown in verbose mode", false);
```

### Logging Settings

Configure logging through the shared settings instance:

```haxe
GlobalLoggingSettings.settings.verbose = true;
GlobalLoggingSettings.settings.toFile = true;
GlobalLoggingSettings.settings.logFileSubFolder = "./logs";
GlobalLoggingSettings.settings.logFileName = "logs.log";
GlobalLoggingSettings.settings.logFileLinePrefix = "app";
GlobalLoggingSettings.settings.maxLogFileLength = 100;
GlobalLoggingSettings.settings.stdErrOut = true;
```

On non-JavaScript targets, file logging writes to:

```text
<logFileSubFolder>/<logFileName>
```

### Import Setup

The library includes a compile-time setup macro that adds the logging imports to `src/import.hx` by default:

```hxml
--macro spilehx.core.logging.GlobalLogger.ensureImport()
```

This adds:

```haxe
import spilehx.core.logging.GlobalLogger;
import spilehx.core.logging.GlobalLogger.*;
```

Projects can keep this macro in an `.hxml` file, or include the provided `extraParams.hxml` if their build flow supports it.

Set `IMPORT_FILE_PATH` to use a different source folder:

```hxml
-D IMPORT_FILE_PATH=./foo/bar
--macro spilehx.core.logging.GlobalLogger.ensureImport()
```

This writes `./foo/bar/import.hx`.

### Project Utilities

`spilehx.core.macrotools.MacroTools` provides compile-time helpers for project-local files and folders. Paths are validated against the compiler working directory before files are created or copied.

`spilehx.core.projectmanagement.Archive` creates and extracts `.tar.xz` archives using the system `tar` command.

`spilehx.core.projectmanagement.FolderFingerprint` creates a short fingerprint for a folder based on contained paths, file sizes, and modification times.
