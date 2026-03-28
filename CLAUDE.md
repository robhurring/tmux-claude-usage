# Agent Instructions

## Git Workflow (Non-Negotiable)
**Before writing any code**, you MUST:
1. Create a feature branch off master: `git checkout -b feat/kebab-description` (or `fix/`, `refactor/`, etc.)
2. Never edit files directly on `master`

**After completing work**, you MUST:
1. Commit atomically with semantic messages (`feat:`, `fix:`, `docs:`, etc.)
2. Run the tests with `make test`
3. Only push to origin if the task is significant enough to require a pull-request

