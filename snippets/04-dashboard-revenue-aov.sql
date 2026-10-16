-- Step 1 (cache refresh): one row per day of completed sales.
-- A sale is dated by when the order was created, in Jakarta time.
insert into dashboard_sales_daily_totals (entry_date, revenue, quantity, order_count)
select
  (order_created_at at time zone 'Asia/Jakarta')::date            as entry_date,
  round(sum(coalesce(net_amount, 0)), 2)                          as revenue,
  round(sum(coalesce(net_quantity, 0)), 2)                        as quantity,
  count(distinct concat_ws('|', platform, outlet, order_id))      as order_count
from marketplace_order_lines
where normalized_order_status = 'Completed'
  and (order_created_at at time zone 'Asia/Jakarta')::date between :from_date and :through_date
group by 1;

-- Step 2 (dashboard card): revenue, completed orders and AOV for a period.
-- An order belongs to exactly one day, so daily distinct counts add up correctly.
select
  sum(revenue)                                   as revenue,
  sum(order_count)                               as completed_orders,
  sum(revenue) / nullif(sum(order_count), 0)     as average_order_value
from dashboard_sales_daily_totals
where entry_date between :period_start and :period_end;

-- The change badge compares this with the previous period:
--   this month (1st..today)  vs  the whole previous calendar month
--   this year (Jan 1..today) vs  the whole previous calendar year
--   last week                vs  the week before
