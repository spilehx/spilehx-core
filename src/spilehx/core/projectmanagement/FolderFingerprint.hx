package spilehx.core.projectmanagement;

import haxe.crypto.Sha256;
import sys.FileSystem;
import haxe.io.Path;

/**
	Builds short fingerprints for folder contents.
 */
class FolderFingerprint {
	/**
		Returns an 8-character fingerprint for a folder.
		The fingerprint changes when file paths, sizes, or modification times change.
	 */
	public static function fingerprint(folder:String):String {
		if (!FileSystem.isDirectory(folder)) {
			throw 'Not a directory: $folder';
		}

		var entries:Array<String> = [];
		scan(folder, "", entries);
		entries.sort(compare);

		var hash:String = Sha256.encode(entries.join("\n"));

		var shortHash = hash.substr(0, 8); // 64 bits

		return shortHash;
	}

	private static function scan(root:String, relative:String, entries:Array<String>):Void {
		var directory = relative == "" ? root : Path.join([root, relative]);

		for (name in FileSystem.readDirectory(directory)) {
			var relativePath = relative == "" ? name : relative + "/" + name;

			var absolutePath = Path.join([root, relativePath]);

			if (FileSystem.isDirectory(absolutePath)) {
				entries.push('D|$relativePath');
				scan(root, relativePath, entries);
			} else {
				var stat = FileSystem.stat(absolutePath);

				entries.push('F|$relativePath|${stat.size}|${stat.mtime.getTime()}');
			}
		}
	}

	private static function compare(a:String, b:String):Int {
		return a < b ? -1 : a > b ? 1 : 0;
	}
}
