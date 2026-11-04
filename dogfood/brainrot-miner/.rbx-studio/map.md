# Project map (files, 7 scripts, 884 lines) hash d614e3caf85f5475
Built by rbx-map. Read this before opening scripts; open only the files a task needs. Rebuild: node "C:/Users/nsidi/Desktop/VibeCode/Roblox Workfloq/studio/rbx-studio/tools/rbx-map.js".

## Remotes (name: fired at -> handled at)
- BuyUpgrade: src/client/Hud.client.luau:129 -> src/server/Game.server.luau:135(args)
- Mine: src/client/Hud.client.luau:201 -> src/server/Game.server.luau:122
- Rebirth: src/client/Hud.client.luau:148 -> src/server/Game.server.luau:160
- State: src/server/Game.server.luau:51 -> src/client/Hud.client.luau:235

## DataStore calls
- src/server/Data.luau: GetDataStore@27, UpdateAsync@67, UpdateAsync@110

## Purchases
- src/server/Game.server.luau: ProcessReceipt@179

## Infinite loops (while true)
- src/client/Hud.client.luau: 251
- src/server/Data.luau: 144
- src/server/Game.server.luau: 205

## Scripts
- src/client/Hud.client.luau (StarterPlayer.StarterPlayerScripts.Client.Hud): client, 258 lines, strict, 5 connects
  requires: Config, Economy, Remotes
  services: Players, ReplicatedStorage, GuiService, TweenService
- src/server/Data.luau (ServerScriptService.Server.Data): module, 168 lines, strict, 0 connects
  exports: load:57, get:94, save:98, release:124, hasPurchase:130, recordPurchase:134, all:138
  services: DataStoreService, RunService, Players
- src/server/Game.server.luau (ServerScriptService.Server.Game): server, 223 lines, strict, 5 connects
  requires: Config, Economy, Remotes, Data
  services: Players, ReplicatedStorage, MarketplaceService
- src/shared/Config.luau (ReplicatedStorage.Shared.Config): module, 44 lines, strict, 0 connects
- src/shared/Economy.luau (ReplicatedStorage.Shared.Economy): module, 84 lines, strict, 0 connects
  exports: costOf:15, bulkCost:20, perClick:30, perSecond:40, multiplier:50, rebirthGain:54, offlineEarnings:61, format:67
- src/shared/Remotes.luau (ReplicatedStorage.Shared.Remotes): module, 31 lines, strict, 0 connects
  exports: folder:22, get:26
  services: ReplicatedStorage
- tests/economy.spec.luau: module, 76 lines, not strict, 0 connects
  requires: ../src/shared/Economy
