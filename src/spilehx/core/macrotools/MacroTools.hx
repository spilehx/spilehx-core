package spilehx.core.macrotools;

import sys.FileStat;
import sys.io.File;
import haxe.macro.Context;
import sys.FileSystem;
import haxe.io.Path;

#if macro
import spilehx.core.logging.Log;

#end

/**
	Compile-time file helpers for project-local paths.
 */
class MacroTools {
	#if macro
	/**
		Returns a compiler define value.
		Uses `fallbackValue` when the define is missing, or aborts compilation if no fallback is provided.
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
		Relative and absolute paths must resolve inside the compiler working directory.
	 */
	public static function ensureProjectFolder(path:String):Void {
		Log.compileTimeLogInfo("Ensuring project folder: " + path);
		var validatedLocalFolderPath:String = validateProjectPath(path);

		if (!FileSystem.exists(validatedLocalFolderPath)) {
			try {
				FileSystem.createDirectory(validatedLocalFolderPath);
			} catch (e:Dynamic) {
				Context.error("Failed to create directory '" + validatedLocalFolderPath + "': " + Std.string(e), Context.currentPos());
			}
		} else {
			// Log.compileTimeLogInfo("Project folder already exists: " + validatedLocalFolderPath);
		}
	}

	/**
		Ensures that a project-local file exists at compile time.
		When the file is missing, an empty file is created.
	 */
	public static function ensureProjectFile(filePath:String):Void {
		// Log.compileTimeLog("Ensuring project file: " + filePath);
		var validatedLocalFilePath:String = validateProjectPath(filePath);

		if (!FileSystem.exists(validatedLocalFilePath)) {
			try {
				Log.compileTimeLog("Ensuring project file: " + filePath);
				File.saveContent(validatedLocalFilePath, "");
			} catch (e:Dynamic) {
				Context.error("Failed to create file '" + validatedLocalFilePath + "': " + Std.string(e), Context.currentPos());
			}
		} else {
			// Log.compileTimeLogInfo("Project file already exists: " + validatedLocalFilePath);
		}
	}

	/**
		Returns a normalized project-local path.
		Compilation is aborted if the path resolves outside the compiler working directory.
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

	/**
		Returns files under a project-local folder with their byte sizes.
	 */
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

	/**
		Copies files recursively between two project-local folders.
	 */
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
