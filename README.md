# asee9: a working AI agent in a browser tab

This repository gives you a working AI agent inside a GitHub Codespace: the
agent program [OpenClaw](https://www.npmjs.com/package/openclaw), connected to
Gemini 3.8 Flash through OpenRouter with your own key, plus short exercises, a
folder that becomes a public website, and assignment and rubric templates. It
is for engineering professors and their students, and nothing is installed on
your laptop.

New to words like agent, harness or Codespace? Read [`PRIMER.md`](PRIMER.md)
first. It takes ten minutes.

---

## Use it in five steps

You need a free GitHub account, an OpenRouter account with a few dollars of
credit, and a laptop with a modern browser.

1. **Get an OpenRouter key with a small credit limit.**
   Sign in at <https://openrouter.ai>, add a little credit, open **Keys**
   (<https://openrouter.ai/settings/keys>) and create a key. **Set a credit
   limit, such as $5.** Copy the key. It starts with `sk-or-`. Treat it like a
   password.
2. **Open a Codespace.** Pick one:
   - **To try it:** go to **`codespaces.new/jhassell/asee9`** and click
     **Create codespace**. This runs on the original repository. You can work,
     but you cannot save changes back to it.
   - **For your own classwork (what you want for a course):** on
     <https://github.com/jhassell/asee9> click **Fork**, then **Create fork**.
     On your fork click the green **Code** button, the **Codespaces** tab, then
     **Create codespace on main**. The **first** Codespace on a new fork takes a
     few minutes to build, because it installs the agent, and you watch a build
     log while it does. Later ones are faster, and faster still if you turn on a
     prebuild: see [Make your Codespace start
     faster](#make-your-codespace-start-faster).

   ![The Code button's Codespaces tab](docs/figures/01-code-menu.svg)

3. **Click Trust Folder & Continue** when VS Code asks whether you trust the
   authors of the files in this folder. Until you click it, no terminal can start.

   ![Click Trust Folder and Continue](docs/screenshots/A-trust-folder-and-continue.png)

4. **Paste the key when the terminal asks.** Setup starts by itself in the
   terminal at the bottom. The key **does not show** as you paste; that is on
   purpose. Press Enter. The terminal starts small: enlarge it with the square
   **Maximize Panel** button just left of the **X** at its top right.
5. **The agent opens.** Setup prints **READY** and opens the agent: a bordered
   box with a cursor. Click inside the terminal and type there. Enter sends.

**When you finish:** stop or delete the Codespace at
<https://github.com/codespaces> (the **…** menu beside it). A stopped Codespace
keeps your files. A deleted one is gone.

If you only see a line ending in `$`, type `bash setup.sh` and press Enter.

---

## Try it

**Before you add any document:** what the agent reads is sent to OpenRouter and
the model's provider. Use only material you would be comfortable sending to an
outside company. No student records or student work, no confidential or
unpublished manuscripts, nothing under review, NDA or export control.

### The three typed lines, on your own files

Drag a few of your own documents (published papers, a syllabus, public course
pages) onto the `mine/` folder in the file list (setup creates `mine/` just
before READY; it is gitignored, so nothing in it is ever committed).
Then follow [`exercises/hands-on.md`](exercises/hands-on.md): you type a goal,
a check and a rule, and watch where the agent does something other than what
you meant. A check line in that style:

```
Which claims come from no file in mine?
```

### A small website

Follow [`exercises/site-tutor.md`](exercises/site-tutor.md). The agent builds a
teaching site in `site/`, then you check its facts. For example:

```
Build site/ teaching beam deflection basics.
```

Each step the agent takes shows as an **Exec** card above its reply: the files it
opened and the commands it ran. Check those, not its summary.

All exercises and templates: [`exercises/README.md`](exercises/README.md).

---

## Your public website

- Anything in `site/` is served as a website on port **8000** while the
  Codespace runs.
- **The address** is printed at READY as *Your public site*. It looks like
  `https://<your-codespace-name>-8000.app.github.dev`. If READY says *Your
  site … the Ports tab* instead, the address is in the **Ports** tab beside the
  terminal, on the row for port **8000**.
- **It is public if READY printed an address.** Then anyone with the link can
  open it while the Codespace runs, and it goes offline when the Codespace
  stops. If READY pointed you at the Ports tab instead, making the port public
  did not succeed (some organizations forbid it) and the site opens only for
  you. `~/.agentic-classroom-site.log` records what happened. Either way, treat
  `site/` as public: it takes one click in the Ports tab to make it so.
- **Check it before you share it.** Open a second terminal (the **+** on the
  terminal panel) and type:

  ```
  python3 .devcontainer/site-check.py
  ```

  It reads every text file in `site/`, whatever it is called, and fails on
  key-like strings, on a symlink, on a local link that is missing or points
  outside `site/`, and on a missing `index.html`. It warns about `.edu` email
  addresses, numbers shaped like student IDs and 64-character hex strings. It
  cannot tell you whether a fact is true.
- `site/` is never committed to git. To keep a site, download the folder
  (right-click it in the file list) or publish it with Netlify, below.

---

## A permanent website with Netlify (optional)

The Codespace address dies when the Codespace stops. Netlify is a web host that
can keep a copy of `site/` at a permanent address. It has a free tier.

**1. Get a Netlify personal access token.** A personal access token is a
password for programs: it lets a script act on your Netlify account. Create a
Netlify account, then in the Netlify app go to **User settings** →
**Applications** → **Personal access tokens** → **New access token**. Give it
an expiry date. Copy it.

**2. Give it to the Codespace.** Pick one:

- **As a Codespaces secret (nothing to paste each time):** on github.com, your
  profile picture → **Settings** → **Codespaces** → **Secrets** → **New
  secret**. Name `NETLIFY_AUTH_TOKEN`, value the token, and under
  **Repository access** choose your fork. A running Codespace sees a new secret
  only after you stop and restart it.
- **Paste it when asked.** The script asks for it (it does not show) and offers
  to save it at `~/.config/netlify/token`, outside the repository.

**3. Publish.** In a terminal (not in the agent), type:

```
bash publish-site.sh
```

It runs the site check first and stops if the check fails. It shows how many
files `site/` holds and their size, then asks:

> Publish site/ to a permanent public Netlify URL? Anyone with the link can see it. [y/N]

Anything but `y` or `yes` stops. On `y` it uploads the folder and prints the
permanent address.

**4. Keep the same address next time.** The first publish creates a new Netlify
site and prints its site id. Save that id as a second Codespaces secret named
`NETLIFY_SITE_ID`. Without it, a new Codespace would create a new site with a
new address.

Options: `--name my-beam-tutor` picks the site's name on the first publish,
`--yes` skips the question (for automation only), `--forget-token` deletes the
saved token and stops without publishing (run the script again to publish).

**The agent is told never to publish.** Publishing is your decision, made at the
`[y/N]` question. See the approval-gate lesson in
[`exercises/site-tutor.md`](exercises/site-tutor.md).

---

## Using it with students

- **Each student forks** this repository (or your adapted fork) and creates their
  own Codespace. The Codespace time comes out of each student's own GitHub
  allowance, not yours.
- **Keys, two options.**
  - *Each student uses their own OpenRouter key* with a small credit limit.
  - *You issue each student a separate key* from your OpenRouter account, each
    with its own small limit (for example $2-5). **Never give a class one shared
    key:** one runaway agent would spend everyone's budget, and you could not
    tell who did.
- **Codespaces secrets save typing.** A student adds a secret named
  `OPENROUTER_API_KEY` at github.com → **Settings** → **Codespaces** →
  **Secrets**, with **Repository access** set to their fork, *before* creating
  the Codespace. Setup then uses it and asks nothing. Pasting at the prompt also
  works. An optional secret `OPENCLAW_MODEL` picks a different model.
- **Cost.** Roughly $0.10-0.50 of OpenRouter credit per agent task on Gemini 3.8
  Flash (a few minutes of the agent reading files and writing a result). Longer
  tasks cost more. Prices change. Each key's spend is at
  <https://openrouter.ai/activity>. Avoid models whose names end in `:free`: they
  are rate-limited per account and an agent hits the limit quickly.
- **Codespaces quota.** Personal GitHub accounts get a free monthly allowance of
  Codespaces compute, counted in core-hours, plus storage. A 4-core machine uses
  the hours twice as fast as a 2-core one. Stopped Codespaces still use storage.
  Check GitHub's current allowance and your usage at
  <https://github.com/settings/billing>.
- **Rules to give students:** what documents may be given to the agent (above),
  that `site/` is public while the Codespace runs, and that the agent never
  publishes.
- **Templates:** [`starter-assignment.md`](exercises/starter-assignment.md)
  (delegate, verify, document), [`starter-build-agent.md`](exercises/starter-build-agent.md)
  (students build a small agent), [`rubric-template.md`](exercises/rubric-template.md),
  and [`what-went-wrong.md`](exercises/what-went-wrong.md), a candid list from
  the course this came from.
- Forks do not update themselves when you change your copy. Settle your version
  before the term starts.

**What the agent can reach.** The agent runs as you inside the Codespace, so it
can read any file you can. Setup does what it can about that: it starts the
agent with `OPENROUTER_API_KEY`, `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID` and the
Codespace's GitHub token removed from its environment, so a stray
`bash publish-site.sh --yes` finds no token and `gh` finds no login. What it
cannot do is hide the files: `~/.openclaw/openclaw.json` holds the key and
`~/.config/netlify/token` holds the Netlify token if you saved it. The agent is
told never to read or print either, but a rule is not a wall. The credit limit
on the key is the wall. If the Netlify token matters more than the convenience,
paste it when you publish and answer *no* to saving it.

---

## Troubleshooting

| What you see | What to do |
|---|---|
| **The key was not accepted** | Copy the whole key again from <https://openrouter.ai/settings/keys> (it starts `sk-or-`), or create a new one. Then type `bash setup.sh`. A wrong key in a Codespaces secret: fix the secret, then stop and restart the Codespace. |
| **Only a line ending in `$`**; setup never started | Type `bash setup.sh`, press Enter. |
| **A `$` line after the agent was running** | The agent closed. Type `openclaw chat`, press Enter. |
| **"another OpenClaw process owns gateway-lifecycle"** | A second `openclaw chat` fails while one is open. Go back to the first terminal: the list of terminals at the right edge of the panel. A second terminal is fine for other commands. |
| **Setup says it is already running in another terminal** | Switch to the first terminal in that list. |
| **The website address does not load** | Open the **Ports** tab and find port **8000**. If its visibility says **Private**, right-click it → **Port Visibility** → **Public** (some organizations forbid this). If port 8000 is missing, stop and restart the Codespace. `~/.agentic-classroom-site.log` records what the site script did. Refresh after the agent writes files. |
| **Out of credit** (`Agent couldn't generate a response`, HTTP 402) | Check the key's limit and your balance at <https://openrouter.ai/settings/keys>. Raise the limit or add credit, then type the same line again. |
| **`bash publish-site.sh` reports 401** | Netlify refused the token: it expired, was deleted or was mistyped. Create a new one, then either update the `NETLIFY_AUTH_TOKEN` secret (and restart the Codespace), or run `bash publish-site.sh --forget-token` — which only deletes the saved token — and then `bash publish-site.sh` again to paste the new one. |
| Want a different OpenRouter key | `bash setup.sh --reset-key` forgets the saved key and asks again. A Codespaces secret always wins: change the secret instead. |
| Ctrl+C does not stop the agent | That is expected. Let it finish. If it is stuck for many minutes, close that terminal (trash-can icon), open a new one (**+**), type `openclaw chat`. |
| The terminal shrank when you opened a file | Click the square **Maximize Panel** button just left of the **X**. |
| No terminal at all | The **+** on the terminal panel. If the panel is gone: the **☰** menu at the top left → **Terminal** → **New Terminal**. |
| Anything else | Delete the Codespace and create a fresh one. A fresh container is the first diagnostic step. |

![The ☰ menu, Terminal, New Terminal](docs/screenshots/F-menu-terminal-new-terminal.png)

---

## How this repository was built

This part is for anyone who wants to understand, adapt or rebuild the
environment. Every script named here is in the repository and has comments at
the top.

### a. The first spin-up, in order

**1. GitHub creates the container.** When you click Create codespace, GitHub
reads `.devcontainer/devcontainer.json` and:

1. pulls the base image `mcr.microsoft.com/devcontainers/python:3.12`, pinned by
   digest;
2. adds three dev container *features* (small, versioned install recipes): Node
   22.23.2, an SSH server (so `gh codespace ssh` works for testing), and the
   GitHub CLI `gh` 2.100.0;
3. runs the **onCreateCommand**, `bash .devcontainer/postCreate.sh`. It installs
   OpenClaw and the Python libraries, adds one line to `~/.bashrc`, and ends
   with a **GATE**: if a pinned tool is missing, it fails the command loudly
   instead of handing you a broken Codespace. It never asks for or reads a key.
   Its output is in the Codespace creation log.

**2. VS Code attaches.** The browser editor connects to the container and applies
`.vscode/settings.json`. Those settings hide VS Code's own built-in AI chat panel
(so nobody types into the wrong agent), open every file in its own tab, and turn
off a terminal relaunch that caused a race right after Trust (see step 4).

**3. Trust.** VS Code opens the folder in *Restricted Mode* and asks whether you
trust the authors. Nothing in the terminal can run until you click **Trust Folder
& Continue**. That is why nothing starts earlier.

**4. The first terminal.** After Trust, VS Code opens a terminal, which starts
an interactive `bash`, which reads `~/.bashrc`. The line postCreate.sh added
there is guarded:

```
if [ -f /workspaces/asee9/.devcontainer/autostart.sh ]; then . /workspaces/asee9/.devcontainer/autostart.sh; fi  # agentic-classroom-autostart
```

The path is the repository folder, so it reads `/workspaces/<your fork's name>`
on a fork. The trailing `# agentic-classroom-autostart` comment is how the
scripts find their own line again: `grep agentic-classroom-autostart ~/.bashrc`.

The terminal starts small. The `workbench.panel.opensMaximized` setting applies
only when the panel is reopened, so the README points at the Maximize Panel
button instead.

**5. autostart.sh.** It is *sourced*, not run, so it is written never to exit
the shell and to print nothing unless it starts setup. In order:

1. It returns at once unless the shell is interactive, has a terminal on stdin
   and stdout, and `TERM_PROGRAM` is `vscode` or `codespaces`. This keeps VS
   Code's hidden environment probe, `gh codespace ssh`, and the container build
   from ever starting setup.
2. In a Codespace it starts `.devcontainer/site-public.sh` detached, in the
   background. This happens before the remaining guards, so the website also
   comes back after a Codespace restart.
3. It stops if setup has already succeeded once (a ready marker file in your
   home folder) or autostart has been switched off with an environment variable.
4. It takes a **run-once lock**: a directory holding a process id and that
   process's start time. A second terminal finds the lock held and gets a plain
   prompt. A lock left by a dead process is taken over under a short mutex, so
   two terminals cannot both take it. A lock held by a live process is checked
   again every 0.5 s for about 5 s, for the case where VS Code relaunches the
   first terminal just after Trust.
5. It runs `bash setup.sh`. There is no date cutoff.

**6. setup.sh, step by step.**

1. Claims the lock (or tells you setup is already running in another terminal),
   re-adds the `~/.bashrc` line if it is missing, and — in a Codespace — starts
   `site-public.sh` in the background as well, in case autostart did not.
2. Checks the tools. If OpenClaw or a Python library is missing (a failed
   container build), it installs the pinned version before asking for a key, so
   a container problem shows up first.
3. Picks the model: `OPENCLAW_MODEL` if set, otherwise
   `openrouter/google/gemini-3.8-flash`.
4. Finds the key, first match wins:
   1. a Codespaces secret `OPENROUTER_API_KEY` (read, then removed from the
      environment of everything setup starts);
   2. the key saved by an earlier run (skipped by `--reset-key`);
   3. a hidden prompt (`read -rs`), three tries. It says how many characters
      arrived. If you type `bash setup.sh` at the prompt by mistake, it tells you
      setup is already running and does not count the try.
5. Validates the key **without spending credit**: a `GET` to
   `https://openrouter.ai/api/v1/key`. The key goes to `curl` in a config file on
   stdin, never on a command line, where other processes could see it. 200 means
   good; 401/403 means refused; 402 means accepted but out of credit. It then
   prints the credit left on the key and warns if the key has **no limit**.
6. Writes `~/.openclaw/openclaw.json`, mode 600 in a mode 700 folder:
   - `env.vars.OPENROUTER_API_KEY`: the key;
   - `agents.defaults.model.primary`: the model, and
     `agents.defaults.modelPolicy.allow`: a list holding only that model;
   - `agents.defaults.cwd`: the repository folder, so files the agent writes
     appear in the editor;
   - `agents.defaults.verboseDefault`: `"on"`, so every tool call shows as an
     Exec card;
   - `memory.search.enabled`: `false` (otherwise it tries an embeddings
     service and logs errors every turn).
7. Runs `openclaw doctor --fix` to normalize anything version-specific (this is
   the slow part, often close to a minute).
8. Deletes OpenClaw's first-run `BOOTSTRAP.md` ritual (it would hijack your first
   prompt with "pick a name for me") and writes `~/.openclaw/workspace/IDENTITY.md`
   with fixed rules: `site/` is public; it is already served, so never start a
   server; never put keys, tokens or environment variables in `site/`; never run
   `gh`; never create a symlink in `site/`; never run the Netlify publish
   script, because publishing is the human's decision; run
   `python3 .devcontainer/site-check.py` before calling a site done; never print
   environment variables or the contents of `~/.openclaw`; never read or print
   `~/.config/netlify`.
   Then `openclaw config validate` confirms the agent accepts its configuration.
9. Creates `mine/`, writes the ready marker, releases the lock, and prints
   **READY** with the model, the folders, the public site address and the
   permanent-website command (`bash publish-site.sh`).
10. Opens `openclaw chat` with every credential taken out of its environment:
    `OPENROUTER_API_KEY`, `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID`, and the
    Codespace's `GITHUB_TOKEN`/`GH_TOKEN`. One consequence worth knowing: `gh`
    and `git push` do not work *from inside the agent*, which is what the "never
    run `gh`" rule asks for anyway. They work normally in a terminal of your
    own. When you leave the agent, the terminal lands at `$` with a reminder of
    how to reopen it. The whole run takes about a minute and a half.

### b. Loading OpenClaw

- `postCreate.sh` runs `npm install -g openclaw@2026.9.2`, up to three times with
  a 5-second pause, because a single npm hiccup should not cost you a rebuild.
  `setup.sh` repeats the install if the binary is missing.
- **Why `openclaw chat`, not bare `openclaw`:** bare `openclaw` opens an
  interface that expects a separate Gateway service on port 18789 and fails here.
  `openclaw chat` runs the agent embedded in the terminal. Its header reads
  `openclaw tui - local embedded`.
- **Verbose tool cards.** By default `openclaw chat` shows only your prompt and
  the final answer, which hides the agent's loop. `verboseDefault: "on"` shows
  each step as an Exec card ("show first 30 lines of…", "run python3 …").
- **Two facts found by testing:** Ctrl+C does not stop or exit `openclaw chat`,
  and a second `openclaw chat` fails while the first runs ("another OpenClaw
  process owns gateway-lifecycle").
- **The GATE** at the end of `postCreate.sh` checks the real thing, not a log
  line: `openclaw --version` must contain 2026.9.2, `pandas`, `matplotlib`,
  `markdown`, `jinja2`, `requests`, `bs4` and `feedparser` must import, and
  `gh --version` must contain 2.100.0. Otherwise it exits 1. In a prebuild, that
  keeps a broken image from being marked ready.
- For testing without the interface, `openclaw agent --local -m "your line"` runs
  one turn and prints the answer.

### c. Setting the versions

Everything is pinned. Where each pin lives:

| What | Version | Set in |
|---|---|---|
| Base image | `mcr.microsoft.com/devcontainers/python:3.12@sha256:7ae01dce85c08cc6b6ca411d7d7051eb100d2274ee2702120c11236692b6204f` | `devcontainer.json` `image` |
| Node feature | `ghcr.io/devcontainers/features/node:1.7.1`, Node `22.23.2` | `devcontainer.json` `features` |
| SSH feature | `ghcr.io/devcontainers/features/sshd:1.1.0` | `devcontainer.json` `features` |
| GitHub CLI feature | `ghcr.io/devcontainers/features/github-cli:1.1.2`, gh `2.100.0` | `devcontainer.json` `features`; checked by the GATE |
| OpenClaw | `2026.9.2` (npm) | `postCreate.sh` and `setup.sh` (keep them equal); checked by the GATE |
| pandas, matplotlib | `3.0.5`, `3.11.1` | `postCreate.sh`, `setup.sh` |
| markdown, jinja2, requests, beautifulsoup4, feedparser | `3.10.3`, `3.1.6`, `2.34.2`, `4.15.0`, `6.0.14` | `postCreate.sh`, `setup.sh` |
| Default model | `openrouter/google/gemini-3.8-flash` | `setup.sh`; override with `OPENCLAW_MODEL` |

**Why everything is pinned.** On 2026-09-08, `npm install -g openclaw@latest`
started pulling OpenClaw 2026.9.3. That release raised its Node requirement to
24.16.0 or later and its install hard-fails on Node 22. An environment that had
worked the day before broke overnight, with no change in this repository. A
floating version is a live dependency on someone else's release schedule.
**OpenClaw and the Node feature must move together:** OpenClaw 2026.9.3 or later
needs the Node feature at version 24 in the same change.

**How to upgrade safely.**

1. Change **one** pin (or one pair that must move together) on a branch.
2. Create a fresh Codespace from that branch (**Code** → **Codespaces** → **…**
   → **New with options**, choose the branch).
3. Read the creation log for `GATE PASSED`.
4. Run setup, run one exercise end to end, publish a test site.
5. Merge only after that works. Then delete the test Codespace.

### d. Using OpenRouter

- **What it is:** a switchboard. One account and one key reach models from many
  companies, and you pay per use. OpenClaw talks to it like any model provider.
- **The model id** is `openrouter/google/gemini-3.8-flash`: OpenClaw's provider
  prefix `openrouter/`, then OpenRouter's own id `google/gemini-3.8-flash`.
- **How the key reaches the agent:** from a Codespaces secret, a saved config or
  the prompt, into `env.vars` in `~/.openclaw/openclaw.json` (mode 600). It is
  never written into the repository, never logged, and never passed on a
  command line. `.gitignore` also excludes `*.key` and `.env` files.
- **`modelPolicy.allow`** lists only the chosen model, so the agent cannot
  quietly switch to a more expensive one.
- **Changing models:** set a Codespaces secret (or environment variable)
  `OPENCLAW_MODEL` to a full id such as `openrouter/<provider>/<model>`, restart
  the Codespace, and run `bash setup.sh`. Pick a model that supports tool
  calling. Test it on one exercise before giving it to a class.
- **Credit limits** are set per key at <https://openrouter.ai/settings/keys>.
  Setup warns if a key has none.
- **Checking spend:** <https://openrouter.ai/activity> lists every request with
  its model and cost.

### e. The public site

- **`.devcontainer/site-public.sh`** creates `site/` with a placeholder
  `index.html` if needed, starts `.devcontainer/site-server.py` detached if
  nothing is answering on port 8000, then runs
  `gh codespace ports visibility 8000:public -c "$CODESPACE_NAME"`, retrying for
  about a minute while the port registers. It saves the address and logs to
  `~/.agentic-classroom-site.log`. It is idempotent: running it twice does no
  harm. Outside a Codespace nothing starts it; run it yourself to serve `site/`
  on port 8000.
- **Why `gh` works without a login:** inside a Codespace, `gh` uses the
  Codespace's own GitHub token. If your organization forbids public ports, the
  port stays private, the log says so, and the site opens only for you.
- **Path safety.** `.devcontainer/site-server.py` serves `site/` and refuses
  any request whose real path lands outside it, so the repository, `mine/` and
  `~/.openclaw` stay unreachable even if something creates a symlink inside
  `site/`. Python's own `python3 -m http.server --directory site` is **not**
  used: it strips `..` from the URL but follows symlinks straight out of the
  folder. The agent's own gateway port (18789) is never made public.
- **Why not `postAttachCommand`.** It was tried. VS Code holds a
  postAttachCommand back until Trust, then runs it in a **new visible terminal
  that takes focus**, hiding the first terminal where setup is waiting for the
  key (measured 2026-09-14). So the site is started from `autostart.sh`, in the
  background, and again from `setup.sh`.
- **`.devcontainer/site-check.py`** fails (exit 1) on key-like strings or secret
  variable names (OpenRouter, GitHub, Netlify, AWS, private keys), on a symlink
  anywhere under `site/`, on local links or images pointing at missing files or
  at files outside `site/`, and on a missing `index.html`. It scans **every**
  readable text file, not only the ones with familiar extensions — a key in
  `.env` or `config.yaml` is as public as one in `index.html` — and skips files
  that look binary. It warns on `.edu` email addresses, 7-10 digit runs that
  look like student IDs, and 64-character hex strings (a checksum, or an older
  Netlify token). It prints file names and labels, never the matched text.
  `site/` is gitignored.

### f. Netlify publishing

`publish-site.sh` is run by a person, never by the agent. It uses Netlify's
REST API with `curl` and Python's standard library, so nothing extra is
installed.

1. **Check:** runs `python3 .devcontainer/site-check.py` and stops if it fails.
2. **Confirm:** shows the file count and size of `site/` and asks the `[y/N]`
   question. `--yes` skips it.
3. **Token:** `NETLIFY_AUTH_TOKEN` from a Codespaces secret, else
   `~/.config/netlify/token` (mode 600, outside the repository; a symlink or a
   file others can read is refused), else a hidden prompt, with an offer to save
   it there.
4. **Site id:** `NETLIFY_SITE_ID` (secret or environment), else the id saved at
   `~/.config/netlify/site-id-<repository folder name>`, else it creates a site with
   `POST https://api.netlify.com/api/v1/sites` (named by `--name` if given),
   saves the id, and tells you to store it as a Codespaces secret.
5. **Deploy:** zips `site/` with Python's `zipfile` and sends it with
   `POST https://api.netlify.com/api/v1/sites/<id>/deploys`,
   `Content-Type: application/zip`.
6. **Wait:** polls `GET https://api.netlify.com/api/v1/deploys/<deploy id>` until
   the state is `ready` or `error`, for about two minutes, then prints the
   permanent `https://` address.

**Token handling:** the token reaches `curl` only through a private config file
or stdin, never as a command-line argument and never in a log. Errors are
explained in plain words: 401/403 (token refused), 404 (wrong site id), 422
(Netlify rejected the request), and network failure.

### g. Rebuild it from scratch

1. Create a new **public** repository on GitHub (not a template repository:
   repositories made with "Use this template" do not inherit prebuilds).
2. Add these files:

   | File | What it does |
   |---|---|
   | `.devcontainer/devcontainer.json` | Pinned image and features, `onCreateCommand`, `hostRequirements`, port 8000 forwarded and labeled, no `postAttachCommand` |
   | `.devcontainer/postCreate.sh` | Installs OpenClaw and Python libraries with retries, adds the `~/.bashrc` line, GATE |
   | `.devcontainer/autostart.sh` | Sourced by `~/.bashrc`: starts the site server, then setup once, under a lock |
   | `.devcontainer/site-public.sh` | Starts the site server and makes port 8000 public |
   | `.devcontainer/site-server.py` | Serves only `site/`, refusing any path that resolves outside it |
   | `.devcontainer/site-check.py` | Checks `site/` before it is shared or published |
   | `.vscode/settings.json` | Hides the built-in AI chat panel, disables preview tabs, disables the terminal relaunch |
   | `setup.sh` | Key, validation, OpenClaw config, IDENTITY.md, READY, opens the agent |
   | `publish-site.sh` | Human-run Netlify publish |
   | `.gitignore` | Excludes `mine/`, `site/`, `.env*`, `*.key` |
   | `README.md`, `PRIMER.md`, `exercises/`, `docs/` | What people read |

3. Make the scripts executable and push:

   ```
   chmod +x setup.sh publish-site.sh .devcontainer/*.sh
   git add -A && git commit -m "Agent Codespace" && git push
   ```

4. Test in a fresh Codespace from the branch:
   1. Open the creation log (Command Palette → **Codespaces: View Creation
      Log**) and look for `GATE PASSED`.
   2. Click Trust. Setup must start by itself in the first terminal and ask for
      a key. Use a key with a $1-2 limit.
   3. At READY: `ls -l ~/.openclaw/openclaw.json` shows `-rw-------`, and the
      agent opens.
   4. Open a second terminal: it must give a plain prompt, not a second setup.
   5. Open the site address in a private browser window (signed out of GitHub):
      it must load.
   6. Type one exercise line to the agent and watch the Exec cards.
   7. Run `python3 .devcontainer/site-check.py`, then `bash publish-site.sh`
      against a throwaway Netlify site.
   8. `git status` must be clean: `mine/` and `site/` are ignored.
   9. Delete the Codespace.
5. **Testing over SSH** (`gh codespace ssh`): setup reads the key from
   `/dev/tty`, so run it under `script`, and autostart only fires when
   `TERM_PROGRAM` is `vscode`, so set that for the shell you are testing.

---

## Make your Codespace start faster

- **Enable a prebuild on your fork.** Forks do **not** inherit the original
  repository's prebuild. On your fork: **Settings** → **Codespaces** → **Set up
  prebuild**. Choose branch `main`, the `.devcontainer/devcontainer.json`
  configuration, trigger **Every push** (or **On configuration change** to run
  fewer), and the region nearest you. A prebuild runs `onCreateCommand` ahead of
  time and stores the result, so a new Codespace opens in seconds instead of
  minutes. Each prebuild takes around ten minutes after a push. Prebuilds use
  GitHub Actions minutes and storage, **billed to the account that owns the
  repository**. Check GitHub's current prices.
- **Why installs live in `onCreateCommand`.** GitHub runs `onCreateCommand` (and
  `updateContentCommand`) inside a prebuild. It never runs `postCreateCommand`
  there. Installs in `postCreateCommand` would run again for every Codespace.
- **A broken GATE hides the prebuild.** If a push makes `postCreate.sh` fail, the
  prebuild fails and new Codespaces fall back to a full build. After every push,
  open a fresh Codespace and confirm the tools are present at once.
- **Machine size.** `hostRequirements` in `devcontainer.json` sets the minimum
  cores. 4 cores shorten container creation and installs; 2 cores are enough
  for one person running one agent, because the agent mostly waits on the
  model. Quota is counted in core-hours, so 2 cores last twice as long.
- **Keep the image pinned by digest.** An unchanged digest lets GitHub and the
  prebuild reuse cached image layers. A moving tag can force a fresh pull.
- **Keep features few.** Each feature is an install step at build time.
- **Optional: publish a prebuilt image.** Build the dev container once with the
  [Dev Container CLI](https://github.com/devcontainers/cli)
  (`devcontainer build --image-name ghcr.io/<you>/asee9-dev:<tag> --push`),
  then point `image` at that tag, pinned by digest. To gain much, the installs
  must be in the image (a Dockerfile), not in `onCreateCommand`.
- **Stop instead of delete** between sessions. A stopped Codespace restarts in
  seconds with its files and its saved key. It uses storage quota, not compute.
- **Idle timeout and retention.** At <https://github.com/settings/codespaces>
  you can shorten the idle timeout (a Codespace stops itself after that many
  idle minutes) and the retention period (how long a stopped Codespace is kept
  before automatic deletion). Shorter saves quota.
- **Keep large downloads out of setup.** `setup.sh` runs after Trust, while a
  person waits. Anything big belongs in the image or `onCreateCommand`.

---

## Credits

Built for the ASEE Midwest Section 2026 workshop *From Chatbots to Agents: A
Hands-On Workshop on Teaching with Agentic AI*, by John Hassell, OU Polytechnic
Institute. At the workshop it was used with a private reading set that is not
included here. The environment was tested in fresh Codespaces and reviewed by
colleagues and several AI systems before release. No endorsement by ASEE is
implied.

## License

[Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/),
full text in [LICENSE](LICENSE). Copyright 2026 John Hassell. You may copy,
adapt and redistribute everything here, including for commercial use, as long
as you credit the source (for example "adapted from github.com/jhassell/asee9 by
John Hassell, CC BY 4.0") and note what you changed. The templates in
`exercises/` are meant to be copied, cut down and renamed for your own courses.
