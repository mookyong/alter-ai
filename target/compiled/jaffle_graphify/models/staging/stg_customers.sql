select
    id as customer_id,
    first_name,
    last_name,
    first_name || ' ' || last_name as full_name
from "jaffle_graphify"."main"."raw_customers"