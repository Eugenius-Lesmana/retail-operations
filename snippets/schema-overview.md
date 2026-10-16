# Schema overview

58 tables and 1 view in PostgreSQL. Foreign keys are listed as `column → table`. **Logical link** means the
relationship is enforced in application code, not by a foreign key.

## Sales (19)

| Table | One row is | Main foreign keys |
|---|---|---|
| `marketplace_order_lines` | one line of one order, for an online shop or an in-store outlet (`platform = 'Offline'`) | `bundle_id → inventory_bundles`, `source_batch_id → marketplace_import_batches`, `source_file_id → marketplace_import_files`. Product: logical link by copied item, variant, brand and category |
| `marketplace_import_batches` | one confirmed upload of marketplace exports | none |
| `marketplace_import_files` | one uploaded export file in a batch, with its 4-week report period | `batch_id → marketplace_import_batches` |
| `marketplace_raw_rows` | one raw export row (legacy, unused by current import) | `batch_id`, `file_id` |
| `marketplace_staging_rows` | one parsed, unconfirmed row (legacy, unused by current import) | `batch_id`, `file_id` |
| `unmapped_marketplace_rows` | one listing (shop + raw name + raw variant) that matched no mapping, with first/last seen | `batch_id`, `file_id` |
| `marketplace_bundle_fulfillments` | one bundle sale line being resolved into stock components (pending, resolved or cancelled) | `marketplace_order_line_id → marketplace_order_lines`, `bundle_id → inventory_bundles` |
| `marketplace_bundle_fulfillment_lines` | one component of a bundle sale, with the variant actually sent | `fulfillment_id → marketplace_bundle_fulfillments`, `component_id → inventory_bundle_components`, `product_id → inventory_products` |
| `offline_sales` | one in-store invoice (date, outlet, payment method, customer, status) | none |
| `offline_sale_lines` | one item line of an in-store invoice | `offline_sale_id → offline_sales`, `product_id → inventory_products` |
| `offline_sale_refunds` | one full or partial refund of an in-store invoice | `offline_sale_id → offline_sales` |
| `offline_sale_refund_lines` | one refunded quantity of one invoice line, with whether it went back to stock | `offline_sale_refund_id → offline_sale_refunds`, `offline_sale_line_id → offline_sale_lines` |
| `pos_offline_refund_requests` | one refund request from the POS app, for idempotency | `offline_sale_id → offline_sales`, `offline_sale_refund_id → offline_sale_refunds` |
| `dashboard_sales_daily_totals` | derived: one day's completed revenue, units, orders and mapping counts | none (cache) |
| `dashboard_sales_daily_dimensions` | derived: one day × one dimension value (outlet, brand, weekday …) | none (cache) |
| `dashboard_sales_aggregate_state` | single row: how far the dashboard cache is fresh, and from which date it is stale | none |
| `forecast_calibration_runs` | one run of the sales-volume forecasting model | none |
| `forecast_series_results` | one forecast for one series (business or variant) and target month, with backtest scores | `run_id → forecast_calibration_runs` |
| `imports` | one generic import log entry (legacy) | none |

## Products and mapping (4)

| Table | One row is | Main foreign keys |
|---|---|---|
| `inventory_products` | one sellable, stock-tracked variant of one product (brand and category are columns) | none |
| `product_mappings` | one shop listing name (+ optional variant) on one platform and shop, mapped to a product or a bundle | `bundle_id → inventory_bundles`; product: logical link by name, variant, brand and category |
| `inventory_bundles` | one bundle recipe sold as a single listing | none |
| `inventory_bundle_components` | one component of a bundle: fixed variant, or customer's choice from allowed variants | `bundle_id → inventory_bundles`, `product_id → inventory_products` |

## Purchases (3)

| Table | One row is | Main foreign keys |
|---|---|---|
| `purchase_invoices` | one supplier invoice, with its payment source (cash, deposit or payable) | supplier: logical link by supplier code |
| `purchase_invoice_lines` | one item line of a supplier invoice | `purchase_invoice_id → purchase_invoices`, `product_id → inventory_products` |
| `supplier_payment_rule_history` | one dated change to how a supplier is paid | `supplier_id → app_suppliers` |

## Inventory (6 + 1 view)

| Table | One row is | Main foreign keys |
|---|---|---|
| `inventory_stock_movements` | one signed stock change (sale, return, restock, adjustment, transfer) for one variant at one location | `product_id → inventory_products`, `location_id → inventory_locations`; source: logical link by `source_type` + `source_key` |
| `inventory_stock_counts` | one physical count of one variant at one location, effective from a date | `product_id`, `location_id` |
| `inventory_cost_history` | one standard unit cost of one variant, effective from a date | `product_id → inventory_products` |
| `inventory_locations` | one stock location (warehouse or store) | none |
| `inventory_summary_aggregates` | derived: inventory page totals for one location | none (cache) |
| `inventory_summary_aggregate_state` | single row: whether the inventory cache is stale | none |
| `inventory_current_stock` (view) | one variant × location: latest count + movements since = quantity on hand | (view) |

## Accounting (13)

| Table | One row is | Main foreign keys |
|---|---|---|
| `accounting_accounts` | one account in the chart of accounts (class, normal side) | none |
| `accounting_entries` | one journal entry (date, origin automatic/manual/scheduled, category, source) | `rent_schedule_id → accounting_rent_schedules`; source: logical link by `source_type` + `source_key` |
| `accounting_entry_lines` | one debit or credit line, optionally tagged with a counterparty | `entry_id → accounting_entries`, `account_code → accounting_accounts` |
| `accounting_rent_schedules` | one rent prepayment released monthly | none |
| `accounting_marketplace_rate_history` | one dated marketplace fee rate for one platform | none |
| `accounting_other_receivables` | one receivable outside the marketplaces (manual, or an in-store sale on credit) | `offline_sale_id → offline_sales`, `source_accounting_entry_id → accounting_entries` |
| `accounting_other_receivable_collections` | one collection against such a receivable | `receivable_id → accounting_other_receivables`, `accounting_entry_id → accounting_entries` |
| `accounting_daily_account_totals` | derived: one day × one account, debit and credit | `account_code → accounting_accounts` |
| `accounting_daily_counterparty_totals` | derived: one day × account × counterparty | `account_code → accounting_accounts` |
| `accounting_period_account_totals` | derived: one month × one account | `account_code → accounting_accounts` |
| `accounting_period_counterparty_totals` | derived: one month × account × counterparty | `account_code → accounting_accounts` |
| `accounting_period_close_status` | derived: one month's close checklist (automatic entries, salary, utilities, tax) | none |
| `accounting_aggregate_state` | single row: how far the accounting caches are fresh | none |

## Reference and admin (13)

| Table | One row is | Main foreign keys |
|---|---|---|
| `app_users` | one staff login (role, active, session version) | none |
| `app_user_permissions` | one permission granted to one user | `user_id → app_users` |
| `app_audit_logs` | one recorded staff action (import, edit, refund, submit) | `actor_user_id → app_users` |
| `app_settings` | single row of global settings (reporting start, opening date, stock threshold) | none |
| `app_outlets` | one shop or store: platform, name, code, stock location | none |
| `app_suppliers` | one supplier with its default payment method | none |
| `app_data_events` | one short-lived "data changed" signal for live refresh | none |
| `ui_translation_overrides` | one admin override of one interface string in one language | none |
| `pos_app_releases` | one published version of the POS app | none |
| `ai_accounting_drafts` | one accounting draft created by the entry assistant, with review status | `created_by_user_id`, `confirmed_by_user_id → app_users`, `confirmed_entry_id → accounting_entries`, `parent_draft_id → ai_accounting_drafts` |
| `ai_sales_drafts` | one in-store sale draft created by the sales assistant | `created_by_user_id`, `confirmed_by_user_id → app_users`, `confirmed_sale_id → offline_sales`, `parent_draft_id → ai_sales_drafts` |
| `ai_accounting_daily_usage` | one day's token use by the entry assistants | none |
| `ai_business_summary_daily_usage` | one day's token use by the query assistant | none |

## Renamed for publication

No table or column name identifies the business. Two **values** do, and are neutralised in these files and the
snippets:

- One account code in `accounting_accounts` contains a real supplier brand name → `asset_brand_supplier_deposit`.
- The POS source tag stored in `offline_sales.raw_payload` (company initials + `_android_pos`) → `android_pos`.

The table names `marketplace_*` and `offline_*` are generic and kept.
