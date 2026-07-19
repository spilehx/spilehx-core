package spilehx.core.projectmanagement;

import sys.io.Process;
import sys.io.File;

/**
	Creates and extracts `.tar.xz` archives.
 */
class Archive {
	/**
		Creates an archive from `sourcePath` and calls `onComplete` after successful compression.
		Throws if the system `tar` command fails.
	 */
	public static function createArchive(sourcePath:String, targetPath:String, archiveName:String, onComplete:Void->Void):Void {
		Sys.println("Creating archive: " + archiveName + " from folder: " + sourcePath);

		var command:String = "tar";
		var args:Array<String> = ["-I", "xz -9e -T0", "-cf", targetPath + "/" + archiveName, sourcePath];
		var proc = new Process(command, args, false);

		var stderr = proc.stderr.readAll().toString();
		var exitCode = proc.exitCode();
		proc.close();

		if (exitCode != 0) {
			var detail = StringTools.trim(stderr);
			if (detail == "") {
				detail = "compression failed";
			}
			throw detail;
		}
		onComplete();
	}


	/**
		Extracts an archive into `targetPath` and calls `onComplete` after successful extraction.
		Throws if the system `tar` command fails.
	 */
    public static function extractArchive(sourcePath:String, targetPath:String, onComplete:Void->Void):Void {
		Sys.println("extract archive: " + sourcePath);

		// tar -xJf folder.tar.xz -C /path/to/destination
		var command:String = "tar";
		var args:Array<String> = ["-xJf", sourcePath, "-C", targetPath];
		var proc = new Process(command, args, false);

		var stderr = proc.stderr.readAll().toString();
		var exitCode = proc.exitCode();
		proc.close();

		if (exitCode != 0) {
			var detail = StringTools.trim(stderr);
			if (detail == "") {
				detail = "decompression failed";
			}
			throw detail;
		}
		onComplete();
	}

}
