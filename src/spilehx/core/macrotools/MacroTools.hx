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
		var validatedLocalFolderPath:String = validateProjectPath(path);
		spilehx.core.filesystem.FileFolderUtils.ensureFolder(validatedLocalFolderPath);
	}

	/**
		Ensures that a project-local file exists at compile time.
		When the file is missing, an empty file is created.
	 */
	public static function ensureProjectFile(filePath:String):Void {
		var validatedLocalFilePath:String = validateProjectPath(filePath);
		spilehx.core.filesystem.FileFolderUtils.ensureFile(validatedLocalFilePath);
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
		Returns the normalized source root from `IMPORT_FILE_PATH`, defaulting to `./src`.
	*/
	public static function getSrcRoot():String {
		var SRC_ROOT_ENV_ARG:String = "IMPORT_FILE_PATH";
		var SRC_ROOT_DEFAULT:String = "./src";
		var srcRoot:String = spilehx.core.macrotools.MacroTools.getEnvVar(SRC_ROOT_ENV_ARG, SRC_ROOT_DEFAULT);

		if (srcRoot == "") {
			srcRoot = SRC_ROOT_DEFAULT;
		}

		return spilehx.core.macrotools.MacroTools.validateProjectPath(srcRoot);
	}

	/**
		Returns files under a project-local folder with their byte sizes.
	 */
	public static function getFilesRecursively(path:String):Array<{path:String, size:Int}> {
		return spilehx.core.filesystem.FileFolderUtils.getFilesRecursively(validateProjectPath(path));
	}

	/**
		Copies files recursively between two project-local folders.
	 */
	public static function copyAssets(source:String, destination:String):Void {
		source = validateProjectPath(source);
		destination = validateProjectPath(destination);
		spilehx.core.filesystem.FileFolderUtils.copyAssets(source, destination);
	}
	#end

	/**
		Helpers for compile-time file reading. Returns the file content as a string literal.
	 */
	public static macro function fileAsString(path:String):ExprOf<String> {
		var content:String = "";

		if (sys.FileSystem.exists(path) == true) {
			content = sys.io.File.getContent(path);
		}

		return macro $v{content};
	}
}
