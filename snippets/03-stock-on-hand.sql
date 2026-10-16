-- Quantity on hand per variant and location:
-- the latest physical count (if any) plus every movement since that count's effective date.
-- Simplified from the production view (display columns removed).
create view inventory_current_stock as
with latest_counts as (
  select distinct on (product_id, location_id)
         product_id, location_id, counted_quantity, effective_from_date
  from inventory_stock_counts
  order by product_id, location_id, effective_from_date desc, created_at desc
)
select
  p.id   as product_id,
  l.id   as location_id,
  p.normalized_name,
  p.actual_variant_name,
  coalesce(c.counted_quantity, 0)                              as counted_quantity,
  coalesce(sum(m.quantity_delta), 0)                           as movement_since_count,
  coalesce(c.counted_quantity, 0) + coalesce(sum(m.quantity_delta), 0) as quantity_on_hand
from inventory_products p
cross join inventory_locations l
left join latest_counts c
  on c.product_id = p.id and c.location_id = l.id
left join inventory_stock_movements m
  on m.product_id = p.id
 and m.location_id = l.id
 and (c.effective_from_date is null or m.occurred_at::date >= c.effective_from_date)
where p.active and l.active
group by p.id, l.id, p.normalized_name, p.actual_variant_name,
         c.counted_quantity, c.effective_from_date;
