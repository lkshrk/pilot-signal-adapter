# pilot-signal-adapter

Go client for [signal-cli-rest-api](https://github.com/bbernhard/signal-cli-rest-api),
providing the transport and message model behind a Signal comms adapter for the
[pilot](https://github.com/lkshrk/pilot) agent daemon.

## Why a separate module

Pilot has no plugin seam — no `go-plugin`, no adapter registry, and its adapters live
under `internal/`, which Go forbids external modules from importing. So the dependency
runs one way:

```
github.com/lkshrk/pilot-signal-adapter    ← this module: transport, message model, tests
          ↑ imported by
fork internal/adapters/signalcli/         ← thin shim: comms.Messenger + handler
```

Keeping the bulk here has a concrete payoff: the fork rebases against upstream roughly
daily, and every fork-local file is recurring conflict surface. Code in this module is
not. It is also the only layer testable without a cluster.

**The boundary is enforced, not remembered**, in three layers: Go itself refuses
`internal/` imports from outside pilot, `depguard` rejects a pilot import should pilot
ever reach `go.mod`, and CI fails if pilot appears anywhere in the module graph.

## Status

Early. The envelope model and frame-kind discrimination are implemented against
captured fixtures; transport and send paths are not yet written. Tracked in Linear
under [Signal CLI](https://linear.app/h-cloud/project/signal-cli-01bb0f6119b6).

## Development

```sh
make          # tidy-check, fmt-check, vet, lint, test — everything CI runs
make test     # race + shuffle + coverage
make fmt      # apply gofumpt/goimports
make help     # list targets
```

Requires Go (version pinned in `go.mod`) and
[golangci-lint](https://golangci-lint.run) v2.

### Go version policy

The `go` directive tracks **pilot's** Go version, not the newest release — pilot must be
able to import this module. Renovate is configured not to bump it.

## Receive semantics

Two behaviours of the upstream API shape the design, both confirmed against a live
deployment rather than inferred from docs:

- **Most frames are not user messages.** `typingMessage` and `receiptMessage` dominate
  the stream. Select `KindData` explicitly; treating every frame as a command misfires.
- **Messages are dropped while no websocket client is attached.** They are not queued
  and replayed on reconnect, so every restart is a loss window. `RECEIVE_WEBHOOK_URL`
  is the upstream's durable alternative and is under evaluation.
