
    
    

select
    product_id as unique_field,
    count(*) as n_records

from (select * from `walmart`.`silver_technical`.`products_t` where price > 0) dbt_subquery
where product_id is not null
group by product_id
having count(*) > 1


