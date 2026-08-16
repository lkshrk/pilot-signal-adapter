// Package signalcli is a client for bbernhard/signal-cli-rest-api, providing the
// transport and message model a pilot comms adapter needs.
//
// This module must never import github.com/qf-studio/pilot: pilot's adapters live
// under internal/, so the dependency only runs one way — the pilot fork's
// internal/adapters/signalcli shim imports this package, not the reverse.
package signalcli
