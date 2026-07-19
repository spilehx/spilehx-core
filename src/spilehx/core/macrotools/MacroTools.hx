package spilehx.core.macrotools;

import sys.FileStat;
import sys.io.File;
import haxe.macro.Context;
import sys.FileSystem;
import haxe.io.Path;

/**
	Compile-time helpers used by Spilehx build macros.

	All public APIs in this type are available only in macro context. They may
	read or modify files relative to the compiler's current working directory and
	may abort compilation by reporting errors through `haxe.macro.Context`.
 */
class MacroTools {
	#if macro
	/**
		Returns a compile-time define value.

		The value is read with `Context.definedValue`, so `varName` refers to a
		Haxe compiler define such as one supplied with `-D` in an `.hxml` file,
		not an operating-system environment variable. Compilation is aborted if
		the define is not present.

		@param varName The name of the compiler define to read.
		@return The define value reported by the macro context.
		@throws haxe.macro.Error If the define is not set.
	 */
	public static function getEnvVar(varName:String, ?fallbackValue:String = null):Dynamic {
		var envVar = Context.definedValue(varName);
		if (envVar == null) {
			if (fallbackValue != null) {
				return fallbackValue;
			} else {
				Context.error("Environment variable " + varName + " not set in .hxml file", Context.currentPos());
			}
		}
		return envVar;
	}

	/**
		Ensures that a project-local folder exists at compile time.

		Relative paths are resolved against the compiler's current working
		directory. Absolute paths are accepted only when they resolve inside that
		directory. The path is normalized with `validateProjectPath` before use.
		The function writes progress messages to standard output. If the path
		already exists, no check is made that it is a directory.

		@param path The relative or absolute folder path to validate and create.
		@throws haxe.macro.Error If the path is outside the project directory or
			the directory cannot be created.
	 */
	public static function ensureProjectFolder(path:String):Void {
		Sys.println("Ensuring project folder: " + path);
		var validatedLocalFolderPath:String = validateProjectPath(path);

		if (!FileSystem.exists(validatedLocalFolderPath)) {
			try {
				FileSystem.createDirectory(validatedLocalFolderPath);
			} catch (e:Dynamic) {
				Context.error("Failed to create directory '" + validatedLocalFolderPath + "': " + Std.string(e), Context.currentPos());
			}
		} else {
			// Sys.println("Project folder already exists: " + validatedLocalFolderPath);
		}
	}

	/**
		Ensures that a project-local file exists at compile time.

		Relative paths are resolved against the compiler's current working
		directory. Absolute paths are accepted only when they resolve inside that
		directory. The path is normalized with `validateProjectPath` before use.
		When the file is missing, an empty file is written. The function writes
		progress messages to standard output. If the path already exists, no check
		is made that it is a regular file.

		@param filePath The relative or absolute file path to validate and create.
		@throws haxe.macro.Error If the path is outside the project directory or
			the file cannot be created.
	 */
	public static function ensureProjectFile(filePath:String):Void {
		Sys.println("Ensuring project file: " + filePath);
		var validatedLocalFilePath:String = validateProjectPath(filePath);

		if (!FileSystem.exists(validatedLocalFilePath)) {
			try {
				File.saveContent(validatedLocalFilePath, "");
			} catch (e:Dynamic) {
				Context.error("Failed to create file '" + validatedLocalFilePath + "': " + Std.string(e), Context.currentPos());
			}
		} else {
			Sys.println("Project file already exists: " + validatedLocalFilePath);
		}
	}

	/**
		Validates that a path resolves inside the current project directory.

		The project directory is the compiler's current working directory after
		`Path.normalize` and trailing slash removal. Relative paths are resolved
		against that directory. Absolute paths are normalized directly. The
		returned path is project-relative and starts with `./`, except for the
		project root itself, which returns `"."`.

		```haxe
		var path = MacroTools.validateProjectPath("generated/output.txt");
		// "./generated/output.txt"
		```

		@param path The relative or absolute path to validate.
		@return A normalized path relative to the project directory.
		@throws haxe.macro.Error If the normalized path resolves outside the
			project directory.
	 */
	public static function validateProjectPath(path:String):String {
		var root = Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()));
		var resolved = Path.normalize(Path.isAbsolute(path) ? path : Path.join([root, path]));

		if (resolved != root && !StringTools.startsWith(resolved, root + "/")) {
			Context.error("Invalid project path: " + path, Context.currentPos());
		}

		var relative = resolved.substr(root.length);

		return relative == "" ? "." : "." + relative;
	}

	public static function getFilesRecursively(path:String):Array<{path:String, size:Int}> {
		path = validateProjectPath(path);

		var files:Array<{path:String, size:Int}> = [];

		// Check if the specified path exists and is a directory
		if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
			for (item in FileSystem.readDirectory(path)) {
				var fullPath = path + "/" + item;

				if (FileSystem.isDirectory(fullPath)) {
					// Recursively add files from subdirectories
					files = files.concat(getFilesRecursively(fullPath));
				} else {
					// if (item != Manifest.MANIFEST_FILE_NAME) {
					// Get file size using FileSystem.stat
					var fileStat:FileStat = FileSystem.stat(fullPath);

					// get local file path
					// var localPath = fullPath.replace(getEnvVar(ENV_KEY_outputFolderPath), ".");
					files.push({path: fullPath, size: fileStat.size});
					// }
				}
			}
		} else {
			Context.warning("Directory does not exist: " + path, Context.currentPos());
		}

		return files;
	}

	public static function copyAssets(source:String, destination:String):Void {
		source = validateProjectPath(source);
		destination = validateProjectPath(destination);

		ensureProjectFolder(destination);
		// Check if the source exists and is a directory
		if (FileSystem.exists(source) && FileSystem.isDirectory(source)) {
			for (item in FileSystem.readDirectory(source)) {
				var srcPath = source + "/" + item;
				var destPath = destination + "/" + item;

				if (FileSystem.isDirectory(srcPath)) {
					// Recursively copy subdirectories
					copyAssets(srcPath, destPath);
				} else {
					// Copy files by reading and writing their contents
					try {
						var content = File.getContent(srcPath); // Read file content
						File.saveContent(destPath, content); // Write content to the destination
					} catch (e:Dynamic) {
						Context.error("Failed to copy file '" + srcPath + "' to '" + destPath + "': " + Std.string(e), Context.currentPos());
					}
				}
			}
		} else {
			Context.warning("Source directory does not exist: " + source, Context.currentPos());
		}
	}

	#end
}
