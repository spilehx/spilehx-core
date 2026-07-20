package spilehx.core.cli;

class CLICommandArg {
	@:isVar public var keyValue(default, null):String;
	@:isVar public var targetProperty(default, null):String;
	@:isVar public var description(default, null):String;
	@:isVar public var isolatedCommand(default, null):Bool; // If this command can only be run with no other commands
	@:isVar public var targetPropertyValue(default, default):String;

	public function new(keyValue:String, targetProperty:String, description:String, isolatedCommand:Bool = true) {
		this.keyValue = keyValue;
		this.targetProperty = targetProperty;
		this.description = description;
		this.isolatedCommand = isolatedCommand;
	}
}
