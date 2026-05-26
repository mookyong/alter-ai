
  
    
    

    create  table
      "jaffle_graphify"."main"."dim_customers__dbt_tmp"
  
    as (
      with customers as (
    select * from "jaffle_graphify"."main"."stg_customers"
),

orders as (
    select * from "jaffle_graphify"."main"."fct_orders"
)

select
    customers.customer_id,
    customers.full_name,
    count(orders.order_id) as order_count,
    sum(orders.total_amount) as lifetime_value
from customers
left join orders using (customer_id)
group by 1, 2
    );
  
  