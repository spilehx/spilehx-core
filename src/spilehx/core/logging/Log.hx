package spilehx.core.logging;

import haxe.PosInfos;
#if macro
import spilehx.core.logging.GlobalLoggingSettings.CompileTimeLogType;
#end

class Log {
	#if macro
	public static function compileTimeLog(msg:String) {
		compileTimeLogOutput(msg, CompileTimeLogType.LOG);
	}

	public static function compileTimeLogInfo(msg:String) {
		compileTimeLogOutput(msg, CompileTimeLogType.INFO);
	}

	public static function compileTimeLogWarn(msg:String) {
		compileTimeLogOutput(msg, CompileTimeLogType.WARN);
	}

	public static function compileTimeLogError(msg:String) {
		compileTimeLogOutput(msg, CompileTimeLogType.ERROR);
	}

	private static function compileTimeLogOutput(msg:String, type:CompileTimeLogType = CompileTimeLogType.INFO) {
		var colour:Int = GlobalLoggingSettings.FG_GREEN;

		switch (type) {
			case INFO:
				colour = GlobalLoggingSettings.FG_GREEN;

			case WARN:
				colour = GlobalLoggingSettings.FG_BLUE;

			case ERROR:
				colour = GlobalLoggingSettings.FG_RED;

			case LOG:
				colour = GlobalLoggingSettings.FG_DEBUG;
		}

		var out:String = "\033[1;" + colour + "m" + msg + " \033[0m";

		Sys.println(out);
	}
	#end

	public static function log(debugprefix:String, msg:String, toFile:Bool = false) {
		out(debugprefix, msg, GlobalLoggingSettings.MSG_DEBUG, toFile);
	}

	public static function info(debugprefix:String, msg:String, toFile:Bool = false) {
		out(debugprefix, msg, GlobalLoggingSettings.MSG_INFO, toFile);
	}

	public static function warn(debugprefix:String, msg:String, toFile:Bool = false) {
		out(debugprefix, msg, GlobalLoggingSettings.MSG_SOFT, toFile);
	}

	public static function error(debugprefix:String, msg:String, toFile:Bool = false) {
		out(debugprefix, msg, GlobalLoggingSettings.MSG_ERROR, toFile);
	}

	public static function userMessage(msg:String) {
		var out:String = "\033[1;" + GlobalLoggingSettings.FG_GREEN + "m" + msg + " \033[0m";
		platfromSpecificLogCommand(out);
	}

	public static function userMessageInfo(msg:String) {
		var out:String = "\033[1;" + GlobalLoggingSettings.FG_DEBUG + "m" + msg + " \033[0m";
		platfromSpecificLogCommand(out);
	}

	public static function userMessageWarn(msg:String) {
		var out:String = "\033[1;" + GlobalLoggingSettings.FG_BLUE + "m" + msg + " \033[0m";
		platfromSpecificLogCommand(out);
	}

	public static function userMessageError(msg:String) {
		var out:String = "\033[1;" + GlobalLoggingSettings.FG_RED + "m" + msg + " \033[0m";
		platfromSpecificLogCommand(out);
	}

	public static function logObject(prefix:String, obj:Dynamic) {
		log(prefix, "----------- LOGGING OBJECT -----------");
		var fields = Reflect.fields(obj);

		for (field in fields) {
			var value = Reflect.getProperty(obj, field);

			if (value != null) {
				log("", "Field-->" + field + "  Value--->" + Std.string(value), false);
			} else {
				log("", "Field-->" + field + "  IS NULL", false);
			}
		}
	}

	private static function out(debugprefix:String, msg:String, type:String = "", toFile:Bool = false) {
		var out:String = "";

		if (type == GlobalLoggingSettings.MSG_INFO) {
			out = "\033[1;" + GlobalLoggingSettings.FG_GREEN + "mINFO: \033[0m";
		} else if (type == GlobalLoggingSettings.MSG_SOFT) {
			out = "\033[1;" + GlobalLoggingSettings.FG_BLUE + "mWARNING: \033[0m";
		} else if (type == GlobalLoggingSettings.MSG_ERROR) {
			out = "\033[1;" + GlobalLoggingSettings.FG_RED + "mERROR: \033[0m";
		} else if (type == GlobalLoggingSettings.MSG_DEBUG) {
			out = "\033[1;" + GlobalLoggingSettings.FG_DEBUG + "mDEBUG: \033[0m";
		}

		out = out + debugprefix + msg;

		if (toFile) {
			appendTextToLogFile(msg, type);
		}

		#if (!js)
		if (type == GlobalLoggingSettings.MSG_ERROR && GlobalLoggingSettings.settings.stdErrOut == true) {
			stdErrOut(msg);
		}
		#end

		platfromSpecificLogCommand(out);
	}

	private static function stdErrOut(msg:String) {
		#if (!js)
		Sys.stderr().writeString(msg + "\n");
		#end
	}

	#if (!js)
	public static function sendRemoteLog(msg:String) {
		if (GlobalLoggingSettings.settings.remoteLogUrl == "") {
			warn("", "remoteLogUrl not set");
			return;
		}
		var fullPath = Sys.programPath();
		var appName = fullPath.split("/").pop().split("\\").pop(); // Extract the file name from the path

		var url = GlobalLoggingSettings.settings.remoteLogUrl + "/?source=" + appName + "&log=\"" + msg + "\"";

		try {
			var http = new haxe.Http(url);
			http.onData = function(data:String) {}

			http.onError = function(error:String) {}

			http.request();
		} catch (e) {
			// dont need to catch an error - this is remote logging
		}
	}
	#end

	private static function appendTextToLogFile(msg:String, type:String = "") {
		var out:String = "";
		if (type == GlobalLoggingSettings.MSG_INFO) {
			out = "INFO : " + msg;
		} else if (type == GlobalLoggingSettings.MSG_SOFT) {
			out = "WARNING : " + msg;
		} else if (type == GlobalLoggingSettings.MSG_ERROR) {
			out = "ERROR : " + msg;
		} else {
			out = msg;
		}

		#if (!js)
		var dateStampString:String = DateTools.format(Date.now(), "%Y-%m-%d_%H:%M:%S");
		var logLine:String = "[" + dateStampString + "] " + GlobalLoggingSettings.settings.logFileLinePrefix + ": " + out;

		appendTextToFile(logLine, GlobalLoggingSettings.settings.logFilePath);
		#end
	}

	public static function debugPrefix(pos:PosInfos):String {
		var prefix:String = pos.fileName + ":" + pos.lineNumber + ": ";
		return prefix;
	}

	private static function platfromSpecificLogCommand(msg:String) {
		#if (js)
		Reflect.callMethod(js.Browser.console, js.Browser.console.log, [msg]);
		#else
		Sys.println(msg);
		#end
	}

	#if (!js)
	public static function appendTextToFile(content:String, outputFilePath:String) {
		var LINE_DELIM:String = "\n";
		var contentArr:Array<String> = new Array<String>();

		// setup folder
		if (sys.FileSystem.exists(GlobalLoggingSettings.settings.logFileSubFolder) == false) {
			sys.FileSystem.createDirectory(GlobalLoggingSettings.settings.logFileSubFolder);
		}

		// get current content
		if (sys.FileSystem.exists(outputFilePath)) {
			contentArr = sys.io.File.getContent(outputFilePath).split(LINE_DELIM);
		}

		// add new content
		contentArr.push(content);

		// limit length
		while (contentArr.length > GlobalLoggingSettings.settings.maxLogFileLength) {
			contentArr.shift();
		}

		writeLogFile(contentArr.join(LINE_DELIM));
	}

	public static function clearLogFile() {
		writeLogFile("");
	}

	static function writeLogFile(text:String):Void {
		var path = GlobalLoggingSettings.settings.logFilePath;
		var dir = haxe.io.Path.directory(path);

		if (!sys.FileSystem.exists(dir)) {
			sys.FileSystem.createDirectory(dir);
		}

		// create file if missing, otherwise overwrite
		var out = sys.io.File.write(path, false);
		out.writeString(text + "\n");
		out.close();
	}
	#end
}
