# Code Style

Shared style rules for this repository.

## Haxe

- Match the existing style in nearby files.
- Use tabs for indentation.
- Put opening braces on the same line.
- Keep imports at the top; keep macro-only imports inside `#if macro`.
- Preserve target conditionals such as `#if macro` and `#if (!js)`.
- Keep public API types explicit.
- Do not add dependencies unless the user asks.

## Comments

- Keep comments short and technical.
- Document purpose and important behavior, not obvious implementation steps.
- Use Haxe doc comments only for public-facing API:

```haxe
/**
	Writes a message using the configured logger.
 */
public function log(message:String):Void {
}
```

- Use `@:dox(hide)` for internal declarations that must remain visible to Haxe but should not appear in generated docs.

## Changes

- Preserve runtime behavior unless the user explicitly asks for implementation changes.
- Keep changes focused on the requested files and task.
- Review the diff before finishing.
