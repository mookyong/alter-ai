create database dbt_demo;

\connect dbt_demo

create schema if not exists raw;

create table if not exists raw.customers (
    customer_id integer primary key,
    customer_name text not null,
    city text not null
);

create table if not exists raw.orders (
    order_id integer primary key,
    customer_id integer not null,
    order_amount numeric(12, 2) not null,
    order_date date not null
);

insert into raw.customers (customer_id, customer_name, city)
values
    (1, 'Alice', 'Seoul'),
    (2, 'Bob', 'Seoul'),
    (3, 'Chris', 'Busan')
on conflict (customer_id) do nothing;

insert into raw.orders (order_id, customer_id, order_amount, order_date)
values
    (1, 1, 120.00, '2024-05-01'),
    (2, 1, 80.50, '2024-05-02'),
    (3, 2, 45.00, '2024-05-03'),
    (4, 3, 210.75, '2024-05-04')
on conflict (order_id) do nothing;
