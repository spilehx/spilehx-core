package spilehx.core.cli;

class CLIArgHelper {
	private var INDENT:String = "  \t";
	private var TAB:String = "\t";

	@:isVar public var helpText_appName(null, default):String;
	@:isVar public var helpText_version(null, default):String;
	@:isVar public var helpText_usage(null, default):String;
	@:isVar public var helpText_description(null, default):Array<String>;
	@:isVar public var helpText_examples(null, default):Array<String>;
	@:isVar public var exitOnNoCliArgs(null, default):Bool;

	public static final instance:CLIArgHelper = new CLIArgHelper();

	private var CLICommandArgs:Array<CLICommandArg>;
	private var onValidArgSubmitted:CLICommandArg->Void;

	private function new() {}

	public function parseApplicationArguments(CLICommandArgs:Array<CLICommandArg>, onValidArgSubmitted:CLICommandArg->Void, argOverride:Array<String> = null) {
		this.CLICommandArgs = CLICommandArgs;
		this.onValidArgSubmitted = onValidArgSubmitted;

		var cliArgs:Array<CLIArg> = getValidCLIArgs(argOverride);

		if (cliArgs.length == 0) {
			if (exitOnNoCliArgs == true) {
				printHelpAndExit();
			}
		}

		if (cliArgs.length > 0) {
			triggerCLIArgs(cliArgs);
		}
	}

	private function triggerCLIArgs(cliArgs:Array<CLIArg>) {
		// look for invalid arg keys
		var validKeys = CLICommandArgs.map(a -> a.keyValue);
		var invalidKeyFound = Lambda.exists(cliArgs, cliArg -> {
			if (!validKeys.contains(cliArg.argKey)) {
				outputArgErrorMessage("Invalid key " + cliArg.argKey);
				return true;
			}
			return false;
		});

		var helpArg:Bool = Lambda.exists(cliArgs, a -> a.argKey == "--help");

		if (helpArg == true || invalidKeyFound == true) {
			printHelpAndExit();
		} else {
			var isolatedCommand:CLICommandArg = null;
			var foundApplicationArguments:Array<CLICommandArg> = [];

			while (cliArgs.length > 0) {
				var cliArg:CLIArg = cliArgs.pop();
				var foundApplicationArgument:CLICommandArg = Lambda.find(CLICommandArgs, arg -> arg.keyValue == cliArg.argKey);
				foundApplicationArgument.targetPropertyValue = cliArg.argValue;

				if (foundApplicationArgument.isolatedCommand == true) {
					isolatedCommand = foundApplicationArgument;
				}

				foundApplicationArguments.push(foundApplicationArgument);
			}

			if (isolatedCommand != null && foundApplicationArguments.length > 1) {
				outputArgErrorMessage(isolatedCommand.keyValue + " cannot be used like this!");
				printHelpAndExit();
			} else {
				for (foundApplicationArgument in foundApplicationArguments) {
					onValidArgSubmitted(foundApplicationArgument);
				}
			}
		}
	}

	private function getValidCLIArgs(argOverride:Array<String> = null):Array<CLIArg> {
		var args:Array<String> = [];

		if (argOverride != null) {
			args = argOverride;
		} else {
			args = Sys.args();
		}

		if (args.length == 0) {
			return [];
		} else if (args.indexOf("--help") > -1) {
			return [
				{
					argKey: "--help",
					argValue: ""
				}
			];
		} else if (args.length % 2 != 0) {
			// by definition there must be an even number of args
			// if not print error and set to --help arg
			outputArgErrorMessage("Bad Arguments");
			return [
				{
					argKey: "--help",
					argValue: ""
				}
			];
		} else {
			// if we are here we have found an even number of arg that does not contain --help
			var validArgs:Array<CLIArg> = new Array<CLIArg>();
			while (args.length > 0) {
				var argKey:String = args.shift();
				var argValue:String = args.shift();
				validArgs.push({
					argKey: argKey,
					argValue: argValue
				});
			}
			return validArgs;
		}
	}

	private function outputArgErrorMessage(errorMsg:String) {
		USER_MESSAGE("");
		USER_MESSAGE_ERROR("ERROR: " + errorMsg);
	}

	private function printHelpAndExit() {
		USER_MESSAGE("");
		USER_MESSAGE(helpText_appName + " - " + helpText_version);
		USER_MESSAGE("========================================");

		USER_MESSAGE("");
		USER_MESSAGE("Usage:");
		USER_MESSAGE_INFO(INDENT + helpText_usage);

		USER_MESSAGE("");
		USER_MESSAGE("Description:");
		for (line in helpText_description) {
			USER_MESSAGE_INFO(INDENT + line);
		}

		USER_MESSAGE("");
		USER_MESSAGE("Options:");
		for (arg in CLICommandArgs) {
			var msgContent:Array<String> = [];
			msgContent.push(INDENT);
			msgContent.push(arg.keyValue);

			if (arg.targetProperty != null && arg.targetProperty != "") {
				msgContent.push("[" + arg.targetProperty.toUpperCase() + "]");
			}

			msgContent.push(TAB);
			msgContent.push(arg.description);

			USER_MESSAGE_INFO(msgContent.join(" "));
		}

		USER_MESSAGE("");
		USER_MESSAGE("Examples:");
		for (line in helpText_examples) {
			USER_MESSAGE_INFO(INDENT + line);
		}

		Sys.exit(1);
	}
}

typedef CLIArg = {
	var argKey:String;
	var argValue:String;
}
