-- One row = one line of one order, from an online shop export or an in-store sale.
-- Trimmed to key columns. Raw listing text is kept; the mapped product fields are copied
-- onto the line and rewritten when the mapping library changes.
create table marketplace_order_lines (
  id                      uuid primary key default gen_random_uuid(),
  platform                text not null,              -- 'Shopee', 'TikTok' or 'Offline'
  outlet                  text not null,
  location                text not null check (btrim(location) <> ''),
  order_id                text not null,
  order_line_key          text not null,              -- stable identity of the line within the export
  normalized_order_status text,                       -- 'Completed', 'Shipping' or 'Cancelled'
  order_created_at        timestamptz,
  order_completed_at      timestamptz,
  raw_product_name        text not null,              -- listing name exactly as exported
  raw_variant_name        text,
  normalized_name         text not null,              -- mapped product (copied)
  actual_variant_name     text,                       -- mapped variant (copied)
  brand                   text not null,
  category                text not null,
  quantity                numeric default 0,
  returned_quantity       numeric default 0,
  net_quantity            numeric default 0,          -- 0 unless completed
  gross_amount            numeric(14,2) default 0,
  discount_amount         numeric(14,2) default 0,
  refund_amount           numeric(14,2) default 0,
  net_amount              numeric(14,2) default 0,    -- 0 unless completed
  mapping_type            text check (mapping_type in ('standard', 'bundle')),
  bundle_id               uuid references inventory_bundles (id),
  source_batch_id         uuid references marketplace_import_batches (id),
  unique (platform, outlet, order_line_key),
  check ((mapping_type = 'bundle' and bundle_id is not null)
      or (mapping_type = 'standard' and bundle_id is null))
);
