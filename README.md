# Juntos

Group challenges with friends. Someone creates a room with a fixed-length challenge ("sleep before 11 for 21 days"), shares the link, and everyone checks in once a day. The point is company: seeing that the others are doing it too. There's no ranking, no points and no punishment for missing a day.

The interface is in Brazilian Portuguese.

## How it works

- **One room, one challenge.** Creating a challenge creates the room and an invite link (`/c/:token`).
- **Joining has zero friction.** Open the link, type your name, you're in. No account, no password. Identity is a permanent signed cookie.
- **Creating requires an account,** so a room is never lost when the creator switches devices. Login is passwordless: email → 6-digit code → session.
- **One-tap check-in.** "Fiz hoje ✓". Tap again to undo. You can also mark yesterday, but only yesterday, and only within the challenge period.
- **Everyone shares the same day 1,** so the room can say "we're all on day 8 of 21".
- **Live updates.** When someone checks in, the room updates for everyone else over Turbo Streams.

## How it's built

- **Rails 8.1** on Ruby 4.0, **SQLite**, **Hotwire** (Turbo + Stimulus), plain CSS
- **Solid Queue, Solid Cache and Solid Cable**
- 37signals-style: small RESTful controllers, server-rendered HTML, minimal state
- No denormalized counters. The grid, "who did it today" and progress are all queries over `checkins`, with a unique index on `(participant_id, date)` so a double tap can't create duplicates.
- "Today" is computed in one place (`Challenge#today`, America/Sao_Paulo), and validation, the grid and the day counter all derive from it. No cron jobs: the day rolls over on read.
- **Minitest** for models, controllers and system tests
- **CI on GitHub Actions:** Brakeman, bundler-audit, importmap audit, RuboCop, unit and system tests

## Running locally

```bash
bin/setup
bin/rails test
```

The design doc is in `docs/superpowers/specs/2026-08-18-juntos-design.md`.
