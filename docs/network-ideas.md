# Networked pets: ideas

Status: **ideas, not built yet.** This is the plan for pets on different machines noticing and
visiting each other over a private Tailscale tailnet.

The setup this was written for: a laptop with a GPU and a local Ollama model, and a small
Chromebook with no local model. Both run aeris-pet on the same tailnet, and more machines
may join later.

## Chosen for the first networked release

### 1. Border crossing (visiting)
The pet walks off the edge of one screen and, a moment later, walks in from the matching edge
of the other machine's screen. Dragging it to the edge and letting go sends it across too.
There is one pet at a time, so it really travels: the sending machine's screen stays empty
until the pet comes back, unless that machine has its own pet.

- Each machine has a fixed place in the row of screens, so the pet knows where it lands, e.g.
  laptop ← → Chromebook. The default is alphabetical by hostname; a small config can override it.
- The handoff carries the pet's state: kind (dragon or raven), direction, speed, mood, and the
  line it was saying. The receiver acknowledges the handoff. With no answer within 2 s, the
  pet turns around at the edge, so it is never lost.
- Optional: the pet comes home on its own after a while, or when the visited machine goes idle.

### 2. Letter relay (asking the laptop's Ollama from the Chromebook)
The Chromebook is too weak for a local model. Its pet can carry a question to the laptop: you
type a short question into the pet (a small input bubble), and the pet tucks a letter in its
beak and flies off the edge. The laptop's pet runs the question on its local Ollama model and
flies the answer back, and the answer is read out of a speech bubble on the Chromebook.

- Only machines that have Ollama answer letters. Each pet's presence message says whether it
  has a model, so the Chromebook knows where letters can go.
- Answers are kept short, a few sentences that fit a bubble. A longer answer opens in a small
  window or is copied on click.
- While a letter is out, the Chromebook's pet waits at the edge, looking out, until the answer
  comes back or a timeout passes.

### 3. Hibernation vigil (battery care, with a notification on the other machine)
When the Chromebook's battery runs low, the laptop's pet notices it in the presence messages.
It sits at the screen edge "keeping watch" and says soft things. The laptop also shows a
**desktop notification**: "tinyraven battery at 9%, plug it in." When the battery recovers,
both pets do a small celebration dance.

- This works both ways: any machine with a battery is watched by the others.
- The notification fires once per low-battery episode, not on every presence message.

### 4. Lost and found (going offline)
When a machine leaves the tailnet (sleep, shutdown, out of range), the other pet finds a
small keepsake at the bottom edge: a feather from the raven, a scale from the dragon. It stays
there while the friend is away. When the friend returns, the pet picks it up and "gives it
back," and the keepsake flies off the edge.

- Offline means no presence message for about 90 s, and the machine not online in
  `tailscale status --json`. Two missed beats alone are not enough; Wi-Fi blips are common.

### 5. Tailnet wave (a friend comes online, with a notification)
When a friend's pet appears on the tailnet, your pet turns toward the edge it would cross to
get there, waves, and says "hey, tinyraven is back!" A **desktop notification** says the same,
so you notice even when the pet is hidden behind a fullscreen window.

- The trigger is the friend's *pet* coming online, not just the machine, so it only fires when
  there is someone to play with.
- Rate limited: at most one wave per friend every 10 minutes, so reconnect flapping does not
  spam you.

### 6. File courier (handed to LocalSend)
Drop a file on the pet and it flies off with the file in its claws. The transfer itself is
**LocalSend**, which both machines already use; the pet does not move files with its own
protocol. On the receiving side, the friend's pet arrives carrying a parcel while LocalSend
asks you to accept, and it waves when the file has landed.

- LocalSend has an HTTP API on its own port (53317 by default). The pet asks LocalSend on
  the peer's Tailscale address to accept the file, so LocalSend's own accept prompt and
  settings stay in charge. Check the protocol version against the installed LocalSend first.
- If LocalSend is not running on the other side, the pet says so and drops the file back.

## Not doing (for now)

- **Ollama banter** (the pets chatting with each other through a model): the Chromebook has no
  model. If it comes back, the laptop would write both sides and send the lines over.
- **Clipboard carrier**, the overall tournament winner: it moves clipboard contents between
  machines. Worth doing later, but only behind a consent prompt (see Security).

## How the pets talk to each other

- **Transport:** each pet listens on its machine's Tailscale IP only (one TCP port, e.g.
  7787), never on 0.0.0.0. Messages are newline-delimited JSON.
- **Discovery:** `tailscale status --json` lists online peers. The pet tries the port on each
  one, and pets that answer are friends. No central server.
- **Presence:** every 30 s each pet sends `{kind, mood, mode, battery, on_screen, has_ollama,
  hostname, version}`. Visits, letters, keepsakes and waves are separate event messages.
- **Identity:** the receiver checks who is connecting with `tailscale whois <ip>` and only
  accepts machines owned by the same Tailscale user, or a list in the config.
- **Failure:** everything degrades to the single-machine pet. If the network is down, the pet
  turns around at the edge and the friend features stay quiet.

## Security

- Nothing listens outside the tailnet. Tailscale encrypts and authenticates the traffic, and
  the access rules decide which machines can reach the port.
- Pets only exchange pet state and short texts. Files go through LocalSend and its own accept
  prompt. Letters to Ollama are plain questions; the pet never runs commands it receives.
- Anything that would move user data (clipboard, files) shows a consent bubble with the
  sender's verified Tailscale name before anything happens.

## How these ideas were chosen

75 ideas were generated by Claude Haiku 5.5 (OpenRouter) from five angles: social play,
utility, poetic and strange, the network as the pets' world, and packages and permissions.
They were then ranked in a 7-round **Swiss tournament** (259 head-to-head matches). Two judges
voted on every match: TypeSafe **Jev** (`~typesafe/jev-latest`, OpenRouter decisions API,
probability of a win) and Google **Gemini 4 Hydrogen** (a single A/B vote). The A/B order was
randomised per match to cancel position bias, and each judge carries half the point.

The judges disagreed in a consistent way: Gemini favoured utility (clipboard, files, security
prompts) and Jev favoured social play (crumbs, waves, keepsakes). Border crossing was the idea
both rated well.

| # | Idea | Points (of 7) | Jev | Gemini |
|---|---|---|---|---|
| 1 | Clipboard Carrier | 5.12 | 3.3 | 7.0 |
| 2 | Border Crossing | 4.97 | 4.9 | 5.0 |
| 3 | Letter Relay | 4.91 | 3.8 | 6.0 |
| 4 | Hibernation Vigil | 4.71 | 4.4 | 5.0 |
| 5 | Lost-and-Found Drop | 4.66 | 5.3 | 4.0 |
| 6 | Tailnet Wave | 4.65 | 5.3 | 4.0 |
| 7 | Crumb Drop Transfer (file courier) | 4.61 | 2.2 | 7.0 |
| 8 | Shared Crumb Drop | 4.58 | 3.2 | 6.0 |
| 9 | Update Herald | 4.42 | 3.8 | 5.0 |
| 10 | Ollama Errand | 4.36 | 2.7 | 6.0 |
| 11 | Shared Notification Nest | 4.30 | 2.6 | 6.0 |
| 12 | Crumb Relay | 4.29 | 5.6 | 3.0 |
| 13 | Morning Mission Report | 4.23 | 3.5 | 5.0 |
| 14 | Latency Weather | 4.15 | 3.3 | 5.0 |
| 15 | Gatekeeper Prompt | 4.15 | 1.3 | 7.0 |
| 16 | Heartbeat Nest | 4.10 | 4.2 | 4.0 |
| 17 | Vanish Alarm | 4.08 | 5.1 | 3.0 |
| 18 | Sudo Sighting | 4.04 | 3.1 | 5.0 |
| 19 | Pacman Gossip | 4.03 | 5.0 | 3.0 |
| 20 | Crumb Diaspora | 4.02 | 5.0 | 3.0 |
| 21 | Ollama Banter | 4.00 | 4.0 | 4.0 |
| 22 | Low-Battery Lullaby | 3.96 | 3.9 | 4.0 |
| 23 | Migration Flight | 3.92 | 4.8 | 3.0 |
| 24 | Package Parity Check | 3.85 | 2.7 | 5.0 |
| 25 | Reboot Perch | 3.83 | 3.7 | 4.0 |

The full list of 75 ideas is in [network-ideas-all.md](network-ideas-all.md).
