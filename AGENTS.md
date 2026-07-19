# AGENTS.md

Instructions for AI assistants working in this repository.

## Purpose

Help users understand, document, and use `spilehx-core` in Haxe projects.

## Read First

- Read [README.md](README.md) for the public library overview.
- Read [.ai/code_styles.md](.ai/code_styles.md) before editing Haxe or documentation.
- Read a task file from `.ai/tasks/` when the user request matches one of the triggers below.
- Read the relevant `.hx` source before giving API-specific guidance.

Instruction priority: `AGENTS.md` > `.ai/tasks/*` > `.ai/code_styles.md` > `README.md`.

## Task Routing

- Use [.ai/tasks/use-core-lib.md](.ai/tasks/use-core-lib.md) when the user asks how to use, configure, import, or troubleshoot this library in a Haxe project.
- Use [.ai/tasks/update-api-docs.md](.ai/tasks/update-api-docs.md) when the user asks to review, add, rewrite, or clean up inline Haxe API documentation.

## General Rules

- Keep answers short, practical, and Haxe-focused.
- Preserve existing behavior, public signatures, macro behavior, and conditional compilation unless the user explicitly asks for code changes.
- Do not invent API behavior. Confirm it from source, README, or build files.
- Prefer small edits over broad rewrites.
- Ask one clear question when the user request is ambiguous.

## Repository Scope

- Source code lives in `src/`.
- User-facing docs live in `README.md` and generated docs under `docs/`.
- AI helper instructions live in `.ai/`.
- `extraParams.hxml` contains the optional logging import setup macro.
