create database dbt_demo;

\connect dbt_demo

create schema if not exists raw;

create table if not exists raw.customers (
    customer_id integer primary key,
    customer_name text not null,
    city text not null
);

insert into raw.customers (customer_id, customer_name, city)
values
    (1, 'Alice', 'Seoul'),
    (2, 'Bob', 'Seoul'),
    (3, 'Chris', 'Busan')
on conflict (customer_id) do nothing;
