# Starter assignment: build a small agent

**A companion to `starter-assignment.md`, for a course where students write code.**

Built for the ASEE Midwest 2026 workshop *From Chatbots to Agents*.
John Hassell, OU Polytechnic Institute. Yours to edit.

---

## What this is

One assignment. One week. Students build a small agent, then prove what it did.
`starter-assignment.md` has students delegate a task and check the result;
this one has them build the loop themselves.

**Who it is for.** Junior standing. Python, HTTP and JSON, the command line,
and Git. No machine-learning math, no model training, no prior AI background.

**The thesis.** Build for reliability, not for a tour of capabilities. Getting
an agent to act is the easy part. Making it fail visibly, recover, and wait for
a person before it does something it cannot undo is the assignment. In
`hands-on.md` you find the **Intent Gap** from the outside, by directing an agent;
here students engineer around it from the inside, and the trace, the check, and
the gate are how they see where the agent did something other than what they
intended. The rule you typed in `hands-on.md` is the first line of a harness;
here students write the rest of it.

**Where it comes from, stated plainly.** It is adapted from the design of SDI
4243/5243 Agentic Systems, a four-week course at OU Polytechnic Institute in
July 2026 (Paper 33, cited under *Provenance*). It borrows from four parts of
that course: the Day 2 mini-build on workflow versus agent, Build Challenge 1
(tool calling), Build Challenge 3 (reliability and rollback), and Build
Challenge 5 (execution traces and approval gates). **It is not the course's own
assignment**, and nothing here reports how students did on it.

## Before you assign it: four decisions

1. **Pick the task.** Replace the example block in the handout with a task
   from your field. It needs one decision a model really has to make, two or
   three tools, and one action that cannot be undone.
2. **Write two sentences for yourself:** what the agent decides or does, and
   the evidence students hand in. If either takes more than a sentence, the
   task is too big for a week.
3. **Make the irreversible action safe.** No real email, no real deletion. Have
   it write to an outbox folder or a test queue, and grade it as if it were
   real.
4. **Give students one working tool call.** Before the week starts, run one
   model request that calls one tool, using an OpenRouter key (see `README.md`),
   and hand students that code. Building the loop is the assignment; finding
   the API is not.

---

# ↓↓↓ COPY FROM HERE — student-facing handout ↓↓↓

## Assignment: Build a small agent

**Points:** 100
**Time:** one week
**Work:** individual

### Why this assignment exists

Getting a model to call a tool is the easy part. Knowing what it did, stopping
it when it goes wrong, and bringing the system back takes engineering. This
assignment grades the engineering. An agent can report success when it did not
succeed, so you build the evidence into the system: a trace your code writes, a
check a person can see, and a gate a person has to open.

### The task

> **[INSTRUCTOR: replace this block with a task from your own field. Three or
> four sentences. Name the decision, the tools, and the irreversible action.]**
>
> *Examples. The course listed these as candidate capstone projects; the
> one-week sketches are examples, not the course's specifications.*
> - *A helpdesk ticket-triage agent. It reads a ticket, decides where it goes,
>   and drafts the routing. A person approves before anything is routed.*
> - *A course-catalog Q&A agent. It answers a question about courses and cites
>   the catalog entry behind every claim. A person approves before an answer is
>   posted.*
> - *A lab-report formatter designed never to invent a number. Every number in
>   its output must appear in the raw data file. A person approves before it
>   overwrites the report file.*

### Step 0: Would a plain script do?

Before you write any agent code, write the fixed-pipeline version: the same
task as a script in which no model decides anything. If that would take more
than an hour, describe it step by step instead.

Then write one paragraph in `DESIGN.md` arguing why this task needs an agent.
Name the step where a fixed rule breaks and a judgment is needed. If the script
does the job, say so, and narrow the task until one real decision is left.
Using an agent where a pipeline would do is a design failure.

### What you build

A small agent with these parts. Describe each one in `DESIGN.md` before you
build it.

**[INSTRUCTOR: name the model API and link the working tool-call example.]**

- **One decision the model makes.** Name it. Everything else is ordinary code.
- **Two or three tools.** Each has a schema: its name, its arguments, what it
  returns, and what it returns on an error.
- **A turn budget.** A hard limit on model calls per run. When the limit is
  reached, the run stops and says so.
- **One validation check a person can see.** It runs before the output is
  accepted. Its result is printed and logged.
- **An approval gate before any irreversible action.** The code asks a person
  and waits. No yes, no action.
- **An execution trace written by your code.** Not a summary the model writes
  about itself.

### What you submit

A repository. **Never commit an API key.** Keys go in an environment variable
or a gitignored file.

1. **`DESIGN.md`**: the Step 0 paragraph, and the six parts above.
2. **The agent code**, runnable from a clean checkout. `README.md` gives the
   one command that runs it.
3. **`traces/`**, one JSONL file per run, written by your code, one event per
   line: each model decision; each tool call, with its arguments and its
   result; each check and its outcome; each approval request and the answer.
   Submit `traces/normal.jsonl` from one normal run and `traces/failed.jsonl`
   from one run that failed. The shape, not a required format:
   ```
   {"event": "decision", "choice": "billing", "tokens_in": 1840, "tokens_out": 62}
   {"event": "approval", "action": "route_ticket", "answer": "no"}
   ```
4. **`PROMPTS.md`**, the prompt changelog. Every prompt edit gets an entry:
   what changed, what you expected, what you observed. "Made it better" is not
   an entry and earns nothing.
5. **`JOURNAL.md`**, three entries, one after each of: the first working tool
   call, the failure case, and the rollback. Four to eight sentences each, with
   the same four fields as `starter-assignment.md`: what I built; what failed;
   what I changed; where AI helped: what it decided, what it ran or opened, what
   came back, and how I verified it.
6. **`ROLLBACK.md`, the rollback story.** Something that failed, how you found
   it, and how you brought the system back to a known-good state. Show
   before-and-after evidence: trace lines, a commit, or rerun output.
7. **A cost note** in `README.md`: tokens in and tokens out for one normal run,
   measured from the usage numbers the API returns, not estimated. Treat token
   use like latency: a property of the design that you measure and reduce.

### Run these checks before you submit

I will grade by running them. Run them first.

1. Clone your repository into a fresh folder and run it using only `README.md`.
2. Open each trace. For each action it records, find what actually changed:
   the file, the queue, the output.
3. Break it on purpose: make one tool return an error, or feed it bad input.
   The agent must stop or recover, visibly, and the trace must show which.
4. Reach the approval gate and answer no. The irreversible action must not
   happen.

> **An agent's report of its own success is evidence of nothing. Check the
> artifact, not the narration.**

### Grading

| Component | Points | What earns them |
|---|---:|---|
| `DESIGN.md` (the rubric's *Specification*) | 10 | The Step 0 paragraph names where a fixed rule breaks. The decision, tools, turn budget, check, and gate are each stated before they are built. |
| Trace and checks (*Verification*) | 25 | The code writes the trace, and a rerun produces the same kinds of events. The failure case and the gate test behave as the trace says. |
| `JOURNAL.md` (*Failure account*) | 35 | Entries name specific failures and point at a trace line, a commit, or a prompt version a grader can open. |
| `PROMPTS.md` (*Prompt changelog*) | 5 | Every edit states what changed, what was expected, and what was observed. |
| The agent (*Artifact*) | 15 | Runs from a clean checkout, does the task, and carries a measured cost note. |
| `ROLLBACK.md` (*Recovery*) | 10 | Restores a known-good state and shows before-and-after evidence. |

**Total: 100.** Score each row at the rubric template's four levels
(Exemplary 100%, Proficient 80%, Developing 55%, Not yet 0%). For rows 1-5, the
"What earns them" column above is the Exemplary descriptor; the template's own
descriptors for those rows are written for `starter-assignment.md`. Row 6 uses
the template's Recovery row as written. These six rows are the build variant in
`rubric-template.md`, with the same weights. **A flawless demonstration with no
failure narrative is an incomplete demonstration.** No rollback story means an
incomplete submission.

### Ground rules

- **Never point the agent at a real irreversible action.** Use the outbox or
  test queue you were given.
- **A hand-written or edited trace is a fabricated result.** It is the same
  failure as an agent reporting work it did not do.
- Using a coding assistant to write the agent is allowed. Say so in
  `JOURNAL.md`. **[INSTRUCTOR: change this line if your policy differs, and add
  your institution's policy reference.]**

# ↑↑↑ COPY TO HERE — end of student-facing handout ↑↑↑

---

## Environment and budget

- **This repository's Codespace works**, and so does any Python environment with a
  key for any model API that supports tool calling. Student code reads the key
  from an environment variable, never from a file in the repository. **In a
  Codespace that means the key must be a Codespaces secret**: students add
  `OPENROUTER_API_KEY` at github.com → Settings → Codespaces → Secrets, with
  repository access set to their fork, *before* creating the Codespace
  (`README.md`, "Using it with students"). A key pasted at setup's prompt
  instead is stored only in the agent's own configuration and is **not** in the
  environment, so `os.environ["OPENROUTER_API_KEY"]` would raise `KeyError`.
- The same Codespace runs `openclaw chat`, so students can work inside an agent
  while they build one, as the course's students did. **Run your own agent in a
  terminal, not from inside `openclaw chat`:** setup opens that agent with the
  key (and the GitHub and Netlify tokens) taken out of its environment, so a
  program it runs for you cannot read them either.
- **Budget: tell students to measure it.** The cost note does that. For
  context only, the four-week course ran on about ten dollars of model credit
  per student.

## How a student would game this, and the counter

- **A hand-written trace.** The trace must come from the code. Rerun it from a
  clean checkout with the same input, and find the line of code that writes
  each kind of event. Model choices can differ between runs. The kinds of
  events should not, and every action the trace records must match something
  that actually changed.
- **A demonstration with no failure.** No rollback story means an incomplete
  submission, however clean the demo. The handout says so before anyone builds.
- **A gate that approves itself**: a default of yes, or a flag left on. Run
  the irreversible path yourself and answer no. The trace must show the request
  and the block, and the action must not have happened.

## What this assignment does not do

It is not validated, and there is no evidence it improves learning. It leaves
out context and retrieval (Build Challenge 2) and evaluation in CI (Build
Challenge 4).

## Provenance

Adapted from the design of **SDI 4243/5243 Agentic Systems**, OU Polytechnic
Institute, July 2026, described in: Hassell, J., Pearson, T., and Sayapaneni,
V., *Teaching Agentic AI as a Reliability Engineering Discipline: Course Design
and First-Offering Experience*, 2026 ASEE Midwest Section Conference.

Questions, or you adapted it and want to tell someone how it went:
John Hassell, OU Polytechnic Institute.
