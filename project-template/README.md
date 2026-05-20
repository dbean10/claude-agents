# Per-Project Agent Overrides

This directory is where you put project-specific subagent definitions that **replace** the global ones from `~/.claude/agents/` for this project.

## When to add a file here

- The project's stack or conventions differ enough that the global agent needs to know
- This project needs a tighter (or looser) tool allowlist
- This project needs an agent that doesn't exist globally

## Pattern

Copy the global file, then add a `## Project context` section at the bottom of the system prompt:

```bash
cp ~/.claude/agents/architect.md .claude/agents/architect.md
```

Then edit the local copy and append a section like:

```markdown
## Project context

This is the `myapp` repo. Stack:
- Frontend: Next.js 14 App Router on Vercel
- Backend: Python FastAPI on Cloud Run
- AI: claude-sonnet-4-6, web_search tool, prompt caching
- Database: Turso libSQL

Conventions:
- All AI calls go through src/lib/ai/ — never inline in route handlers
- Cloud Run env vars resolve from GCP Secret Manager at runtime
- Vercel env vars are baked at deploy time; dashboard changes require redeploy

Gotchas:
- middleware.ts must live in src/ (not project root) when using src/app/
- jest.config.js must be plain JS, not TS (ts-node absent in CI)
- Cloud SQL was deliberately not chosen — Turso fits the serverless topology better
```

The agent gets the global discipline-specific rules from the top of the file and the project-specific context from the bottom in the same system prompt.

## What's currently overridden

Nothing yet. Project-level files added here will appear in this list.
