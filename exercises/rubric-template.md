# Rubric template

Yours to edit. It pairs with `starter-assignment.md`
and grades the four things that assignment asks a student to hand in: the
deliverable (the Pass 2 output, as revised in Pass 3), plus the record of how
they directed and checked the assistant that produced it — `PROMPTS.md`,
`JOURNAL.md`, and `VERIFICATION.md`. Adapted from **SDI 4243/5243 Agentic
Systems** (OU Polytechnic Institute, Summer 2026). Two mechanisms carry most of
the weight and both are free to adopt: a prompt changelog (`PROMPTS.md`) and a
build journal graded on honesty about failure (`JOURNAL.md`).

**Tracks.** The assignment offers Track A (a browser and a free chat
assistant; the submission is Markdown files or one PDF), Track B (a coding
agent in a course environment; the submission is a repository), and an
instructor-run no-account version. Every row below can be earned in full on
any of them. Where a descriptor names a commit or a diff, that is the Track B
form of the evidence; the Track A form is the attached transcript, the prompt
version in `PROMPTS.md`, or the line in `VERIFICATION.md` that the claim points
at. On Track B, also check that no key or credential was committed; the
assignment forbids it. The no-account mapping for all five rows is under *The
no-account version*, after the grader rules.

**The thesis:** a flawless demonstration with no failure narrative is an
incomplete demonstration. A correct deliverable proves the student got an
output. The specification, the verification, and the failure account prove
they could get it again, catch it when it goes wrong, and say what happened.
In this repository's terms, the rows grade how well a student exposed the Intent
Gap between what they meant and what the assistant did.
The artifact is worth 15 points here; the process is worth 85.

---

## The grid

Four levels. **Exemplary 100% · Proficient 80% · Developing 55% · Not yet 0%**
of the criterion's points. Grade each row independently.

| Criterion | Pts | Exemplary | Proficient | Developing | Not yet |
|---|---|---|---|---|---|
| **1. Specification**<br>The final prompt, plus both transcripts | 20 | The final prompt states scope (what is in and out), output format, and at least three acceptance criteria the agent can fail, the two required ones among them (how many sources it opened; a closing `Not checked:` line), and the final Pass 2 transcript shows each one passing or failing. A stranger could re-run it and get a comparable result. The Pass 2 journal field *what the specification bought me* states the difference from Pass 1 in countable terms. | Scope and format are explicit. Acceptance criteria are present but vague ("be accurate") or unfalsifiable, or one of the two required ones is missing. The Pass 1 comparison is stated in impressions ("much better") rather than counts. | The prompt names a task and little else. Scope is implied. No criteria the agent could be judged against. No Pass 1 comparison, or no Pass 1 transcript. | No prompt submitted, or one vague sentence with no scope, format, or criteria. |
| **2. Verification**<br>`VERIFICATION.md` — evidence the student checked the agent, not the agent's report | 25 | The checks are real and independent of the assistant — a file, a command output, a page, a number the student recomputed — and the submission *shows* each check (command, screenshot, quoted source, or trace line) rather than describing it. The single most impressive claim was traced to its original source. Any error found is stated specifically — what was claimed, what is true, how it was caught; a clean result is reported check by check (the clean-result rule below). The self-audit record and the closing `Not checked:` line are present. | Verification is real but partial: key claims checked, some taken on the agent's word. Checks described rather than shown. Or the self-audit record or the `Not checked:` line is missing. | Verification is asserted ("I confirmed the output was correct," "I found no errors") with no method and no artifact. | None. The agent's report is reproduced as the finding. |
| **3. Failure account**<br>`JOURNAL.md` — completeness and honesty. (The Pass 2 field *what the specification bought me* is scored under row 1, not here.) | 25 | All three entries (one per pass) present, four to eight sentences each, covering what was built, what failed, what changed, and where AI helped: what it decided, what it ran or opened, what came back, and how it was verified. Each names a **specific** failure — the actual error, wrong output, or wrong assumption — and points at something a grader can open in the submission: a transcript line, a prompt version, a line in `VERIFICATION.md`, a file — or, on Track B, a commit or a diff. The Pass 3 entry reports what the hunt found: a failure, or, if the hunt came back clean, the checks run and what each showed, pointing at the lines in `VERIFICATION.md` — a clean hunt reported that specifically is Exemplary, the same as a catch. Reads like a lab notebook. | All entries present, four to eight sentences, specific enough to follow, but at least one failure is described generically ("it kept breaking") or cannot be checked against the submitted files. | Entries present but thin, retrospective, or sanitized: process narration with no identified failure. Or fewer than half the required entries. | Missing, or a success story with no failures reported. |
| **4. Prompt changelog**<br>`PROMPTS.md` | 15 | An entry for every substantive prompt change, each stating **what changed, what was expected, and what was observed**, with each observed effect pointing at a transcript line or run output. Observed effects are reported honestly, including "no improvement" or "worse" where that is what happened. The full text of every prompt version is in the submission (in `PROMPTS.md` or the attached transcripts; on Track B, in the commit history). | Entries for most changes, stating what changed and why, but the observed effect is missing or asserted without evidence. | A few real entries. An entry saying only that the prompt was improved earns nothing toward this row, as the assignment states. | No changelog, every entry says only that the prompt was improved, or the prompt versions it describes appear nowhere in the submission. |
| **5. Artifact**<br>The deliverable: the Pass 2 output, as revised in Pass 3 | 15 | Correct and complete against the task, in the requested format. Pass 3 revisions marked. Known limitations documented rather than hidden. Track B, when the deliverable is code: also runs as specified from a clean checkout. | Minor deviations from the requested format or scope, or revisions applied but not marked. Track B code: runs with minor deviations, or requires an undocumented step. | Partially correct, or incomplete. Track B code: runs partially, or only in the student's own environment. | Wrong, not submitted, or (Track B code) does not run. |

**Total: 100 points.**

### Three grader rules that do the real work

- **The unverifiable-claim cap.** If the submission states as verified, or as
  fact, anything the student could not have checked — a source that does not
  exist, a number that appears nowhere in the cited material, a result from a
  run that never happened — without listing it under `Not checked:`, criterion
  2 is capped at **Developing**, however good the rest is. Anything honestly
  listed under `Not checked:` never triggers the cap; that line exists so a
  student who traced the most impressive claim can say plainly what they did
  not reach. An agent's report of its own success is evidence of nothing: check
  the artifact, not the narration.
- **The evidence spot-check.** Before scoring criterion 3, pick **one** claimed
  failure at random and go look for it in the submission. If the transcript
  line, prompt version, file, or (Track B) commit or diff it points at is not
  there, drop that row one level and say why. It takes about ninety seconds
  and it is the difference between grading honesty and grading the
  performance of honesty.
- **The clean-result rule.** Full credit for Verification requires a documented
  hunt, not a particular outcome. The checks must be real, independent of the
  assistant, and shown rather than described, and they must include tracing the
  single most impressive claim to its original source. If the hunt caught an
  error, the error is stated specifically: what was claimed, what is actually
  true, and how that was established. If every check came back clean, that is
  reported the same way, check by check, with what each returned, and earns the
  same credit as a documented catch. A bare "I found no errors" with no checks
  shown is an assertion, not a verification, and is scored as one.
  (The assignment states this rule in the same words under *Pass 3*.)

Grade rows 3 and 4 from the submitted files *before* you open the deliverable.
Otherwise everything after "it works" reads as justification.

### The no-account version

The assignment promises a no-account path: the instructor runs the three
passes and the Pass 3 self-audit prompt, hands out all four transcripts, and
the student does Pass 3 on them. Grade it out of the same 100. Row 1 grades
the rewritten specification in the student's `PROMPTS.md` — what they would
have run instead of the instructor's — plus the *what the specification bought
me* field computed from the instructor's two transcripts. Row 4 grades the
critique's entries, one per proposed change, each stating what they would
change, what they expect it to fix, and what in the instructor's transcript
shows it is needed — that last item is the *observed* field, and the
instructor's transcripts supply it, so an entry that points at the transcript
line earns the row's Exemplary as written. Row 2 grades as written, with the
self-audit record being what the instructor's self-audit transcript withdrew
and what it should have. Row 3 grades as written, with two fields mapped: for
passes 1 and 2, *what I built* is the student's reading of the instructor's
transcript for that pass (the two Pass 1 questions answered, the Pass 2 output
assessed), and *what I changed* points at the corresponding entry in the
critique; the Pass 3 entry needs no mapping. Row 5 grades as written.

---

## Adapting the weights

The five criteria are the durable part; the numbers are a starting position.
Move them deliberately — the weights are the message students actually read.

- **A course that is not about AI at all:** keep criteria **1, 2, and 4**
  (20/25/15, rescaled) and attach them to any assignment where students use an
  assistant. Cheapest version to adopt; needs no tooling beyond a repository,
  or a shared document.
- **Capstone, senior design, or a building assignment (the build variant):**
  Specification 10, Verification 25, Failure account 35, Prompt changelog 5,
  Artifact 15, and a sixth row, Recovery, 10 = 100. Recovery asks: can the
  student roll the system back to a known-good state and narrate it? Artifact
  (15) stays below Specification plus Verification (35). The Recovery row's
  levels are under *The Recovery row*, below. `starter-build-agent.md` uses
  this variant.
- **Large sections:** cut to three rows (Specification, Verification, Failure
  account) at 40/30/30 and grade the artifact pass/fail separately. The
  spot-check matters more, not less, as section size grows.
- **What not to move:** do not let **Artifact** exceed **Specification** plus
  **Verification**. Past that you are rewarding output again, and students will
  optimize for a clean demo by hiding the interesting parts.

### The Recovery row

The sixth row of the build variant only. The default grid above stays at five
rows. Same four levels, same percentages.

| Criterion | Pts | Exemplary | Proficient | Developing | Not yet |
|---|---|---|---|---|---|
| **6. Recovery**<br>Something went wrong, and how it was recovered | 10 | Restores a known-good state and shows before-and-after evidence (a commit, a file, or rerun output). Says what went wrong and which known-good state it went back to. | Restores a working state, but the evidence shows only one side (before or after), or the state restored is not shown to be known-good. | Recovery is described but not shown: no commit, file, or rerun output a grader can open. | No recovery, or the failure is hidden and the system is left broken. |

---

## What this rubric does about academic integrity

It replaces detection with disclosure. One of the journal's four required
fields is *where AI helped: what it decided, what it ran or opened, what came
back, and how you verified it*, so the journal is
itself the AI-use disclosure record: declaring assistance is not a confession
but a graded deliverable, and omitting it costs points on criterion 3. The
misconduct line therefore is not "you used an agent" — it is **"you presented
an unverified claim as a finding, or you concealed how the work was
produced."** Both are checkable against the submitted transcripts, the
changelog, and the deliverable. Authorship detection is not. This turns integrity from a policing
problem into a professional disclosure habit, and it produces the audit trail
engineering teams now expect.

**Honest caveat.** This rubric is unvalidated — one four-week offering, a small
cohort, a single instructor, and no evidence yet that it rewards candor rather
than a performance of candor. The spot-check is the structural
counter-measure, not a proof. Anchor the failure descriptors to your own
artifacts and expect to revise after your first real stack of submissions.
