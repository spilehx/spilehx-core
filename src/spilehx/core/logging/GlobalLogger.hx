package spilehx.core.logging;

import haxe.PosInfos;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import spilehx.core.logging.GlobalLoggingSettings.CompileTimeLogType;
#end

/**
	Global logging macros and user-message helpers.
 */
class GlobalLogger {
	#if macro
	/**
		Adds the global logger imports to `import.hx` in the configured source folder.
	 */
	public static macro function ensureImport():Expr {
		// Log.compileTimeLog("Setting up Logging System");

		var projectPath = spilehx.core.macrotools.MacroTools.getSrcRoot();
		spilehx.core.projectsetup.ProjectConfigEntry.createImportEntry("import spilehx.core.logging.GlobalLogger;", projectPath);
		spilehx.core.projectsetup.ProjectConfigEntry.createImportEntry("import spilehx.core.logging.GlobalLogger.*;", projectPath);
		return macro {};
	}
	#end

	private static var debugPrefix = Log.debugPrefix;

	/**
		Shared logging configuration.
	 */
	public static var LOG_SETTINGS:GlobalLoggingSettings = GlobalLoggingSettings.settings;

	/**
		Logs a debug message with call-site source information when verbose logging is enabled.
	 */
	public static macro function LOG(msg:ExprOf<String>):Expr {
		return makeLoggingCall(macro GlobalLogger.logImpl($msg));
	}

	/**
		Logs an informational message with call-site source information when verbose logging is enabled.
	 */
	public static macro function LOG_INFO(msg:ExprOf<String>):Expr {
		return makeLoggingCall(macro GlobalLogger.logInfoImpl($msg));
	}

	/**
		Logs an error message with call-site source information.
	 */
	public static macro function LOG_ERROR(msg:ExprOf<String>):Expr {
		return makeLoggingCall(macro GlobalLogger.logErrorImpl($msg));
	}

	/**
		Logs a warning message with call-site source information.
	 */
	public static macro function LOG_WARN(msg:ExprOf<String>):Expr {
		return makeLoggingCall(macro GlobalLogger.logWarnImpl($msg));
	}

	/**
		Logs the reflected fields of an object when verbose logging is enabled.
	 */
	public static macro function LOG_OBJECT(obj:Expr):Expr {
		return makeLoggingCall(macro GlobalLogger.logObjectImpl($obj));
	}

	/**
		Writes a user-visible message.
		When `forceMsg` is false, output is suppressed unless verbose logging is enabled.
	 */
	public static function USER_MESSAGE(msg:String, ?forceMsg:Bool = true):Void {
		if (!GlobalLoggingSettings.settings.verbose && !forceMsg) {
			return;
		}

		Log.userMessage(msg);
	}

	/**
		Writes an informational user-visible message.
		When `forceMsg` is false, output is suppressed unless verbose logging is enabled.
	 */
	public static function USER_MESSAGE_INFO(msg:String, ?forceMsg:Bool = true):Void {
		if (!GlobalLoggingSettings.settings.verbose && !forceMsg) {
			return;
		}

		Log.userMessageInfo(msg);
	}

	/**
		Writes a warning user-visible message.
		When `forceMsg` is false, output is suppressed unless verbose logging is enabled.
	 */
	public static function USER_MESSAGE_WARN(msg:String, ?forceMsg:Bool = true):Void {
		if (!GlobalLoggingSettings.settings.verbose && !forceMsg) {
			return;
		}

		Log.userMessageWarn(msg);
	}

	/**
		Writes an error user-visible message.
		When `forceMsg` is false, output is suppressed unless verbose logging is enabled.
	 */
	public static function USER_MESSAGE_ERROR(msg:String, ?forceMsg:Bool = true):Void {
		if (!GlobalLoggingSettings.settings.verbose && !forceMsg) {
			return;
		}

		Log.userMessageError(msg);
	}

	#if macro
	private static function makeLoggingCall(expression:Expr):Expr {
		/*
		 * Ensure PosInfos injection uses the position where the public
		 * logging macro was called.
		 */
		expression.pos = haxe.macro.Context.currentPos();
		return expression;
	}
	#end

	@:dox(hide)
	@:noCompletion
	public static function logImpl(msg:String, ?pos:PosInfos):Void {
		if (!GlobalLoggingSettings.settings.verbose) {
			return;
		}

		Log.log(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	@:dox(hide)
	@:noCompletion
	public static function logInfoImpl(msg:String, ?pos:PosInfos):Void {
		if (!GlobalLoggingSettings.settings.verbose) {
			return;
		}

		Log.info(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	@:dox(hide)
	@:noCompletion
	public static function logErrorImpl(msg:String, ?pos:PosInfos):Void {
		Log.error(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	@:dox(hide)
	@:noCompletion
	public static function logWarnImpl(msg:String, ?pos:PosInfos):Void {
		if (!GlobalLoggingSettings.settings.verbose) {
			USER_MESSAGE_WARN(msg, true);
			return;
		}

		Log.warn(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	@:dox(hide)
	@:noCompletion
	public static function logObjectImpl(obj:Dynamic, ?pos:PosInfos):Void {
		if (!GlobalLoggingSettings.settings.verbose) {
			return;
		}

		Log.logObject(debugPrefix(pos), obj);
	}
}
