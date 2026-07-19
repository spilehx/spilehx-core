package spilehx.core.logging;

/**
	Shared settings for the global logging API.
 */
class GlobalLoggingSettings {
	@:dox(hide)
	public static inline var MSG_ERROR = "ERROR";
	@:dox(hide)
	public static inline var MSG_DEBUG = "DEBUG";
	@:dox(hide)
	public static inline var MSG_INFO = "INFO";
	@:dox(hide)
	public static inline var MSG_SOFT = "WARN";

	@:dox(hide)
	public static inline var FG_RED:Int = 31;
	@:dox(hide)
	public static inline var FG_GREEN:Int = 32;
	@:dox(hide)
	public static inline var FG_BLUE:Int = 34;
	@:dox(hide)
	public static inline var FG_DEBUG:Int = 93;

	// a little singleton to hold settings
	/**
		Singleton settings instance used by `GlobalLogger`.
	 */
	public static final settings:GlobalLoggingSettings = new GlobalLoggingSettings();

	/**
		Enables log file output on non-JavaScript targets.
	 */
	@:isVar public var toFile(get, set):Bool;
	/**
		Current log file path derived from `logFileSubFolder` and `logFileName`.
	 */
	@:isVar public var logFilePath(get, null):String;
	/**
		Prefix written before each log file entry.
	 */
	@:isVar public var logFileLinePrefix(default, default):String;
	/**
		Maximum number of entries retained in the log file.
	 */
	@:isVar public var maxLogFileLength(default, default):Int;
	/**
		Folder used for log file output.
	 */
	@:isVar public var logFileSubFolder(default, default):String;
	/**
		File name used for log file output.
	 */
	@:isVar public var logFileName(default, default):String;
	/**
		Remote logging endpoint used for remote log messages.
	 */
	@:isVar public var remoteLogUrl(default, default):String;
	/**
		Enables verbose logger output.
	 */
	@:isVar public var verbose(default, default):Bool;
	/**
		Sends error log messages to stderr on non-JavaScript targets.
	 */
	@:isVar public var stdErrOut(default, default):Bool;

	private function new() {
		this.logFileSubFolder = "./logs";
		this.logFileName = "logs.log";
		this.remoteLogUrl = "";
		this.logFileLinePrefix = "";
		this.maxLogFileLength = 100;
		this.toFile = false;
		this.stdErrOut = false;
	}

	#if (!js)
	/**
		Clears the configured log file.
	 */
	public function clearLogFile() {
		Log.clearLogFile();
	}
	#end

	function get_toFile():Bool {
		#if (js)
		// no file output in browser
		return false;
		#end

		return toFile;
	}

	function set_toFile(toFile):Bool {
		return this.toFile = toFile;
	}

	function get_logFilePath():String {
		this.logFilePath = this.logFileSubFolder + "/" + this.logFileName;
		return logFilePath;
	}
}

@:dox(hide)
enum CompileTimeLogType {
	NORMAL;
	INFO;
	WARN;
	ERROR;
}
