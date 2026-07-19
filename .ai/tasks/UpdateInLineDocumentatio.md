Review all `.hx` files in this workspace and improve their API documentation.

Goals:

* Keep documentation comments short, clear, and concise.
* Only document code that is intended to be part of the public-facing API.
* Remove unnecessary, repetitive, outdated, or overly verbose documentation comments.
* Add missing documentation comments for public API classes, enums, abstracts, typedefs, fields, properties, constructors, and functions.
* Amend existing documentation comments where they are unclear, inaccurate, or too long.
* Hide internal implementation details from Dox.

Rules:

1. Treat public-facing API as code that library users are expected to call, instantiate, extend, implement, configure, or reference directly.

2. Treat code as internal when it is:

   * an implementation detail;
   * a helper used only inside the library;
   * generated or compiler-facing code;
   * a macro implementation detail;
   * an adapter, bridge, parser helper, internal configuration structure, or private workflow type;
   * public only because of Haxe visibility or macro limitations.

3. For public API:

   * Use Haxe documentation comments in the form `/** ... */`.
   * Place the comment immediately above the documented declaration.
   * Prefer one or two short sentences.
   * Explain what the API does, not how its implementation works.
   * Add `@param`, `@return`, `@throws`, `@see`, or `@deprecated` only when they add useful information.
   * Do not repeat information already obvious from the name and type signature.
   * Do not add comments such as “Gets the value” or “Sets the value” unless there is important behaviour to explain.
   * Keep terminology consistent across the project.

4. For internal API:

   * Prefer making the declaration `private` when that is safe and does not change intended behaviour.
   * Otherwise add `@:dox(hide)` directly above the class, enum, abstract, typedef, field, property, constructor, or function.
   * Use `@:noCompletion` only when the declaration should also be hidden from IDE completion.
   * Do not change public visibility solely to improve documentation unless it is clearly safe.
   * Do not hide code that users are expected to access.

5. Remove documentation comments from internal declarations once they are hidden, unless the comment is still useful to maintainers.

6. Preserve:

   * runtime behaviour;
   * public signatures;
   * metadata unrelated to documentation;
   * conditional compilation blocks;
   * macro behaviour;
   * formatting conventions already used by the project.

7. Do not:

   * invent behaviour that cannot be confirmed from the code;
   * add long tutorials or examples;
   * document every private helper;
   * change implementation logic;
   * rename declarations;
   * introduce breaking API changes;
   * add `@:dox(hide)` to standard Haxe types or external library types.

Process:

1. Inspect the whole workspace before editing.
2. Identify the intended public API from package structure, visibility, usage, naming, metadata, imports, and references.
3. Update all relevant `.hx` files.
4. Keep changes focused on documentation and Dox visibility metadata.
5. After editing, review the diff for consistency.
6. Run the existing Haxe build and documentation commands if available.
7. Report:

   * which public APIs received new or revised documentation;
   * which declarations were hidden with `@:dox(hide)`;
   * any declarations whose public/internal status was ambiguous;
   * any build or documentation errors encountered.

Use this style:

```haxe
/**
 * Writes a message using the configured logger.
 */
public function log(message:String):Void {
}
```

For a parameter that is not obvious:

```haxe
/**
 * Writes a message at the specified severity.
 *
 * @param level Minimum severity assigned to the message.
 */
public function log(level:LogLevel, message:String):Void {
}
```

For internal code that must remain public:

```haxe
@:dox(hide)
public function rebuildInternalCache():Void {
}
```

For an internal type:

```haxe
@:dox(hide)
class InternalProjectResolver {
}
```

Make the edits directly. Do not stop after only producing recommendations.
