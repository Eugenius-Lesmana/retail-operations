# 4. AI assistants

Both assistants use the OpenAI API (GPT-4o mini). In both, **the model only interprets language**. Reading and
writing data is done by the platform's own code, with the same rules as the rest of the app.

```
 staff message ──▶ model: classify + extract ──▶ structured JSON ──▶ platform code ──▶ database
                   (no database access)            (validated)        (normal rules)
```

## Query assistant (read-only)

![Business summary assistant](images/ai-query-assistant.png)

1. The model classifies the question into one of a fixed set of request types, such as *sales summary for a
   period*, *best-selling items*, *low stock*, *top supplier by purchases*.
2. It fills in the parameters (period, outlet, item) as structured JSON.
3. The platform runs the matching query on its own aggregation layer.
4. The model turns the returned numbers into a short answer.

It cannot add, edit, delete, import or export data. A question that matches no request type gets a refusal, not
an invented answer. A daily token budget is shown in the panel.

## Entry assistant (drafts only)

![Draft review before anything is posted](images/ai-entry-review.png)

1. A staff member writes what happened in plain language, for example that the October electricity bill was
   paid in cash.
2. The model splits the message into individual entries and extracts each one's type, date, amount, category
   and payment account as structured JSON.
3. The platform turns them into **drafts**, checked by the same validation as a manual entry.
4. A person confirms, corrects or rejects each draft. **Nothing is posted until the batch is submitted.**

The review screen shows the original message next to each draft and warns when a draft would replace an
existing entry (for example, a second electricity bill for the same month).

## Why this design

- **Staff-safe.** A wrong interpretation produces a draft someone rejects, not a wrong number in the ledger.
- **Auditable.** Every posted entry went through the same code path as a manual one.
- **Cheap.** A small model is enough, because it only classifies and extracts; it never has to reason over the
  whole database.
