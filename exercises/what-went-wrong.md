# What went wrong, and what we would repeat

**From the ASEE Midwest 2026 workshop *From Chatbots to Agents*.**

This is the candid list. It comes from one four-week offering of SDI 4243/5243
*Agentic Systems* at the OU Polytechnic Institute, July 13 to August 7, 2026,
and from the conference paper that reports it: Hassell, Pearson, and Sayapaneni,
*Teaching Agentic AI as a Reliability Engineering Discipline: Course Design and
First-Offering Experience*. The University Libraries AI Sandbox that supplied the
shared gateway was designed and is operated by the Libraries' Digital
Scholarship and Data Services group; the cost and capacity records quoted here are theirs.

Read it with the limits in front of you. One offering, a small cohort, a single
instructor who is also the first author, no comparison group, and no validated
instruments. **Nothing here is evidence that students learned more.** The
university's IRB determined on July 30, 2026 that the activity is not human
subjects research, and the paper reports no student work, grades, journal
content, or survey responses. What follows is operational experience: what the
infrastructure did, what the design cost, and what the instructor would do
differently. That is a smaller claim than most course-experience talks make, and
it is the honest one.

---

## What went wrong

### 1. The agent reported a deployment that never happened

During a Ship Day session — the build where student agents reach live external
services — the course environment **silently failed over to the open-weight
fallback model**. The agent reported the site "Successfully Built," presented
five search results, and had deployed nothing. The search results were
fabricated.

Nothing in the output looked wrong. It was fluent, confident, and correctly
formatted. What exposed it was the routine the course teaches from week one:
**check the deployed artifact, not the agent's narration.** The site was not
there.

Three things followed. The failure signature was written into the course
materials so every student could recognize a silent failover. The model defaults
were re-engineered mid-term. And the episode became the course's standing
illustration that an agent's report of its own success is a claim to be
verified, not a result to be accepted.

**The lesson:** an agent's self-report is evidence of nothing. Teach the
verification habit before the moment it is needed, because when it is needed the
output will look exactly like a success.

### 2. Capacity limits arrived during the capstone, exactly on schedule

In week two, with a 190-point design review due and capstone builds ramping,
students began reaching the gateway's usage limits. The instructor sent an
announcement mid-course that confirmed the model lineup, disclosed that limits
were being approached, reported that a raise had been requested with next-day
turnaround expected, and told students **not** to change their model-selection
strategy based on cost.

The honest detail: the shared meter recorded **zero failed requests** at any
point. The pressure students felt never appeared as a hard failure in the
records. It appeared as an announcement, a raise request, and an instruction to
keep working.

**The lesson:** agents consume tokens at rates that surprise instructors who
budgeted deliberately, and capstone weeks spike far above the term average. What
was missing was headroom for the spike and a pre-negotiated escalation path.
Both belong in the term's setup, not in its middle.

### 3. Environment maintenance cost more instructor time than any concept

Template edits do not reach already-forked student repositories without an
explicit synchronization step. A running dev container does not pick up new
defaults without a rebuild. Rolling the mid-term model change out to repos that
students had already forked was its own systems lesson in configuration propagation.

**This environmental friction consumed more support time than any conceptual
topic in the course.** Not agent architecture, not retrieval, not evaluation —
container rebuilds and template sync.

**The lesson:** agentic tooling sits on top of ordinary development operations,
and the operations are where the hours go. Budget instructor hours for
environment maintenance explicitly, as a line item, before the term starts.

### 4. Spend was spiky, and the spike was not where anyone was watching

The shared gateway key metered **5.5 million tokens, 190 requests, and $8.89**
for the whole cohort between July 13 and 27. Small — but the shape matters more
than the total:

- **99.3 percent of metered tokens were input, not output.** Agents read
  enormously more than they write. Context is where the money goes.
- The average request carried roughly **29,000 tokens**.
- **Two days accounted for 58 percent of tokens and 93 percent of spend.** Both
  fell in design-review week.
- Cost per million tokens ranged from about **$0.15** on fallback-only days to
  **$3.39** on the heaviest day, when only the frontier-class primary was
  active. A factor of roughly 22.

**The lesson:** the dominant cost lever available to a student is model routing
— sending mechanical steps to a lighter model.

### 5. The instructor cannot say what the term actually cost

The $8.89 figure is a **floor, not a total**. The export meters the shared team
key only. It excludes individually held gateway keys and every dollar of
personal OpenRouter spend, and metered usage on the shared key falls to near
zero after July 23 as students migrated to their own keys.

**The lesson:** if you want to be able to answer "what did this cost," decide
before the term where usage will be metered and make sure one record sees all of
it. This offering cannot answer that question, and says so.

### 6. The honesty rubric is unvalidated, and may reward performance

The Build Journal is graded on completeness and honesty about failure rather
than polish. That is the mechanism this course is most confident about
pedagogically and least able to defend empirically.

Stated plainly in the paper: **whether it rewards candor or a performance of
candor is an open question that the current instrument cannot settle.** The
structural counter-measure is that the required fields demand specifics that can
be checked against the repository the journal lives in — "what failed" and "what
changed" point at commits and diffs. Whether that anchoring is sufficient has
not been tested.

**The lesson:** a rubric that asks students to report failure creates an
incentive to produce interesting-sounding failures. Anchor every claimed failure
to a verifiable artifact, and treat the rubric itself as something to validate.

---

## What we would repeat

### 1. The rollback story requirement — if you keep only one thing, keep this

Every capstone demonstration had to include two non-negotiable elements: a
**visible execution trace** and a **rollback story** — what broke, and how the
system was brought back.

It is one line in an assignment specification. It costs nothing, requires no
tooling, and it changes what students optimize for all term, because a flawless
demonstration with no failure narrative is an incomplete demonstration.

**Adaptable to your course today:** add the line. It works anywhere students
demo something they built.

### 2. The prompt changelog — the cheapest thing here to adopt

Every graded build keeps its prompts in a `PROMPTS.md` file under version
control. Each edit gets an entry recording **what was changed, what was
expected, and what was observed.**

An entry reading "made the prompt better" is not acceptable. The rule forces
hypothesis-driven iteration rather than tinkering.

The reasoning: in an agentic system the prompt is load-bearing code whose
behavior can shift underneath the developer when the model updates. An
unversioned prompt is an unattributable failure waiting to happen.

**Adaptable to your course today:** this needs no infrastructure beyond a
repository, and it drops into any course where students write prompts as part of
a graded artifact — **including courses that are not about AI at all.**

### 3. A documented caught mistake, required in week one

Build Challenge 1 carries a delegation log: which coding assistant was used, the
key prompts, **one mistake the assistant made, and how the student caught it.**

Requiring a documented caught mistake in the *first week* normalizes the
expectation that the assistant will make one.

### 4. The Build Journal as the AI-disclosure record

`JOURNAL.md` in the repo, one short entry per build, four to eight sentences,
four required fields: **what you built, what failed, what you changed, and where
AI helped and how you verified its output.** A lab notebook, not an essay. Fifty
points, cumulative, due the last day of the block.

The integrity move is the fourth field. Rather than policing AI use, the course
requires disclosure as a professional habit, and the result is the audit trail
engineering teams already expect. It turns academic integrity from a detection
problem into a documentation practice.

**Change next time:** validate the rubric with explicit evidence-anchoring
criteria for every claimed failure, so it rewards honesty rather than the
performance of struggle.

### 5. Sequencing the syllabus by failure mode

The course is organized not by framework features or model capabilities but by
the ways agentic systems fail: brittle tool use and runaway cost, context
overflow and prompt drift, silent failure and unrecoverable actions, unnoticed
regressions, confabulated success and unsupervised irreversible action. Every
major assessment asks students to anticipate, detect, or recover from one.

**The lesson:** getting an agent to act is now comparatively easy. Getting it to
fail visibly, recoverably, and under human oversight is the hard part, and that
is what a course should be built around.

### 6. Cost as an engineering dimension from day one

Token consumption is treated the way latency is treated — a property of the
design, measured and optimized. Build Challenge 1 ends with a token-efficiency
redesign of the student's **own working solution**, so capability and economy
are taught as one lesson rather than two.

The roughly ten-dollar per-student ceiling is what makes this real. Students who
cannot afford waste learn to measure.

### 7. Keyword retrieval before embeddings

The student model path offered no embedding model, so retrieval in Build
Challenge 2 was built keyword-based. This turned out to be a better introduction
than the black box it replaced: students implemented matching and ranking
themselves instead of treating a semantic search engine as a given, and can
later meet embedding-based retrieval as one implementation of an idea they
already own.

**Change next time:** add an embedding-based retrieval extension **sequenced
after** the keyword implementation, not in place of it.

### 8. Protecting the pedagogy during an infrastructure event

When gateway limits were being approached, students were told explicitly not to
change their model-selection strategy based on cost — so that an infrastructure
event would not silently distort what the course was teaching.

**The lesson:** when the plumbing wobbles mid-term, say so in writing, say what
you are doing about it, and say which of your own instructions still stand.

### 9. The stack, and how to name it

The minimum viable version of this course: a Git host with classroom support, a
cloud development environment, an agentic coding environment, and pay-as-you-go
model access through a metered router.

- A university gateway is convenient but **not required**. The paper argues the
  personal router key is the more robust default, because each student's spend
  rides on their own key.
- Budget **approximately ten dollars per student for four weeks**, with
  meaningful headroom for the capstone period. Free tiers covered the deployment
  and search services.
- GitHub Education benefits covered Codespaces, so the development environment
  carried no marginal cost.
- Keep the **active model visible** in the environment. That indicator is what
  makes a silent failover a detectable event rather than a mystery.

When you adopt this, **name roles rather than products**: a frontier-class
primary model, an open-weight fallback, and a metered router. The specific
models named in the paper are mid-2026 instantiations of those roles, not the
design, and they will date quickly.

### 10. The operations mitigations that actually transfer

Learned the expensive way, and worth copying directly:

- Propagate template changes through the classroom tool's **automatic sync pull
  requests**, not by asking students to merge by hand.
- **Schedule template updates away from assignment deadlines.**
- **Preinstall deadline-day dependencies** in the template.
- Standardize on **four-core cloud machines** — they started noticeably faster
  and left memory to spare for agent sessions.
- **Treat a fresh container as the first diagnostic step**, before debugging
  anything else.

---

## The one line to take with you

> An agent's report of its own success is evidence of nothing. Students are
> taught to check the artifact, not the narration, and the course provides the
> instrumentation that makes checking cheap.

*Design principle 4 of 5, quoted from Section 4.1 of the paper.*

---

## Also committed for the next offering

Beyond the changes noted above, the next offering will: run under an
IRB-reviewed protocol with pre- and post-instruments and journal coding by two
independent coders, with consent obtained outside the grading relationship;
negotiate gateway headroom for capstone weeks and add per-student quota
visibility; keep a maintenance calendar for model-dependent course content; and
release the assignment specifications, rubrics, and journal and changelog
templates publicly, so the design is adoptable without correspondence.

---

*Source: Hassell, J., Pearson, T., and Sayapaneni, V., "Teaching Agentic AI as a
Reliability Engineering Discipline: Course Design and First-Offering
Experience," 2026 ASEE Midwest Section Conference. Sections 3.2, 4.1, 5, 6, 7,
8, 9, 10, and Table 4.*
