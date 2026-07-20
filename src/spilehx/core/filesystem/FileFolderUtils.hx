package spilehx.core.filesystem;

import sys.FileSystem;
import sys.io.File;
// import haxe.macro.Context;
// import spilehx.core.logging.Log;

class FileFolderUtils {
    public static function isFolderEmpty(path:String):Bool {
        return FileSystem.exists(path)
            && FileSystem.isDirectory(path)
            && FileSystem.readDirectory(path).length == 0;
    }



	public static function ensureFolder(path:String):Void {
		LOG("Ensuring folder: " + path);

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
				LOG("Ensuring project file: " + filePath);
				File.saveContent(filePath, "");
			} catch (e:Dynamic) {
                USER_MESSAGE_ERROR("Failed to create file '" + filePath + "': " + Std.string(e));
			}
		} else {
			// Log.compileTimeLogInfo("Project file already exists: " + filePath);
		}
	}





}