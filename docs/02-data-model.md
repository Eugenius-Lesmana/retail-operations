# 2. Data model

59 PostgreSQL tables, grouped into six areas. The design rule throughout: **decide what one row means before
anything else**, because almost every reporting error in the old spreadsheets came from mixing levels.

## The six areas

```
 Marketplace exports         Supplier invoices
        │                           │
        ▼                           ▼
 ┌──────────────┐  maps to  ┌──────────────┐
 │    SALES     │──────────▶│   PRODUCTS   │◀── index library: listing names → products
 │ order lines  │           │  + variants  │◀── bundle library: bundle → components
 └──────┬───────┘           └──────┬───────┘
        │ moves stock              │
        ▼                          ▼
 ┌──────────────┐           ┌──────────────┐
 │  INVENTORY   │◀──────────│  PURCHASES   │
 │  movements   │  receives │ invoice lines│
 └──────────────┘           └──────┬───────┘
        ▲                          │
        │ cost of goods            ▼
 ┌──────────────────────────────────────────┐
 │               ACCOUNTING                 │
 │ double-entry ledger, receivables,        │
 │ payables, monthly close                  │
 └──────────────────────────────────────────┘
```

| Area | One row means | Notes |
|---|---|---|
| **Sales** | one product line of one order, on one platform and outlet | Orders are grouped by order number; returns and cancellations are kept, not deleted |
| **Products** | one sellable variant of one product (e.g. a polish in one colour) | Brands and categories hang off products |
| **Product mapping** | one raw marketplace listing name, or one bundle | Points to the product, or to the bundle's components |
| **Purchases** | one line of one supplier invoice | Re-importing an invoice replaces it after confirmation, so there are no duplicates |
| **Inventory** | one stock movement (sale, purchase, return, adjustment) | Stock on hand is the sum of movements, never a number edited by hand |
| **Accounting** | one ledger line (debit or credit) | Every entry balances; automatic and manual entries are labelled |

## Grain rules that mattered

- **A listing is not a product.** Shops name the same item differently, and rename listings. Sales keep the raw
  listing name and are joined to the product through the mapping table, so a rename never loses history.
- **A bundle is not one item.** A bundle line is resolved into its components for stock and cost. Where the
  customer picked the variants, the line waits as *pending choice* until staff assign them.
- **An order is not an order line.** Order counts use distinct orders; units and revenue use lines.
- **Stock is a history, not a field.** Because stock is the sum of movements, any count can be explained, and
  a wrong movement can be reversed instead of overwriting the total.

## In numbers (real data)

- About **2,000 orders a month** across physical outlets, Shopee and TikTok.
- **7,100+ raw listing names** mapped to **288 products**.

The screenshots and examples in this repository use synthetic data.
