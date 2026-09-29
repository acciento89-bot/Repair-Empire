# AGENTS.md

## Repair Empire execution contract

Before changing implementation code, read:
1. `README.md`
2. all canonical specs listed there
3. `docs/MASTER-PLAN.md`
4. `docs/REPAIR-EMPIRE-V1-LEDGER.md`
5. the detail plan for the next open phase

## Mandatory workflow
- Use the ledger as the canonical task state.
- Work on the next open task and only its explicit dependencies.
- Do not reduce the approved V1 to an MVP.
- Do not redesign approved product scope unless a documented change request requires it.
- Keep economy, progression, purchases and job completion server-authoritative.
- Keep content/tunables data-driven.
- Run applicable tests/static checks before marking a task complete.
- Commit completed work to GitHub.
- Update the ledger only after acceptance criteria are verified.
- Continue to the next task unless a real blocker remains.
- Maintain exactly one canonical local Roblox place artifact: `build.rbxlx`. Do not persist `QA`, `mainQA`, release-copy or backup `.rbxl/.rbxlx` files.
- Temporary runtime screenshots or probes belong only under `/private/tmp` and must be deleted after verification.
- Publish development and production places only from the canonical current source/build. Never publish from an older local QA place copy.

## Completion report
Always report:
- completed task IDs
- files changed
- tests/checks and results
- commit(s)
- ledger state
- next open task
