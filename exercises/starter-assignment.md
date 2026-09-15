# Starter assignment — *Delegate, Verify, Document*

**A starter assignment adaptable to your own course.**

Built for the ASEE Midwest 2026 workshop *From Chatbots to Agents*.
John Hassell, OU Polytechnic Institute. Copy it, cut it, rename it, put your
own name on it. (Reuse terms: see the repository README.)

---

## What this is

One assignment. One week. It drops into a course you already teach, on top of
work you already assign. It does not require you to teach AI, and it does not
require your students to know anything about AI before they start.

The move is this: **take a task you already give, have students delegate it to
an AI assistant, and grade the supervision instead of the output.** In this
repository's terms, students work the **Intent Gap**: the gap between what they
meant to ask for and what the assistant actually did.

That single change does most of the work. Students who have been quietly using
AI all semester now have to say what they asked for, what came back, what was
wrong with it, and how they know. Students who have been avoiding AI get a
first contact that is structured, low-stakes, and honest. And you get an
artifact you can actually assess, which a finished deliverable produced by
unknown means is not.

It is scaled down from a four-week agentic-AI course taught at OU Polytechnic
Institute in Summer 2026, described in the companion paper. Three mechanisms
from that course survive the shrink, because they cost nothing and travel
well:

- **A prompt changelog.** Prompts are load-bearing code. Version them.
- **A build journal graded on honesty about failure**, not on polish.
- **A required documented hunt for a mistake.** The assistant will almost certainly make one.
  Say which one — and if a real hunt comes back clean, show the hunt. The
  documented hunt is what earns the credit, not the catch.

The course sequenced its assignments by failure mode rather than by feature.
This assignment inherits exactly one failure mode, the one that matters most
and arrives first:

> **An AI assistant's report of its own success is a claim, not evidence.
> Check the artifact, not the narration.**

---

## Before you assign it — four decisions, about fifteen minutes

**1. Pick the task.** Something you already assign that takes a competent
student two to four hours, produces a checkable artifact, and has right and
wrong answers. Not an essay. A calculation, a design check, a data analysis, a
literature scan, a code deliverable, a spec review. See *Adaptation* below for
worked examples in four disciplines.

**2. Decide the track.** Track A needs nothing but a browser and a free chat
assistant. Track B needs a coding agent. **Pick Track A unless you already run
a course where students use Git.** Track A is the version that works in a
statics section on a Tuesday. Both appear in the handout below and you delete the one
you are not using before you hand it out. Track A is written out in full.
Track B is a placeholder you fill in, because the environment, the tool, and
the key handling are different at every institution and only you know yours.

**3. Decide whether to seed a defect.** This is optional, it takes about twenty
minutes, and it roughly doubles what the assignment teaches. Instructions are
in *Seeding a defect*, further down. If you skip it, the assignment still
works — students find real mistakes on their own, because the assistant makes
them without help.

**4. Decide what "verified" means for your task.** Write down, for yourself,
the two or three checks that would catch a wrong answer in your discipline: a
units check, a limit case, a conservation law, a recount against the raw data,
a lookup in the actual standard. You will paste these into the list of checks
in *Pass 3* of the student handout below. This is the part only you can supply, and it is the
part that makes the assignment yours rather than a generic AI-literacy
exercise.

---
---

# ↓↓↓ COPY FROM HERE — student-facing handout ↓↓↓

---

## Assignment: Delegate, Verify, Document

**Points:** 100
**Time:** roughly one week
**Work:** individual
**Turn in:** see *What you submit*

### Why this assignment exists

You are going to be working alongside AI assistants for the rest of your
career, and the skill that matters is not getting one to produce something. It
is knowing whether what it produced is true.

An AI assistant is fluent, fast, and confident whether or not it is right. It
will tell you a task succeeded when it did not. It will produce a number in
the correct format, with correct units, that is wrong. It does not know the
difference, and it cannot warn you. There is always a gap between what you
meant and what it did; your job is to find that gap and show it.

So this assignment does not grade the deliverable very heavily. It grades what
you can prove about the deliverable — how precisely you asked, what you
checked and what it showed, and what you would tell a colleague who has to
trust your work.

### Learning objectives

When you finish this assignment you will be able to:

1. **Specify** a technical task precisely enough that another agent — human or
   machine — can complete it without asking you a follow-up question,
   including scope, output format, and acceptance criteria.
2. **Compare** the output of an underspecified request against the output of a
   specified one, and describe the difference in concrete terms rather than in
   impressions.
3. **Verify** an AI-generated technical claim against a source of truth
   independent of the assistant, and either identify at least one specific
   error or show the checks that established there was none.
4. **Document** your use of AI in a form another engineer can audit: what you
   asked, what changed, what you observed, and how you checked.

Objective 1 is assessed by your final specification and `PROMPTS.md`.
Objective 2 is assessed by the *what the specification bought me* field in
`JOURNAL.md`. Objective 3 is assessed by `VERIFICATION.md`. Objective 4 is
assessed by `JOURNAL.md`.

### What you need

**Track A (default).** A web browser and access to one AI chat assistant. Any
of the free tiers is fine. If you have no access to one, tell me before the
due date — there is a no-account version of this assignment and you will not
be penalized for taking it.

**Track B (if your section is using it).** The course development environment
and the agent tool we set up in class.
**[INSTRUCTOR: if you are running Track B, replace that sentence with the
actual name of your environment, how students open it, and where they get
whatever key or login it needs. Track B is a placeholder here because it is
different at every institution. If you are running Track A, delete every
Track B line — here, in *What you submit*, and in the Deliverable row of
*Grading* — before you hand this out.]**

You will not be asked to pay for anything. Do not buy a subscription for this
assignment. If a tool asks for a credit card, stop and use a different one.

### The task

> **[INSTRUCTOR: replace this block with your own task. Keep it to three or
> four sentences. It should be something with a checkable answer.]**
>
> *Example, from an engineering-education context:*
> *You have a folder of 30 lab reports from last term, names removed. Produce
> a one-page evidence brief: which reports state a measured uncertainty, which
> do not, and for each one that does, the value as stated and where it appears.*

You will attempt this task **three times**. Do all three. The comparison
between them is most of what you are being graded on.

#### Pass 1 — Ask badly, on purpose

Open a new conversation. Ask for the task in **one sentence**, the way you
would ask a tired colleague across a desk. Do not describe the format you
want. Do not say how long it should be. Do not say what counts as done.

Save the entire exchange — your prompt and the full response.

Then answer these two questions in writing, in `JOURNAL.md`:

- Is anything it told you actually *wrong*?
- Could you hand this to someone who is depending on it?

For most students the honest answers are "no" and "no." Nothing is false, and
none of it is usable. That gap is the point of Pass 1. Do not skip past it.

#### Pass 2 — Ask well

Open a **new** conversation. Do not continue the first one; you want a clean
comparison, not a correction.

Write a specification. It must contain four things, each labeled:

1. **SCOPE.** What is in, what is out, and where the material lives. If there
   is a shortcut that makes the task tractable — an index, a header block, a
   summary table, a subset — name it and tell the assistant to use it instead
   of reading everything.
2. **METHOD.** How you want it done, if you care. If you do not care, say
   that.
3. **OUTPUT.** The exact shape of the answer. Sections, table columns, sort
   order, length. "A table with columns X, Y, Z, sorted ascending by X" is a
   specification. "A summary" is not.
4. **ACCEPTANCE CRITERIA.** Three to five checks the assistant must run
   against its own answer before giving it to you. Always include these two:
   - *"State how many source items you actually opened."*
   - *"End with a line beginning `Not checked:` naming anything you could not
     confirm. Say so plainly if you could not meet a criterion. Do not fill a
     gap with a guess."*

Run it. If the result is wrong in a way your specification did not prevent,
**edit the specification and run it again** — do not fix the output by hand.
Every edit gets an entry in `PROMPTS.md`. Two or three revisions is normal.

Save the final exchange.

#### Pass 3 — Break your own result

**Do not ask the assistant to check itself yet.** First, do it yourself.

Take the Pass 2 output and try to prove that a piece of it is wrong. Pick the
claim you would be most embarrassed to repeat in front of the class — usually
the most impressive one — and go to the source. Not to the assistant. To the
source.

Use these checks:

> **[INSTRUCTOR: replace this list with the two to four checks that catch a
> wrong answer in your discipline. Be concrete and mechanical.]**
>
> *Examples of the right level of concreteness:*
> - *Does the claimed size of the source match its actual size?*
>   `wc -w file` *against the size the metadata claims.*
> - *Does the document have a reference list at all?*
> - *Do the units resolve? Does the limit case behave?*
> - *Does the number appear, verbatim, in the source it is attributed to?*

Then, and only then, ask the assistant to audit itself. Paste something close
to this:

```
For every item you cited, run these checks and show me a table of the
results — do not summarize, show me each check:
[your checks here]
Then tell me which of your citations you would now withdraw.
```

Record what it withdrew, and — this matters more — record anything **you**
caught that it did not.

**You must hunt for at least one substantive error, and document the hunt
whether or not it finds one.** Substantive means not a typo: a fabricated source, an invented number, a miscount, a claim about a
source that the source does not support, a step that was reported as done and
was not.

If you genuinely believe there are none, look again first, and check the most
impressive claim against its original source rather than against the
assistant. Then report what you did. The rule that governs this:

**The clean-result rule.** Full credit for Verification requires a documented
hunt, not a particular outcome. The checks must be real, independent of the
assistant, and shown rather than described, and they must include tracing the
single most impressive claim to its original source. If the hunt caught an
error, the error is stated specifically: what was claimed, what is actually
true, and how that was established. If every check came back clean, that is
reported the same way, check by check, with what each returned, and earns the
same credit as a documented catch. A bare "I found no errors" with no checks
shown is an assertion, not a verification, and is scored as one.

"I found nothing" and "I stopped looking" produce the same one-line claim.
Only the version that shows every check is worth points.

### What you submit

Four things. **Track A:** plain text or Markdown files, or a single PDF
containing all four, clearly separated. **Track B:** the same four things,
committed in the repository your section was told to use, so that your prompt
versions and revisions are in the commit history and not only in a document.
**On either track, never commit or submit an API key, password, or other
credential.**

**1. The deliverable** — the Pass 2 output, revised by you if you found errors
in Pass 3. Mark your revisions. **Attach the raw Pass 1 exchange and the saved
final Pass 2 exchange as well**, on either track, prompt and full response for
each, including every step it shows (code run, file opened, search) and what
each returned; Track B: the agent's run log. That way the comparison in your
journal can be checked and your final specification is on record.

**2. `PROMPTS.md` — the prompt changelog.**

Your prompts are the part of this system you actually wrote. Version them the
way you would version code. One entry per revision:

```markdown
## v1 — 2026-10-06 14:20
**Changed:** Initial specification. Added SCOPE, OUTPUT, ACCEPTANCE.
**Expected:** A table of in-scope items with a source identifier on every row.
**Observed:** Got the table. Sort order ignored. No count of items opened,
even though I asked for one.

## v2 — 2026-10-06 14:41
**Changed:** Moved the "state how many items you opened" line out of the
paragraph and into its own numbered acceptance criterion.
**Expected:** An explicit count.
**Observed:** Count appeared: "opened 14 files." Sort order still wrong, so
that is a v3 problem.
```

**An entry that says the prompt was "improved" or "made better" earns zero
points for that entry.** State what you changed, what you expected, and what
you observed. Those three fields are the entry.

**The full text of every version must be in the submission.** Track A: paste
each version's full text under its entry. Track B: the commit history holds
every version; name the commit in the entry.

**3. `JOURNAL.md` — the build journal.**

One entry per pass — three entries. Four to eight sentences each. Four
required fields:

- **What I built.**
- **What failed.**
- **What I changed.**
- **Where AI helped: what it decided, what it ran or opened, what came back, and how I verified it.**

The **Pass 2 entry carries one extra required field**:

- **What the specification bought me.** Answer in counts, not impressions.
  Not "it was better." Something closer to: "Pass 1 named four sources and no
  total; Pass 2 named fifty-eight, each with an identifier I can open, and
  told me it opened fourteen files." If you cannot put a number on the
  difference, say that, and say why.

Write it like a lab notebook, not like an essay. It is graded on completeness
and honesty about failures, **not on polish**. A journal reporting three
failures and how you got past them scores higher than a journal reporting
that everything went smoothly. If everything went smoothly, you did not look
closely enough, and the journal is where that shows. The one exception is a
Pass 3 hunt that came back clean: that entry reports what the hunt found — a
failure, or the checks you ran and what each showed — and it earns the same
credit as a catch if it is specific enough to check against your
`VERIFICATION.md`.

This journal is also your AI-use disclosure for this assignment. See *Ground
rules*.

**4. `VERIFICATION.md` — the verification record.**

- Every check you ran, and what it returned. Include the checks that found
  nothing; a check that came back clean is evidence too.
- **Each substantive error you found, stated specifically.** What was claimed,
  what is actually true, and how you established it. If every check came back
  clean, say so under the clean-result rule in *Pass 3*: the checks and their
  results are the finding.
- What the assistant withdrew when you asked it to audit itself, and what it
  did not withdraw that it should have.
- A closing line: `Not checked: ...` — everything you did not have time or
  means to confirm. There is always something. Naming it costs you no points.
  Pretending there is nothing costs you several.

### Grading

| Component | Points | What earns them |
|---|---:|---|
| Specification (your final prompt, plus both transcripts) | 20 | Scope, output format, and at least three acceptance criteria the assistant can fail, the two required ones among them; the final Pass 2 transcript shows each one passing or failing. The "what the specification bought me" field in your Pass 2 journal entry states the difference from Pass 1 in countable terms rather than impressions. |
| `VERIFICATION.md` (the rubric's *Verification*) | 25 | Checks are real, independent of the assistant, and shown rather than described; the most impressive claim is traced to its original source; the self-audit record and the closing `Not checked:` line are present. Any error found is stated specifically; a clean result is reported check by check, under the clean-result rule in *Pass 3*. |
| `JOURNAL.md` (the rubric's *Failure account*) | 25 | Three entries, four fields each, specific and honest. Failures — or, for a Pass 3 hunt that came back clean, the checks run and what each showed — described concretely enough to be checked against your own submitted files. |
| `PROMPTS.md` (the rubric's *Prompt changelog*) | 15 | Real revision history. Each entry states what changed, what was expected, what was observed, with each observed effect pointing at a transcript line or run output; the full text of every version is in the submission. |
| Deliverable (the rubric's *Artifact*) | 15 | Correct, complete, in the requested format, with your Pass 3 revisions marked. Track B, when the deliverable is code: it also runs as specified from a clean checkout. |

These five rows are the five criteria in `rubric-template.md`, in the same
order and with the same weights, so the rubric's performance levels apply
directly.

**The deliverable is worth 15 of 100 on purpose.** A flawless result with no
failure narrative is an incomplete submission. What is being assessed is
whether you can supervise a fast, confident, unreliable collaborator — which
is the actual job.

**[INSTRUCTOR: a fuller rubric with performance levels is distributed
alongside this assignment as `rubric-template.md`. If you are handing out this
assignment on its own, either attach that file or delete this line — do not
leave students pointed at a document they do not have.]**

### Ground rules

- **AI use is required for this assignment.** That is the assignment.
- **Disclosure is by artifact, not by declaration.** You do not sign a
  statement. You submit `PROMPTS.md`, `JOURNAL.md`, and `VERIFICATION.md`,
  which show what you did in enough detail that a reader can follow it. This
  is how disclosure works on engineering teams: an audit trail, not an
  honor pledge.
- **Undisclosed use is the violation, not use.** Submitting AI-generated
  content as if you produced it, or fabricating a journal entry or a
  verification you did not perform, is academic misconduct under
  **[INSTRUCTOR: your institution's policy reference]**. Using an assistant
  heavily and saying so precisely is exactly what is being asked for.
- **A fabricated verification is the worst outcome available here.** Reporting
  a check you did not run is the same failure mode as the assistant reporting
  a task it did not complete. That is the thing this assignment exists to
  train out of you.
- **Never paste anything into an assistant that you would not post publicly.**
  No unpublished research data, no other people's personal information, no
  credentials or keys.

### If you get stuck

| What happened | What to do |
|---|---|
| No access to an AI assistant | Email me before the due date. There is a no-account version and it is not worth fewer points. |
| The assistant refuses the task | Note the refusal in `JOURNAL.md` as an observed failure, then narrow the request and try again. A refusal is data. |
| The output is different every time you run it | Expected. These systems are not deterministic. Record it in `JOURNAL.md` — that variability is itself one of the findings. |
| You cannot find any error at all | Re-read *Pass 3*, then check the single most impressive claim against its original source rather than against the assistant. If it still comes back clean, submit `VERIFICATION.md` with every check and what it returned: under the clean-result rule, a documented clean result earns the same credit as a catch. |
| A tool asks you to pay | Stop. Use a different one, or email me. Nothing here requires a purchase. |
| You are two hours in and lost | Email me with your `PROMPTS.md` as it stands. That file is enough for me to see where you are. |

---

# ↑↑↑ COPY TO HERE — end of student-facing handout ↑↑↑

---
---

## Adaptation — what to change for your course

Four lines carry the whole assignment. Change these and it becomes yours:

1. **The task.** One paragraph, replacing *The task*.
2. **The checks.** Two to four mechanical verifications, replacing the list in
   *Pass 3*.
3. **The source of truth** students must check against — the thing that is
   authoritative and is not the assistant.
4. **Optionally, the seeded defect.** See the next section.

Everything else — the three passes, the three files, the point split, the
ground rules — transfers unchanged.

### Worked variants

**Statics / mechanics of materials.**
*Task:* Give the assistant a loaded frame or truss — a real one from your
problem sets, described in text — and ask for member forces and a
recommended section from a named steel table.
*Checks:* Re-solve one joint by hand. Sum moments about a second point.
Confirm the section actually appears in the AISC table at the given
designation, with the properties claimed. Check units end to end.
*Source of truth:* the steel manual, not the assistant.
*What students find:* section properties that are plausible, correctly
formatted, and not in the table. Sign errors that survive because the
magnitude looks reasonable.

**Circuits / electronics.**
*Task:* Ask for a design meeting a specification — a filter with a stated
corner frequency, a bias network for a given operating point — with component
values drawn from standard E-series values, plus a parts list with real part
numbers.
*Checks:* Re-derive the transfer function. Check the corner frequency
numerically. Confirm every part number resolves to a real, currently stocked
part at a distributor. Check tolerance stack-up.
*Source of truth:* the datasheet and the distributor listing.
*What students find:* part numbers that do not exist, or exist with different
pinouts. Values that are not in any standard series. A response curve
described but never computed.

**Data science / statistics / any course with a dataset.**
*Task:* Hand over a real dataset — CSV, a few thousand rows — and ask for a
specific analysis with a specific output table.
*Checks:* Recount the rows yourself. Recompute one statistic in a spreadsheet.
Check the group counts sum to the total. Confirm every number in the write-up
appears in the code output. Re-run the same prompt and compare.
*Source of truth:* the raw file.
*What students find:* row counts that drift, a filter applied and then
described as if it were not, a p-value quoted in prose that no code produced.
This is the easiest variant to seed a defect into — see below.

**Design studio / capstone / project course.**
*Task:* Ask for a compliance review of a draft design against a named standard
or the sponsor's requirements document, returned as a requirement-by-
requirement table with a citation to the clause for every judgment.
*Checks:* Open the standard and read three cited clauses at random. Confirm
the clause numbers exist and say what is claimed. Confirm no requirement was
silently dropped from the table.
*Source of truth:* the standard.
*What students find:* clause numbers that look exactly right and are not.
Requirements quietly omitted rather than marked non-compliant. This variant
generalizes to codes, rubrics, ABET criteria, and sponsor specs.

**Literature review, any discipline.**
*Task:* A scoped review of a set of papers you provide. Not a search of the
open literature — provide the documents, so verification is possible.
*Checks:* Every citation resolves to a file you handed out. Every quoted
number appears verbatim in that paper. No two entries are the same paper under
two names.
*What students find:* the classic one. Confident citations to work that does
not exist.

**Anything with writing as the deliverable** — a lab report, a memo, a
proposal section. The checks become: does every factual claim trace to a
source in the packet; does every number appear in the data; is any citation
invented. The assignment structure does not change.

---

## Seeding a defect — twenty minutes, and it doubles the yield

If students verify against clean material, most of them find nothing, conclude
the assistant is reliable, and learn the opposite of the lesson. If the
material contains a known defect, verification becomes non-optional and you
get a clean signal on who actually did it.

You are not deceiving students. You tell them plainly in the handout: *"The
material you have been given may contain errors. Part of your job is to find
them."* They know a defect may be there. They still have to do the work to
find it, and the ones who skip verification still miss it.

**Two defects, both about twenty minutes to make, and both effective.** They
teach different things.

**1. The fabrication.** Add one item that does not exist. Write it to be
maximally attractive: the cleanest result, the largest effect, the most
quotable number, in exactly the format the assignment asks for. Make it the
best thing in the pile.

Then leave one mechanical tell in it. Metadata that contradicts content works
well: a header claiming roughly four thousand words above a body that runs
five hundred, a stated page count that the document does not have, a
references field with a number in it and no reference list underneath. The
reason to prefer a tell of that kind is that it can be caught by a check
rather than by expertise — a nervous student with no domain confidence can
still count words and compare. Calibrate it before you ship: run the same
check across your real material so you know what the normal range looks like,
and make the seeded item fall clearly outside it.

*Teaches:* the most impressive finding is the one to check first.
*Analogues:* a fabricated datasheet, an invented AISC section, a made-up
clause in the standard, a row in the dataset with a physically impossible
value, a citation to a paper that does not exist.

**2. The duplicate.** Copy a real item under a new identifier. It adds one to
every count and looks like nothing.

*Teaches:* a count is a claim. This one is quieter and lands harder on the
strong students.
*Analogues:* a duplicated row in the dataset, the same component listed under
two part numbers, the same requirement appearing twice in the spec.

**Three rules for seeding.**

- **Write an answer key first.** Exactly what the defect is, exactly what a
  correct finding looks like, and exactly which command or check surfaces it.
  Do this before you hand anything out, not while you are grading at 11pm.
- **Remove your own shortcuts from the student packet.** If you have an index,
  a summary table, or a clean list built from the *original* material, it will
  not contain the seeded item, and any student who uses it walks straight past
  the defect without knowing. Ship the material; keep the index.
- **Debrief in class, from the front.** Do not leave the reveal to individual
  grading. Put the seeded item on the screen and ask who cited it. Expect
  something like 40% of hands, not all of them — these systems are not
  deterministic and some students will get a clean result by luck. Forty
  percent is enough for the point to land, and you should say out loud that
  the ones who got a clean result got lucky rather than careful, because next
  time the luck runs the other way.

---

## AI cost and access when your department has no budget

Short version: **this assignment can cost zero dollars, and you should design
it that way even if you have money.**

**What agent work actually costs, measured.** The four-week OUPI course
metered its shared gateway key over two weeks of a full cohort building
agents: **5.5 million tokens, 190 requests, $8.89 total, zero failed
requests.** Per student, per term, that course budgeted **about ten dollars**
of pay-as-you-go model access, and that was for four weeks of continuous
agent construction.

This is one assignment, not four weeks. Extrapolating from those numbers —
and this is an extrapolation, not a measurement — a student running the three
passes here spends on the order of tens of cents. **Budget one dollar per
student and you will very likely not spend it. Budget three and you have
headroom.**

Two findings from that metering change how you design the assignment:

- **99.3% of the tokens were input, not output.** Agents read enormously more
  than they write. Cost scales with how much material you make them read, not
  with how much they produce. If you want the assignment cheap, hand students
  a small set of documents, or hand them a large one and require them to filter it
  first — which is a better assignment anyway.
- **Cost per million tokens ranged from about $0.15 to $3.39** depending on
  which model was used, a factor of about twenty-two. Model choice is the
  dominant cost lever available. A cheap fast model is entirely adequate for
  this assignment, and arguably better, because it fails more visibly.

**Paths that cost your department nothing, roughly in order of how much
friction they add:**

1. **Free-tier chat assistants.** Track A needs nothing else. Every major
   assistant has a free tier that will handle this task. This is the default
   and it works today.
2. **Your institution's existing license.** Many campuses already have an
   enterprise agreement through IT or the library, and faculty frequently do
   not know it. Ask before you buy anything. At OU, the University Libraries
   operate an AI Sandbox — a gateway giving students metered access to fifteen
   commercial and open models at no cost to them, funded by the Libraries.
   Your library may be closer to this than you expect. It is worth one email.
3. **GitHub Education.** Covers Codespaces for verified students and faculty,
   so a cloud development environment carries no marginal cost. Relevant only
   for Track B.
4. **A metered router with a student-held key** — OpenRouter or similar,
   pay-as-you-go, no subscription. The OUPI course found the personal key to
   be the *more* robust default than the institutional gateway, because each
   student's spend rides on their own key and one student's usage cannot
   exhaust the class. If you go here, cap it: tell students a dollar figure,
   and tell them to stop and email you rather than spend past it.
5. **Instructor-run — this is the "no-account version" the handout promises.**
   The handout tells students twice that a no-account path exists and
   costs them no points. This is it, and you should have it built before the
   assignment goes out rather than improvised when someone emails you. Run the
   three passes yourself, including the self-audit prompt from *Pass 3*,
   capture all four transcripts, and hand them out. Those students do Pass 3
   on your transcripts — their self-audit record is what your self-audit
   transcript withdrew and what it should have — and submit the deliverable,
   `VERIFICATION.md`, and `JOURNAL.md` as normal; `PROMPTS.md` becomes a
   written critique of your specification: the specification they would have
   run instead of yours, plus one entry per change they would make, each
   stating what they would change, what they expect it to fix, and what in
   your transcript shows it is needed. They lose the experience of specifying
   and keep the experience of verifying, which is the half this assignment is
   actually about. Grade it out of the same 100: their rewritten specification
   is graded as row 1 (Specification), with the "what the specification bought
   me" field computed from your two transcripts; their change entries are
   graded as row 4 (Prompt changelog); rows 2, 3, and 5 grade as written. The
   rubric says the same under *The no-account version*.

**Four rules regardless of budget.**

- **Never require a paid personal subscription.** It is an equity problem and
  it will be raised, correctly, at the first faculty meeting where you mention
  this. Free tiers are sufficient for this assignment. Say so in the handout.
- **Always have the no-account path ready** and mention it in the handout
  before anyone has to ask for it. A student who cannot get access should not
  have to disclose why.
- **Never have students commit or submit an API key.** If you use Track B,
  say this in the handout in bold, and check for it when you grade. Keys go in
  environment variables, not in repositories.
- **Name roles, not products, in your syllabus** — "a general-purpose AI
  assistant," "a metered model provider." The specific tools will change
  between the day you write the syllabus and the day you teach it. They
  changed once, mid-term, in the course this came from, and should be expected
  to change again.

---

## What this costs you to run

Honest numbers, so you can decide before you commit:

- **Setup:** about an hour to adapt the task and write your checks. Twenty
  minutes more if you seed a defect. Another twenty for the answer key, which
  you should not skip.
- **Grading:** slower than grading the deliverable alone, because you are
  reading three short documents instead of one. Faster than you expect,
  because the four required fields make a thin submission obvious in about
  thirty seconds. The specificity requirement does the triage for you — "what
  failed" and "what I changed" either point at something concrete or they do
  not.
- **In-class time:** zero required. Fifteen minutes of debrief makes it
  substantially better, and if you seeded a defect, the debrief is where the
  lesson actually lands.
- **The cost nobody budgets:** if you use Track B, environment maintenance.
  In the course this came from, template changes not propagating to existing
  student forks, and containers not picking up new defaults without a rebuild,
  **consumed more support time than any conceptual topic in the course.**
  Budget instructor hours for it explicitly, or use Track A, which has no
  environment to maintain.

---

## What this assignment does not do

Stated plainly, because you will be asked:

- It does not measure learning gains. There is no validated instrument here
  and no evidence that it improves outcomes relative to anything else. It is a
  design informed by one four-week offering with a small cohort and no
  comparison group.
- It does not detect AI use, and it is not meant to. It replaces detection
  with disclosure. A student determined to fabricate a journal can fabricate
  one — though doing so convincingly requires most of the work the assignment
  asks for, which is the only enforcement mechanism it has and the only one it
  claims.
- It does not teach anyone to build an agent. It teaches supervision of one.
  Those are different courses.
  The four-week course this comes from is the building course; this
  assignment is the checking habit that course grades from day one. For a
  first building assignment, see `starter-build-agent.md`.
- The honesty-graded journal has a known open problem: it can reward the
  *performance* of struggle rather than actual candor. The structural
  counter-measure is that the required fields demand specifics — "what failed"
  and "what I changed" point at artifacts you can check against the
  submission itself. Whether that is sufficient is unresolved.

---

## Provenance

Adapted from **SDI 4243/5243 Agentic Systems**, OU Polytechnic Institute,
July 2026, described in: Hassell, J., Pearson, T., and Sayapaneni, V.,
*Teaching Agentic AI as a Reliability Engineering Discipline: Course Design
and First-Offering Experience*, 2026 ASEE Midwest Section Conference.

The three mechanisms kept here — the prompt changelog, the honesty-graded
build journal, and the required documented hunt for a mistake — are the elements
of that course that cost nothing to adopt and require no tooling beyond
whatever you already use to collect work.

If you keep only one thing from this handout, keep the **required documented
hunt**. It is one line in an assignment specification, it costs nothing,
and it changes what students optimize for.

Questions, or you adapted it and want to tell someone how it went:
John Hassell, OU Polytechnic Institute.
