# 1. How the dashboard works

The dashboard answers the questions the owners asked every week, in the order they asked them: *how much did
we sell, is that up or down, where did it come from, and what sold best?* Every number on it is computed from
completed sales in the database, never typed in.

![Operations dashboard](images/dashboard.png)

## Layout, top to bottom

| Section | Question it answers | Definition |
|---|---|---|
| **Revenue** card | How much did we sell? | Sum of net sales on completed sale lines in the selected period (cancelled lines count as 0) |
| **Completed orders** card | How many orders? | Count of distinct orders with at least one completed line |
| **Average order value** card | How big is a typical order? | Revenue ÷ completed orders |
| **Change badge** (e.g. −58.0%) | Is it up or down? | Change against the previous period of the same length, so a part-month is compared with a part-month |
| **Unmapped item groups** card | Can we trust the numbers? | Marketplace listings that are not yet mapped to a product; "Needs review" until they are |
| **Total revenue** chart | When did we sell? | Completed sales by day across all outlets, zoomable |
| **Item mapping health** | How much revenue is mapped? | Share of completed sales whose listing maps to a product in the index library |

The **unmapped items** card is deliberately on the front page. Revenue is correct whether or not a listing is
mapped, but item, brand and category analysis is only as good as the mapping, so the dashboard says how much of
it to trust.

## Contribution and drill-down

![Revenue by period and contribution](images/outlet-by-brand.png)

**Revenue by period and contribution** splits the same revenue by any one dimension (outlet, platform, brand,
category, item) over daily, weekly or monthly periods. The example shows each outlet's revenue broken down by
brand over the last two weeks.

![Sales analytics: market leaders](images/sales-analytics.png)

**Sales analytics** ranks the leader in each dimension for the period: item, variant, brand, category,
location, outlet, province, weekday, week of month and month, each with units, orders and revenue. Selecting an
item opens the same breakdown for that item alone, which answers "when and where does this product sell best?"

## Design choices

- **One definition per metric, used everywhere.** Revenue on the dashboard, in analytics and in the income
  statement comes from the same rule, so the pages never disagree.
- **Period comparisons are like for like.** A month in progress is compared with the same number of days of
  the previous month, not the whole month, which would always look like a drop.
- **Customers are people, not orders.** "Most valuable customer" groups orders by customer, not by order.
- **Trust signals sit next to the numbers** (mapping health, unmapped items, incomplete import weeks) instead
  of on a separate admin page.
