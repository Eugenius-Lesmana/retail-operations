# 6. Workflows, tab by tab

What each part of the platform is for, and what a staff member actually does there. Every write described here
follows the same server-side path (check access → validate → write → derive stock and ledger → audit → refresh
other screens), described in [Architecture](00-architecture.md).

## Sales

**Weekly routine: import marketplace sales.**

1. Download each shop's order export from Shopee or TikTok for a 4-week window (Monday to Sunday).
2. **Import records → Online marketplace**, drop the files, and pick the report period. Each file is assigned
   to its shop (guessed from the file name, editable).
3. **Review.** The preview shows rows per file, matched and unmapped rows, the date range found, and warnings:
   rows outside the period, two files for one shop, a file name that disagrees with the period, or sparse weeks.
   Nothing has been written yet.
4. **Confirm.** A progress modal walks through the stages (reading, replacing the window, writing lines,
   resolving bundles, stock, accounting, audit) and ends with a summary.
5. Check the header cards: **Unmapped items** (go to the index library), **Incomplete weeks** (a shop's export
   is missing for some week), **Latest refresh**.

**In-store sales.** **Import records → Manual / offline**: upload invoice workbooks (file name, invoice number,
date, outlet code and item table are cross-checked) or fill the form: date, outlet, customer, payment method
(cash, QRIS, transfer, debit, credit or on account with a due date) and lines. The invoice number is generated
from date and outlet. Re-using an invoice number asks for replacement confirmation. Sales from the Android POS
appear here automatically.

**Corrections.** The sales history can be filtered and exported. A full or partial **refund** picks lines and
quantities and whether the items go back to stock. Moderators can cancel or delete a wrong transaction; both
are audited.

## Purchases

1. **Import purchases**: one or more supplier invoice workbooks (named by date, type and supplier code), or a
   manual invoice.
2. **Review files**: supplier, date and file name are cross-checked against the invoice content; items are
   matched to variants; an existing invoice number asks for replacement.
3. **Import**: lines are written, stock is added at the receiving location, and the ledger posts inventory
   against cash, the supplier's deposit or a payable, depending on that supplier's payment rule on the invoice
   date.

## Inventory

![Inventory management](images/inventory.png)

| Task | How |
|---|---|
| Map new listings | **Index library → Import** (spreadsheet) or **Manual** (one mapping); warnings for re-pointed mappings need acknowledging. See [Product mapping](05-product-mapping.md) |
| Define bundles | **Bundle library → Import** or **Manual**: bundle code, total units, fixed components and customer-choice components |
| Resolve customer-choice bundles | Assign the variants actually sent; stock and cost follow |
| Check stock | Current stock by item, brand and category, per location or all locations; low-stock count against the admin threshold |
| Look into one item | **Details**: variants, stock per location, dated cost history, and the movement history chart |
| Record a count | Count for a variant at a location on a date; the difference is posted as an inventory adjustment |
| Change a cost | New cost with an effective date; the change in value of stock on hand is posted to the ledger |
| Move stock | **Stock transfer** between locations |

## Accounting

![Accounting activity: automatic and manual ledger entries](images/ledger-activity.png)

- **Data:** the month's ledger activity, automatic and manual, filterable by entry type, with the balances on
  top (cash, inventory, deposits, receivables, prepayments, equity).
- **Add accounting entry:** capital or withdrawal, loan received, marketplace payout, supplier deposit, other
  receivable, rent prepayment (released monthly), fixed asset, operating expense, monthly expense (salary,
  utilities, tax) and payable settlement. Each type asks only for the fields it needs, and loans can fund only
  deposits, prepayments and fixed assets.
- **Balance sheet** and **Income statement** for any date or month, with supplier balances by counterparty.
- **Monthly close:** a checklist per month (salary, utilities and tax recorded; automatic entries present) that
  shows *Review* until complete.
- **Opening balance:** created once, on the oldest reporting week, from cash and supplier deposits; inventory
  starts at zero or from a full physical count.

## AI Assistant

- **Accounting and sales drafts:** describe what happened, review the drafts (confirm, correct by replying, or
  reject), then submit the batch. See [AI assistants](04-ai-assistants.md).
- **Business Summary** panel on every page: ask about sales, items, purchases, stock, cash or the forecast.

## Admin

| Area | What an admin does |
|---|---|
| Users | Create staff logins, set roles (user, moderator, admin) and per-feature permissions, reset passwords, disable accounts, view each person's activity history |
| Backups | Take a verified snapshot to a separate database, preview it, restore it (a safety copy is taken first, then counts are verified and caches rebuilt) |
| Retention | See and clean up temporary records (refresh signals, abandoned imports, old AI drafts) |
| Sales settings | Oldest reporting week, online shops and in-store outlets with their stock locations |
| Suppliers | Supplier codes and dated payment rules (cash, deposit, payable) |
| Accounting settings | Dated marketplace fee rates per platform |
| Inventory | Low-stock threshold |
| Glossary | Override English or Indonesian wording without a code change |
| Forecasting | Re-fit the monthly unit forecast; each series picks the model with the best back-test |

A weekly scheduled job runs retention, a backup and a forecast refresh.
