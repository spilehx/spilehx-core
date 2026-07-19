# Code Style

## Scope

Use the existing Haxe style in this repository. Prefer consistency over personal preference.

## Formatting

- Use tabs for indentation.
- Place opening braces on the same line.
- Use explicit types on public APIs and where they improve clarity.
- Keep imports grouped at the top, with conditional macro imports inside `#if macro`.
- Keep target-specific code inside clear Haxe conditional compilation blocks.
- Preserve existing naming conventions: `PascalCase` types, `camelCase` members, and `UPPER_CASE` constants.

## Design

- Apply single responsibility: each class and function should have one clear purpose.
- Keep functions small and focused.
- Prefer straightforward control flow and early returns.
- Apply DRY only when duplication represents the same stable concept.
- Apply KISS: avoid unnecessary abstraction, indirection, metaprogramming, or configuration.
- Do not add dependencies unless explicitly required.
- Preserve public APIs and cross-target behaviour unless instructed otherwise.

## Readability

- Choose descriptive names that communicate intent.
- Make behaviour clear from the code without relying on comments.
- Avoid hidden side effects and surprising state changes.
- Keep related logic together.
- Remove dead, redundant, or obsolete code when code changes are permitted.

## Comments

- Comments must explain purpose, constraints, target behaviour, or non-obvious decisions.
- Do not restate the code.
- Keep documentation concise, accurate, and maintained with the implementation.
- Use Haxe documentation comments for public APIs where documentation adds value.

## Changes

- Make the smallest maintainable change.
- Avoid unrelated refactoring or formatting changes.
- Prefer clear, readable, easily tested code over clever code.
