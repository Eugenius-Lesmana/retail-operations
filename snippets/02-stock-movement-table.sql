-- One row = one signed change to the stock of one variant at one location.
-- Stock is never stored as a number; it is derived from counts and these movements.
create table inventory_stock_movements (
  id             uuid primary key default gen_random_uuid(),
  product_id     uuid not null references inventory_products (id),
  location_id    uuid not null references inventory_locations (id),
  movement_type  text not null check (movement_type in (
                   'sale', 'return_to_stock', 'damaged_return', 'restock',
                   'manual_adjustment', 'physical_count_adjustment',
                   'transfer_in', 'transfer_out')),
  quantity_delta numeric(14,3) not null check (quantity_delta <> 0),  -- negative = out
  unit_cost      numeric(14,2),
  occurred_at    timestamptz not null,
  source_type    text not null default 'manual',  -- e.g. sale line, purchase line, bundle component
  source_key     text,                            -- id of the record that caused the movement
  notes          text
);

-- One movement per source record, so a re-run can never double-count stock.
create unique index inventory_stock_movements_source_key_uidx
  on inventory_stock_movements (source_type, source_key)
  where source_key is not null;

create index inventory_stock_movements_product_location_date_idx
  on inventory_stock_movements (product_id, location_id, occurred_at desc);
