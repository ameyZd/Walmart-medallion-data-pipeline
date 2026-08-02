
      merge into `walmart`.`gold`.`dim_customers` as DBT_INTERNAL_DEST
        using `dim_customers__dbt_tmp` as DBT_INTERNAL_SOURCE
    on DBT_INTERNAL_SOURCE.`dbt_scd_id` = DBT_INTERNAL_DEST.`dbt_scd_id`
    when matched
        and ( DBT_INTERNAL_DEST.`dbt_valid_to` = to_date('9999-12-31') or
                DBT_INTERNAL_DEST.`dbt_valid_to` is null )
        and DBT_INTERNAL_SOURCE.`dbt_change_type` in ('update', 'delete')
        then update
        set `dbt_valid_to` = DBT_INTERNAL_SOURCE.`dbt_valid_to`

    when not matched
        and DBT_INTERNAL_SOURCE.`dbt_change_type` = 'insert'
        then insert (`customer_id`, `customer_first_name`, `customer_last_name`, `customer_email`, `customer_phone`, `customer_city`, `customer_province`, `customer_country`, `customer_created_timestamp`, `customer_updated_timestamp`, `customer_is_active`, `customer_processed_at`, `customer_gold_processed_at`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
        values (`customer_id`, `customer_first_name`, `customer_last_name`, `customer_email`, `customer_phone`, `customer_city`, `customer_province`, `customer_country`, `customer_created_timestamp`, `customer_updated_timestamp`, `customer_is_active`, `customer_processed_at`, `customer_gold_processed_at`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
    ;

  