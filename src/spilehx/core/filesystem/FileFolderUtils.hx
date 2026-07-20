package spilehx.core.filesystem;

import sys.FileSystem;
import sys.io.File;
import sys.FileStat;
import haxe.io.Path;

// import haxe.macro.Context;
// import spilehx.core.logging.Log;
class FileFolderUtils {
	public static function isFolderEmpty(path:String):Bool {
		return FileSystem.exists(path) && FileSystem.isDirectory(path) && FileSystem.readDirectory(path).length == 0;
	}

	public static function ensureFolder(path:String):Void {
		if (path == "" || path == "." || FileSystem.exists(path)) {
			return;
		}

		var parent = Path.directory(Path.normalize(path));
		if (parent != null && parent != "" && parent != path && !FileSystem.exists(parent)) {
			ensureFolder(parent);
		}

		if (!FileSystem.exists(path)) {
			try {
				FileSystem.createDirectory(path);
			} catch (e:Dynamic) {
				USER_MESSAGE_ERROR("Failed to create directory '" + path + "': " + Std.string(e));
			}
		} else {
			// Log.compileTimeLogInfo("Folder already exists: " + path);
		}
	}

	public static function ensureFile(filePath:String):Void {
		// Log.compileTimeLog("Ensuring project file: " + filePath);

		if (!FileSystem.exists(filePath)) {
			try {
				var folderPath = Path.directory(Path.normalize(filePath));
				if (folderPath != null && folderPath != "" && folderPath != filePath) {
					ensureFolder(folderPath);
				}

				File.saveContent(filePath, "");
			} catch (e:Dynamic) {
				USER_MESSAGE_ERROR("Failed to create file '" + filePath + "': " + Std.string(e));
			}
		} else {
			// Log.compileTimeLogInfo("Project file already exists: " + filePath);
		}
	}

	public static function getFilesRecursively(path:String):Array<{path:String, size:Int}> {
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
			USER_MESSAGE_ERROR("Directory does not exist: " + path);
		}

		return files;
	}

	public static function copyAssets(source:String, destination:String):Void {
		ensureFolder(destination);
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
						USER_MESSAGE_ERROR("Failed to copy file '" + srcPath + "' to '" + destPath + "': " + Std.string(e));
					}
				}
			}
		} else {
			USER_MESSAGE_ERROR("Source directory does not exist: " + source);
		}
	}
}
