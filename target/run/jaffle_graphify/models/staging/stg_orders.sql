
  
  create view "jaffle_graphify"."main"."stg_orders__dbt_tmp" as (
    select
    id as order_id,
    user_id as customer_id,
    cast(order_date as date) as order_date,
    status
from "jaffle_graphify"."main"."raw_orders"
  );
