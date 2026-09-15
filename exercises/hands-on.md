# The hands-on: one goal, five moves

**Where you are:** setup printed **READY** and the agent opened in the terminal:
a bordered box with a cursor. You type there. Click once inside the terminal
before you type. Type each line as it appears and press Enter once, at the end.

**The Intent Gap.** Agents can act on our behalf, but they do not share the
full intent we carry in our heads. The engineering challenge is to expose the
gap between what you meant and what the agent did, then build checks, evidence,
recovery and human judgment around it.

## 0 PUT YOUR DOCUMENTS IN

**Read this first; it is the one rule on this page.** What the agent reads is
sent over the internet to OpenRouter and the model's provider, and it leaves
your control when it does. **Use only material you would be comfortable sending
to an outside company.** That means: no student records or student work, no
confidential or unpublished manuscripts, no material you are reviewing for a
journal or conference, no proprietary or industry-restricted data, no
unpublished results you are not ready to share, nothing under NDA or export
control.

Published papers or abstracts of your own, a syllabus, or public course pages
are safe choices. Plain text or Markdown files work best; the agent may or may
not manage to read a PDF, and watching how it tries is part of the lesson. Three to ten
documents is plenty. Teaching this rule to your students is part of teaching
them to use these tools.

Drag the files from your laptop onto the `mine` folder in the file list on the
left. (Setup created `mine/`. It is gitignored: nothing in it is ever
committed.) If dragging does not work, type this to the agent and paste one
paragraph, such as an abstract, after it:

```
Create mine/notes.md with this text:
```

## 1 PICTURE IT

Don't type yet. You are handing this job to the agent the way you would hand it
to a new research assistant:

```
Survey mine, find a missing topic, and draft a paper abstract for it.
```

Before it starts, write down what you expect:

- The topic it will pick: ________
- What it must do to be sure that topic is missing: ________
- What would make you trust the abstract: ________

## 2 HAND IT OVER

Now type the goal above, then press Enter.

It takes a minute or two. Watch the steps it shows: each one is an **Exec**
card. Notice the decisions you did not make.

## 3 COMPARE

Go back to what you wrote in move 1:

1. Topic: what did the agent decide that you never told it?
2. What it must do: did it do that, or something else?
3. Trust: could a decision it made make the abstract wrong for its purpose? On
   your own documents, you are the expert.

## 4 CHECK

Type:

```
Which results in your abstract did you actually compute?
```

Then scroll up to the cards above the **first** abstract. Look for a card that
could have produced a number: something that ran on real data. If there is
none, the number was not computed, whatever the agent says.

## 5 GIVE IT A RULE

Type:

```
New rule: never state a result you did not compute. Rewrite it.
```

Compare the rewrite with the first abstract. What changed? What did not?

You just started building an agent: a rule is the first line of its harness.
And a rule is a claim until you check it.

## Then check one claim yourself

Type:

```
For each claim, quote the sentence in mine it rests on.
```

Pick one quotation. Open that file in `mine` and find the sentence. Is it there,
word for word, and does it say what the agent claims?

**Check its evidence, not its summary.** The evidence is the files it opened and
the commands it ran, and the sentence in your own file. It is not "all good."

## What to expect

These three lines were tested on a folder of conference papers with Gemini 3.8
Flash. In every test run the first abstract stated results nobody had computed
(a cohort size, a p-value, a percentage); asked, the agent admitted they were
placeholders; given the rule, it rewrote the abstract without them. Your
documents, and the model's mood that day, will give a different run. The
pattern is what to look for.

## A variant for course materials (untested)

If `mine/` holds a syllabus and assignments rather than papers:

```
Read mine, find a gap in this course, and draft an assignment for it.
```
```
Which claims in it come from no file in mine?
```
```
New rule: name the file behind every claim. Rewrite it.
```

## If this went wrong

| You see | You do |
|---|---|
| It asks you a question | Answer in one line. If you don't know, tell it to choose and to say what it assumed. |
| A line ending in `$` | The agent closed. Type `openclaw chat`, press Enter. |
| Pressed Enter too early | Let it finish, then type the whole line again. |
| The abstract scrolled off the top | Scroll up. If it won't scroll, type: Show the abstract again. |
| `Agent couldn't generate a response` | Type the same line again. If it repeats, check your OpenRouter credit. |
| "mine is empty" or it cannot find your files | Check the files are inside `mine` in the file list, not beside it. |

Ctrl+C does not stop the agent. Let it finish.
