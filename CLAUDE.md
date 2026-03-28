# Agent Instructions

## Git Workflow (Non-Negotiable)
**Before writing any code**, you MUST:
1. Create a feature branch off master: `git checkout -b feat/kebab-description` (or `fix/`, `refactor/`, etc.)
2. Never edit files directly on `master`

**After completing work**, you MUST:
1. Commit atomically with semantic messages (`feat:`, `fix:`, `docs:`, etc.)
2. Only push to origin if the task requires a pull-request (L/XL tasks or when explicitly asked)
3. Run the tests with `make test`

