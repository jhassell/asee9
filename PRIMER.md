# What you are actually using

### A ten-minute primer

You do not need this to do the exercises. Read it if you want to know what the
thing on your screen actually is. Some of the vocabulary is recent and still
unsettled; **no prior familiarity is assumed**, and where the field is still
arguing, this primer says so rather than picking a winner.

## The short version

- There is no agreed definition of "agent." Ours: it chooses an action, uses a
  tool, observes the result, and continues without waiting for you.
- You will recognise it when it **runs a command, reads what came back, and
  picks its next step, without you telling it to.**
- Working model: **Agent ≈ Model + Harness.** The harness is the engineered
  runtime: tools, environment, evidence, state, loop, permissions.
- The engineering problem is **deciding which keys it gets**: what authority,
  what boundary, whose approval, what record.
- **A harness bounds the evidence available to the agent.** Prompting cannot
  manufacture a source the system cannot reach.
- Therefore **check its evidence, not its summary**: the files it opened and the
  commands it ran. That is the Check move in `exercises/hands-on.md`.

The rest of this page explains each line.

## The Intent Gap

Agents act on our behalf, but they do not share the intent we carry in our
heads. There is always a gap between what we intend and what the system
actually does. In the hands-on exercise you see it when you compare what the
agent made with what you pictured, when you check what it actually did, and when
you give it a rule. You engineer around the gap; nothing closes it. Engineering
means making it visible, testable, and recoverable, and students learn that by
building real things with agents.

---

## 1. What is an agent?

There is **no single accepted boundary** around the word. Vendors, researchers
and practitioners draw it in different places, and the disagreement is real
rather than a failure of anyone's homework. So here is the **operational
definition this repository uses**:

> **An agent is a model that can choose an action, use a tool, observe the
> result, and decide what to do next, without waiting for another instruction
> from you.**

That is a definition you can hold a system against, which is what an
engineering definition is for.

### How it differs from a chatbot

The familiar experience is turn-taking: you type, it replies, you read, you
decide, you type again. Every decision about *what to do next* is yours. The
model is an advisor that cannot act.

An agent is given a goal instead of a question, and then runs a loop:

> decide what to do next → do it → look at what happened → decide again

**The clearest way to recognise one** is this specific behaviour:

> *It runs a command, reads what came back, and picks its next step, without
> you telling it to.*

Sometimes that next step is a different approach after something fails. Often
you will see it list, search and read files, then write its answer in prose; it
may write no file or program at all.

A caution about easy tests: "does it produce text, or files?" will not separate
them. A chat interface can run code behind the scenes; an agent can work for two
minutes and hand you nothing but a paragraph. **Chat is an interface. Agency is
a behaviour.** Judge the behaviour.

What an agent is not:

- It is not a fixed pipeline: a script runs the same steps every time; an agent
  picks its next step, so it can pick a wrong one.
- It is not judgment you can stop checking. And it is the wrong tool when a
  fixed script would do, when an action cannot be undone and no person approves
  it first, or when nothing outside it can check the result.

## 2. What is an agentic system?

Not just the model. The whole assembly:

| Part | What it is |
|---|---|
| **The model** | Reads context, decides what to do next. It has no hands. |
| **Tools** | The hands. Read a file, write a file, run a command, search. |
| **An environment** | A computer, a folder, a sandbox: where the actions land. |
| **State / memory** | What it carries between steps, and what it forgets. |
| **The loop** | Runs decide → act → observe repeatedly, and decides when to stop. |
| **Permissions and oversight** | What it may not do, and what needs your approval. |

Everything except the first row is **not the model**.

## 3. The harness

A useful shorthand, **a working model**, not a standard anyone is obliged to
accept:

> ## Agent ≈ Model + Harness

The **harness** is the engineered runtime around the model: the tools it can
call, the environment it acts in, the evidence it can reach, the state it keeps,
the loop, the permissions and the oversight. A raw model does nothing at all. A
harness is what makes it an agent.

### The delegation problem

Here, the harness gives the model **tool-mediated access to a computer**: within
the permissions we grant, it can read files, write files and run commands, and
what it changes stays changed. That is a real transfer of authority. So:

> **The engineering problem is deciding which keys it gets**: what authority,
> within what boundary, what needs human approval, and what record it leaves.

That is requirements, threat modelling, containment and auditability: an
engineer's home ground.

In this repository, the agent runs as you inside your Codespace. It can reach
anything you can reach there, including the saved model key. It has been told
not to print it; that is a rule, not a wall. The credit limit on the key is the
wall.

One action is kept for a person: publishing the website to a permanent address.
The agent is told never to run `publish-site.sh`, and the script asks a yes/no
question before it publishes. That is an **approval gate**, one of the "keys"
above that you decide not to hand over.

### A discipline being named right now

**Mitchell Hashimoto used the phrase "harness engineering" on 5 February 2026**,
for the habit of engineering a permanent fix into an agent's environment each
time it makes a mistake. **LangChain published "Anatomy of an Agent Harness" on
10 March 2026**, the source of the `Agent = Model + Harness` shorthand. By
**June 2026** researchers were asking what makes a harness a harness. The honest
description is **an emerging engineering practice**: not an established field,
and not one nobody has noticed either.

### Why checks matter

> ## A harness bounds the evidence available to the agent.

Not what it *knows*: a model knows a great deal from training and can spot a
contradiction placed in front of it. What the harness bounds is **which evidence
the agent can obtain, and which actions it can take, during this task.**

Inside a closed folder, an agent can tell you what the folder says, and whether
the folder contradicts itself. It **cannot independently establish an external
fact that requires evidence it cannot reach**, and better prompting does not fix
that. So, inside that boundary, the rule everything here is built on:

> **Check its evidence, not its summary.**

What you trust is the command on screen and what it printed (the files it
opened, the commands it ran), never "all good." And some things no check inside
the folder can prove, such as whether the topic it chose is worth a paper.
**That part stays with human judgment.**

## 4. What is GitHub? What is a Codespace?

**GitHub** stores project files along with a version history of committed
changes. The system underneath is called *git*. What engineers get from it is
that changes are attributable and reversible. Two honest caveats: history *can*
be rewritten, and a change records *why* only insofar as somebody wrote a useful
message. A **fork** is your own copy of someone else's repository.

**A Codespace** is a disposable cloud development environment: a computer GitHub
builds for you and shows you in a browser tab, with an editor, a terminal, and
whatever software the project specified in advance. You can stop and restart it,
and inactive ones are deleted automatically after a retention period (30 days by
default). Delete yours when you are done.

Three reasons this repository uses one:

1. **You install nothing** on your laptop.
2. **Everyone is identical.** A class of thirty gets one environment, pinned to
   tested versions, instead of thirty laptops.
3. **It is disposable.** Something given tool-mediated access to a computer
   should be given a computer you are willing to throw away. Same instinct as
   commissioning a new controller on a rig rather than on the line.

## 5. What is OpenClaw?

OpenClaw is a harness. It runs in the terminal (here it opens by itself when
setup finishes), and it connects a model to a set of tools and a working folder.
Its public repository dates from **24 November 2025**; the `openclaw` package
was first published at the end of **January 2026**.

A release published on **8 September 2026** raised the required version of an
underlying runtime and broke this environment's setup outright. It was found,
diagnosed and pinned, so your environment is frozen to one tested version.
**That is a harness-engineering decision too.**

### Model or harness?

- **Models** are Claude, GPT, Gemini. Anthropic, OpenAI and Google build these.
- **Harnesses** are Claude Code, Codex CLI, OpenClaw: equipment *around* a model.

They mix. Anthropic ships a harness around its own models; OpenAI ships Codex;
OpenClaw is independent and can be pointed at somebody else's model. Here it is
pointed at a Gemini-family model through OpenRouter, a switchboard that lets one
program reach many providers with one key. So when a vendor says its product
"now has agentic capabilities," it means **they now ship the harness too**. Same
architecture. Different supplier.

## 6. A short timeline

| When | What |
|---|---|
| **24 Feb 2025** | Claude Code, limited research preview |
| **16 Apr 2025** | OpenAI Codex CLI |
| **22 May 2025** | Claude Code generally available |
| **25 Jun 2025** | Google Gemini CLI |
| **24 Nov 2025** | The repository that becomes OpenClaw appears |
| **late Jan 2026** | The `openclaw` package is published, renaming existing work |
| **5 Feb 2026** | "Harness engineering" used as a phrase |
| **10 Mar 2026** | `Agent = Model + Harness` published as a shorthand |
| **19 May 2026** | Google announces the move to Antigravity CLI |
| **18 Jun 2026** | Gemini CLI ends for consumer Google accounts; enterprise and API-key access continue |
| **Jun 2026** | Researchers begin asking what makes a harness a harness |
| **8 Sep 2026** | An OpenClaw release breaks this environment's setup; versions are pinned |

Most of the engineering practice around these tools has not been written yet.

## 7. Where this might go, and what it is not

*This section is argument, not fact.*

Today a harness mediates a model's access to a computer. The interesting
question is what happens as the same pattern reaches instruments, vehicles,
buildings, fabrication lines and field robots. Anthropic has begun describing a
standard intended to let agents operate physical devices, so the direction is
not fantasy.

**But be careful with the analogy.** Physical systems are not "the same
architecture with different hands." They add real-time constraints, continuous
dynamics, sensor uncertainty, actuator limits, interlocks, irreversible
consequences, certification regimes, stability and fault tolerance. Robotics,
controls and safety engineering have **mature theory** for problems agent
developers are only beginning to meet.

What is genuinely interesting is that the same *questions* recur (authority,
actuation limits, observability, verification, safe failure) and that the
people who already know how to answer them for physical systems are mostly not
the people currently building agent harnesses.

Many of them teach engineering.
