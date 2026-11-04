# Debt

| ID | Item | File | Score | Status |
|---|---|---|---|---|
| TD-001 | Full-state State push to every player every 0.1 s (N3, ~10 pkts/s/player). Push on change, interpolate passive income on client | src/server/Game.server.luau (tick loop) | 3 x 3 / 2 = 4.5 | open |
| TD-002 | Data.release drops the profile even if the final save failed; no retry budget, lock only expires after 180 s | src/server/Data.luau:121 | 4 x 1 / 2 = 2 | open (data path, needs owner approval) |
| TD-003 | Data.load waits 2^attempt after the last failed try (8 s wasted), logs nil err when lock is held | src/server/Data.luau:85 | 1 x 4 / 1 = 1 | open |
| TD-004 | Config.Products.RockRush.productId = 0, receipt path never fires | src/shared/Config.luau:31 | 4 x 4 / 1 = 16 | open, set real id before launch |
| TD-005 | UpgradeDef type duplicated in Config.luau and Economy.luau | src/shared/Config.luau:4 | 1 x 4 / 1 = 1 | open |
| TD-006 | 4 selene fromScale/fromOffset warnings in label() calls | src/client/Hud.client.luau:66 | 1 x 4 / 1 = 1 | open |
| TD-007 | Two new Tweens per rock tap; reuse one tween pair | src/client/Hud.client.luau:193 | 1 x 4 / 2 = 2 | open, unmeasured (NOT ASSESSED) |
| TD-008 | Receipt: unknown ProductId returns NotProcessedYet forever (retry loop) | src/server/Game.server.luau (ProcessReceipt) | 2 x 3 / 1 = 6 | open |
