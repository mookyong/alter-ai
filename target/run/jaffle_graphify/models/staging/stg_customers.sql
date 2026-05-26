
  
  create view "jaffle_graphify"."main"."stg_customers__dbt_tmp" as (
    select
    id as customer_id,
    first_name,
    last_name,
    first_name || ' ' || last_name as full_name
from "jaffle_graphify"."main"."raw_customers"
  );
