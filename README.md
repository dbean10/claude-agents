# AI Virtual Team — Claude Code Subagents

A toolkit of ten specialized subagents that act as your virtual team across every project. Each agent has a single discipline, a clear definition of when to invoke it, and a tightly-scoped tool allowlist.

These started life as named personas in an AI-first development bootcamp. The names have been retired; the disciplines remain. Each agent is named by **function**, not by person.

## The team

| Agent | When to invoke |
|---|---|
| **architect** | System design, AI/non-AI seams, contracts at boundaries |
| **engineer** | Writing/refactoring code with product awareness |
| **security** | Threat modeling, credentials, prompt injection, audit |
| **quality** | Tests, evals, CI gates, regression-proofing |
| **data** | Retrieval, RAG, vector stores, schema design |
| **ux** | UI states, error paths, feedback collection, AI experience |
| **devops** | Deployments, observability, secrets, pipelines |
| **pm** | Scope, prioritization, what-and-why, MVP discipline |
| **cost** | Token budgets, prompt caching, model selection economics |
| **docs** | READMEs, ADRs, journal entries, technical writing |

## Install

Copy the agent files into your user-level Claude Code agents directory. They'll be available across every project on this machine.

```bash
mkdir -p ~/.claude/agents
cp global/*.md ~/.claude/agents/

# Verify
ls ~/.claude/agents/
```

Then **restart any active Claude Code session** so the new agents are loaded. Subagents created or modified on disk only take effect after a restart.

Alternatively, you can verify they loaded by running `/agents` inside Claude Code — your new agents should appear in the list.

## How to invoke

There are three ways an agent gets used. In rough order of how often each happens:

### 1. Auto-delegation (most common)

Claude Code reads the `description` field on each agent and routes appropriate work to it automatically. You write your normal prompt; the right agent gets the work.

```
You: We're about to add basic auth to this Next.js app.
Claude: [auto-invokes security agent for the threat analysis,
         then engineer agent to implement the middleware]
```

The `description` field in each agent is written specifically to trigger this routing. Action-oriented phrasing ("Use this when...", "Use PROACTIVELY...") is what makes auto-delegation work.

### 2. Explicit invocation by name

When you want a specific agent's perspective, name it.

```
You: @architect review the proposed Cloud Run + Vercel split
You: Have the security agent audit the auth flow before we merge
You: Get cost to review the new /research endpoint before we ship
```

### 3. Multi-agent workflows

Several agents in sequence on the same change.

```
You: For the new feature, get pm to scope the MVP, architect to
     design the seams, engineer to implement, quality to write
     the tests, security to review, then docs to write the ADR.
```

Each agent runs in its own context window — they don't pollute each other or the parent session.

## The hybrid global / per-project pattern

These ten agents live in `~/.claude/agents/`. That makes them available in every project.

For a specific project, you can add overrides at `<project>/.claude/agents/`. A file with the same name **replaces** the global one (it doesn't extend). So a per-project override needs to be self-contained.

### When to override per-project

- The project has its own conventions (file structure, naming, deployment target) that the agent should know about
- The project needs an agent with different tool permissions (e.g., engineer with restricted Bash on a sensitive repo)
- The project has its own agent that doesn't fit the standard ten (e.g., `migration` for a database-heavy repo)

### How to override

Copy the global file into the project, then layer your project-specific context onto the system prompt:

```bash
mkdir -p .claude/agents
cp ~/.claude/agents/architect.md .claude/agents/architect.md
# Edit the project copy to add project-specific context
```

The per-project file takes precedence within that project.

### What to include in per-project overrides

A useful pattern is to keep the global system prompt at the top, then add a `## Project context` section at the bottom with stack details, conventions, and gotchas. The agent reads the whole file, so the local context naturally informs its work.

## Customizing the team

These agents are a starting point. Expect to tune them as you discover what works:

- An agent that auto-invokes too aggressively → tighten the `description`
- An agent that never gets auto-invoked → make the `description` more action-oriented and specific
- An agent that has the wrong tool list → adjust the `tools:` frontmatter
- An agent producing output you don't want → edit the system prompt's "Output format" section
- A gap you keep hitting → add a new agent

Treat the kit as v0.1. The version that fits your work will diverge from this one.

## Design choices, briefly

A few decisions worth knowing:

**Function over persona.** Each agent is named by its discipline (architect, engineer, security) not by a person. This makes the toolkit portable across users and future-proofs the framework for agents that aren't human-shaped.

**One agent per role, not review-vs-doer split.** Each agent is versatile — invoking it as a reviewer triggers review behavior; invoking it for implementation triggers doer behavior. Less overhead, more flexibility.

**Conservative tool allowlists.** Each agent gets only the tools it needs. Reviewer-leaning agents (security, pm, cost) cannot write files. Doer agents (engineer, devops, quality) can. This bounds blast radius.

**System prompts encode load-bearing principles.** Each agent's prompt contains specific, opinionated rules (e.g., "AI reads but never writes directly to deterministic systems", "Configured does not equal enforcing", "Define failure states before happy path"). These aren't vague heuristics — they're the rules that earned their place through real engineering experience.

**Model: sonnet across the board.** Could be tuned upward to opus for security/architecture review or downward to haiku for cost/docs work, but sonnet is the right default for most. Adjust the `model:` field if you want different.

## Troubleshooting

**Agents don't appear when I run `/agents`.** Did you restart the session? Subagent loading happens at session start.

**Agent is being invoked too often.** Tighten its `description` — make it more specific about when it should be used. Consider adding "only use when..." language.

**Agent is never being invoked.** Loosen its `description` — make it more action-oriented with phrases like "Use PROACTIVELY when..." Specific trigger conditions help the parent agent route correctly.

**Agent produces output in the wrong format.** Edit the "Output format" section of its system prompt to be more specific.

**Want to override globally for one session.** Run Claude Code with `--agent <name>` to force a specific agent for the entire session.

## License

These definitions are yours to modify and extend. They are not a product — they are scaffolding. The point is that you make them yours.
