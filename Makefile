.PHONY: install uninstall verify sync check

# Symlink every global agent into ~/.claude/agents/
install:
	@mkdir -p ~/.claude/agents
	@for f in $$(pwd)/global/*.md; do \
		target=~/.claude/agents/$$(basename $$f); \
		if [ -L "$$target" ]; then \
			echo "  · $$(basename $$f) already symlinked"; \
		else \
			ln -s "$$f" "$$target"; \
			echo "  ✓ $$(basename $$f) symlinked"; \
		fi; \
	done
	@echo ""
	@echo "Installed. Restart Claude Code to load the agents."

# Remove the symlinks (leaves the repo untouched)
uninstall:
	@for f in global/*.md; do \
		name=$$(basename $$f); \
		target=~/.claude/agents/$$name; \
		if [ -L "$$target" ]; then \
			rm "$$target"; \
			echo "  ✓ $$name unlinked"; \
		fi; \
	done

# Verify install state
verify:
	@echo "Agent files in repo:"
	@ls -1 global/*.md | sed 's|^|  |'
	@echo ""
	@echo "Symlinks in ~/.claude/agents/:"
	@ls -la ~/.claude/agents/ 2>/dev/null | grep -E '\.md$$' | sed 's|^|  |' || echo "  (none)"

# Rewrite every agent's shared writing section from shared/writing.md
sync:
	@python3 bin/sync-shared

# Assert every copy still matches the source, and that the source names
# no caller-specific vocabulary
check:
	@python3 bin/sync-shared --check
