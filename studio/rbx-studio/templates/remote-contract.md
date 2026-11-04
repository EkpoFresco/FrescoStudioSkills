# Remote contract: <system>

| Remote | Kind | Direction | Payload (types) | Validation (in order) | Rate limit | Max bytes |
|---|---|---|---|---|---|---|
| Buy | RemoteEvent | C->S | itemId: string | typeof, exists in catalog, owns currency, cooldown | 5/s burst 10 | <200 |

Kinds: RemoteEvent (reliable, ordered), UnreliableRemoteEvent (cosmetic, drops >1000 bytes), RemoteFunction (C->S only; never InvokeClient).
Server handler order: type -> finite -> range -> ownership -> distance -> cooldown -> rate limit -> act.
Shared definition lives in `src/shared/` (or ReplicatedStorage) so client and server use one source.
