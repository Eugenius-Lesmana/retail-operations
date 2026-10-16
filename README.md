# Retail operations and analytics platform: a case study

A sales, inventory, purchasing and accounting platform I designed for my family's multi-outlet retail business,
which sells beauty products through physical stores and Shopee and TikTok shops (about 2,000 orders a month).
It is in rollout: historical data is being imported and the design is being tuned for real-world volume.

**This is a case study, not a code release.** The platform is private. Every screenshot below comes from a demo
copy running on **synthetic data**: the brands, products, customers, suppliers and amounts are invented, and the
company name has been replaced.

![Operations dashboard: revenue, orders, average order value, daily revenue and item-mapping health](docs/images/dashboard.png)

## The problem

Before the platform, sales lived in marketplace exports, purchases in supplier invoices, and stock in
spreadsheets that were updated by hand. That caused three recurring problems:

- **Stock counts drifted.** Marketplace listings are named however each shop chose, often with bundles
  ("buy 3, pick your colours"), so the same physical product sold under dozens of names and bundles did not
  reduce the right stock.
- **Invoices went missing,** so purchase costs and supplier balances were incomplete.
- **There was no accountant,** so there was no reliable view of profit, cash or what was owed.

## What I built

One PostgreSQL database (59 tables) that every sale, purchase and stock movement flows through, with an
analytics layer and two AI assistants on top.

| Area | What it does |
|---|---|
| **Sales** | Imports Shopee and TikTok exports and manual in-store sales; staged imports flag rows that cannot be mapped instead of guessing |
| **Product mapping** | Reconciles raw marketplace listing names to normalised products and variants: **7,100+ listing names mapped to 288 products** in the real data, including bundles |
| **Purchases** | Supplier invoices with line items, costs and due dates |
| **Inventory** | Every sale and purchase moves stock by variant and location; full movement history per item |
| **Accounting** | Double-entry ledger posted automatically from sales and purchases, plus manual entries; balance sheet and income statement |
| **Analytics** | Revenue by day, week, month and year; by outlet, platform, brand, category and item; best periods per item; top customers |
| **AI assistants** | One answers business questions from the data, read-only; one turns staff messages into draft entries for review |

### Analytics

![Sales analytics: revenue, units and orders for the period, and market leaders by item, variant, brand, category, location, outlet, day and month](docs/images/sales-analytics.png)

Every "market leader" card answers a question the owners asked repeatedly: which item, variant, brand,
category, outlet, province, weekday and month sells most, with units, orders and revenue behind each.

### Bundles and product mapping

![A bundle sale: each customer-chosen component is assigned to the actual stock variant sold](docs/images/bundle-mapping.png)

Bundles were the main cause of stock errors. A bundle sale is split into its components, and where the
customer chose the colours, staff assign each component to the real variant, so stock moves for what actually
left the shelf. Until that is done the line is marked *Pending choice*, not silently guessed.

### Inventory

![Stock movement for one variant: purchases step stock up, sales draw it down](docs/images/stock-movement.png)

Each variant's stock is the sum of its movements, so any count can be traced back to the sales and purchases
that produced it.

### Accounting

![Balance sheet: assets, liabilities and equity at a chosen date](docs/images/balance-sheet.png)

![Income statement and monthly close: revenue, cost of goods sold, gross profit, and which monthly costs are recorded](docs/images/income-statement.png)

Sales and purchases post double-entry ledger lines automatically. The monthly close shows whether salary,
utilities and tax have been recorded before a month is treated as complete, so the profit figure is not
overstated by missing costs.

### AI assistants

![Read-only business assistant answering "How is the business this month?"](docs/images/ai-query-assistant.png)

**The query assistant** (OpenAI GPT-4o mini) classifies a question into a known request type, such as sales or
stock over a period, asks the platform's own aggregation layer for the numbers, and explains the answer in
plain language. It cannot add, edit, delete, import or export anything.

![Draft review: the entry assistant's proposals are confirmed, corrected or rejected before anything is posted](docs/images/ai-entry-review.png)

**The entry assistant** turns a staff message ("paid the October electricity, 2.15 million") into structured
draft entries. Nothing is posted until a person confirms each draft, and the platform warns when a draft would
replace an existing entry.

In both, the model only interprets language; the platform's own code does all reading and writing of data.

## How it is built

- **Database:** PostgreSQL on Supabase; 59 tables across sales, product mapping, purchasing, inventory,
  accounting and reference data.
- **Application:** a web app (Next.js) deployed on Vercel, plus a point-of-sale app that sends in-store sales
  straight to the database.
- **AI:** OpenAI API (GPT-4o mini) with structured JSON output for both assistants.

**My role.** I designed the data model, the business rules (mapping, bundles, stock movements, ledger
postings, the monthly close) and how the pieces connect. Most of the application code was written with AI
coding assistants (mainly OpenAI Codex) working to my specifications, and I reviewed and tested it.

## What I learned

- **Fix the grain first.** Most reporting errors came from mixing levels: a listing is not a product, a bundle
  is not one item, an order is not an order line. Getting those right in the schema fixed problems no report
  could.
- **Flag, don't guess.** Imports that stop and ask about unmapped rows are slower on day one and far cheaper
  than wrong stock found a month later.
- **Keep the model away from the data.** Letting the AI only interpret requests, with all reads and writes in
  ordinary code, made the assistants safe to give to staff.

## What is not here

The source code, the real data, and anything that identifies the business's customers or suppliers.
