# Security Remote Audit

All client/server remotes are declared in `src/shared/remotes/RemoteDefinitions.luau`.
The client is considered untrusted.

| Remote | Authority | Required server checks |
|---|---|---|
| RequestJobOffers | Server | rate limit, loaded profile |
| AcceptJob | Server | offer ID, TTL, eligibility, tool tier, world anchor |
| AbandonJob | Server | active ownership |
| PerformJobAction | Server | instance ID, stage order, action, timing, spatial proximity, duplicate guard |
| UseInstantJobFinish | Server | active job, consumable count, spatial proximity |
| Create/Join/LeaveCoopContract | Server | eligibility, capacity, ownership/state |
| PerformCoopAction | Server | participant, stage, timing, spatial proximity |
| PurchaseTool | Server | ID, level, ownership, funds |
| EquipTool | Server | ownership |
| PurchaseVehicle | Server | ID, level, ownership, funds |
| SelectVehicle/SpawnVehicle | Server | ownership/selected state |
| PurchaseUpgrade | Server | known upgrade kind, funds, max tier |
| HireEmployee | Server | ID, slot capacity, workshop/company gates, funds |
| ClaimDailyReward | Server | day boundary, prior claim |
| RequestDailyJobs | Server | deterministic server selection |
| ClaimAchievement | Server | server metric condition, not already claimed |
| RequestPrestige | Server | preview nonce, expiry, eligibility |
| PromptGamePass/Product | Server | allowlisted config key and configured Roblox ID |
| StateUpdated | Server -> client only | never accepted from client |

## P14 validation policy
- Rate limits are centralized in SecurityService for value-bearing feature remotes.
- Job and co-op flows additionally maintain local defensive limits.
- Invalid/spam requests are rejected and logged.
- Auto-kick threshold is intentionally high to avoid punishing latency/client bugs.
- Economy, XP, ownership, purchase grants and completion state are never accepted as client-provided values.

## Studio exploit verification still required
Real multi-client/executor-style verification requires Roblox Studio/runtime access and is tracked separately in the ledger.
