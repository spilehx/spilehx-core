package spilehx.core.logging;

import haxe.PosInfos;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import spilehx.core.logging.GlobalLoggingSettings.CompileTimeLogType;
#end

class GlobalLogger {
	#if macro
	public static macro function ensureImport():Expr {
		Log.compileTimeLog("Setting up Logging System");
		spilehx.core.macrotools.projectsetup.ProjectConfigEntry.createImportEntry("import spilehx.core.logging.GlobalLogger;");
		spilehx.core.macrotools.projectsetup.ProjectConfigEntry.createImportEntry("import spilehx.core.logging.GlobalLogger.*;");
		return macro {};
	}
	#end

	private static var debugPrefix = Log.debugPrefix;

	public static var LOG_SETTINGS:GlobalLoggingSettings = GlobalLoggingSettings.settings;

	/*
	 * Public logging API
	 *
	 * These macros expose only the parameters callers should provide.
	 */
	public static macro function LOG(msg:ExprOf<String>):Expr {
		return makeLoggingCall(macro GlobalLogger.logImpl($msg));
	}

	public static macro function LOG_INFO(msg:ExprOf<String>):Expr {
		return makeLoggingCall(macro GlobalLogger.logInfoImpl($msg));
	}

	public static macro function LOG_ERROR(msg:ExprOf<String>):Expr {
		return makeLoggingCall(macro GlobalLogger.logErrorImpl($msg));
	}

	public static macro function LOG_WARN(msg:ExprOf<String>):Expr {
		return makeLoggingCall(macro GlobalLogger.logWarnImpl($msg));
	}

	public static macro function LOG_OBJECT(obj:Expr):Expr {
		return makeLoggingCall(macro GlobalLogger.logObjectImpl($obj));
	}

	/*
	 * User-facing messages do not require source positions, so these remain
	 * ordinary runtime functions.
	 */
	public static function USER_MESSAGE(msg:String, ?forceMsg:Bool = true):Void {
		if (!GlobalLoggingSettings.settings.verbose && !forceMsg) {
			return;
		}

		Log.userMessage(msg);
	}

	public static function USER_MESSAGE_INFO(msg:String, ?forceMsg:Bool = true):Void {
		if (!GlobalLoggingSettings.settings.verbose && !forceMsg) {
			return;
		}

		Log.userMessageInfo(msg);
	}

	public static function USER_MESSAGE_WARN(msg:String, ?forceMsg:Bool = true):Void {
		if (!GlobalLoggingSettings.settings.verbose && !forceMsg) {
			return;
		}

		Log.userMessageWarn(msg);
	}

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

	/*
	 * Internal runtime implementations
	 *
	 * @:noCompletion keeps these out of normal IDE completion.
	 * Their PosInfos arguments are omitted by the generated macro calls,
	 * so Haxe injects the call-site information.
	 */
	@:noCompletion
	public static function logImpl(msg:String, ?pos:PosInfos):Void {
		if (!GlobalLoggingSettings.settings.verbose) {
			return;
		}

		Log.log(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	@:noCompletion
	public static function logInfoImpl(msg:String, ?pos:PosInfos):Void {
		if (!GlobalLoggingSettings.settings.verbose) {
			return;
		}

		Log.info(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	@:noCompletion
	public static function logErrorImpl(msg:String, ?pos:PosInfos):Void {
		Log.error(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	@:noCompletion
	public static function logWarnImpl(msg:String, ?pos:PosInfos):Void {
		if (!GlobalLoggingSettings.settings.verbose) {
			USER_MESSAGE_WARN(msg, true);
			return;
		}

		Log.warn(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	@:noCompletion
	public static function logObjectImpl(obj:Dynamic, ?pos:PosInfos):Void {
		if (!GlobalLoggingSettings.settings.verbose) {
			return;
		}

		Log.logObject(debugPrefix(pos), obj);
	}
}
