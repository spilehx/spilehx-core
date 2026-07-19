# Task: Update API Documentation

Use this task when the user asks to review, add, rewrite, or clean up inline Haxe API documentation.

## Goal

Improve comments for the public API while keeping implementation details out of generated Dox output.

## Steps

1. Read `AGENTS.md`, `.ai/code_styles.md`, and the relevant `.hx` files.
2. Identify public API: types and members library users call, configure, extend, or reference.
3. Add or revise concise `/** ... */` comments for public API only.
4. Hide internal public declarations with `@:dox(hide)` when they must stay public for Haxe or macro reasons.
5. Do not change behavior, signatures, names, or unrelated formatting.
6. Run the available Haxe build and docs commands when practical.
7. Report changed public docs, hidden declarations, ambiguous API status, and any build/doc errors.

## Public API Comments

- Prefer one short sentence.
- Add tags such as `@param` or `@return` only when they add useful information.
- Do not document obvious getters, setters, or private helpers.

## Internal API

Treat implementation helpers, macro internals, generated code, adapters, and compiler-facing workflow types as internal unless the source or README shows that users should call them.
