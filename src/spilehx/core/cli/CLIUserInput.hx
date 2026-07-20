package spilehx.core.cli;

import haxe.Constraints.Function;

class CLIUserInput {
	public static function ask(question:String, ?defaultValue:String):String {
		Sys.print("");
		if (defaultValue != null) {
			Sys.print('$question [$defaultValue]: ');
		} else {
			Sys.print('$question: ');
		}

		var input = "";
		try {
			input = StringTools.trim(Sys.stdin().readLine());
		} catch (e:Dynamic) {
			exitWithMessage();
		}

		if (input == "" && defaultValue != null) {
			return defaultValue;
		}

		return input;
	}

	public static function askConfirm(question:String, defaultValue:Bool = false):Bool {
		Sys.print("");
		return ask(question + " (y/n)", defaultValue ? "y" : "n").toLowerCase() == "y";
	}

	public static function askOptions(question:String, options:Array<CLIUserInputOptions>) {
		Sys.print("");
		Sys.print('$question: ');

		for (i in 0...options.length) {
			Sys.print("\n  " + "[" + (i + 1) + "] " + options[i].label);
		}

		// or exit
		Sys.print("\n  " + "[" + (options.length + 1) + "] Exit");
		Sys.print("\n\nChoose and press enter: ");

		var input = StringTools.trim(Sys.stdin().readLine());
		try {
			var inputIndex = Std.parseInt(input) - 1;

			if (input == "" || input == null || inputIndex < 0 || inputIndex >= options.length) {
				trace("we would exit");
				exitWithMessage();
			} else {
				var selectedOption = options[inputIndex];
				trace("Selected option: " + selectedOption.label);
				selectedOption.callBack();
			}
		} catch (e:Dynamic) {
			exitWithMessage();
		}
	}

	private static function exitWithMessage():Void {
		USER_MESSAGE_INFO("Exiting application.\n");
		Sys.exit(0);
	}
}

typedef CLIUserInputOptions = {
	var label:String;
	var callBack:Function;
}
