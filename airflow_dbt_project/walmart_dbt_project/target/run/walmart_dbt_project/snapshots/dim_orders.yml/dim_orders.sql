
      merge into `walmart`.`gold`.`dim_orders` as DBT_INTERNAL_DEST
        using `dim_orders__dbt_tmp` as DBT_INTERNAL_SOURCE
    on DBT_INTERNAL_SOURCE.`dbt_scd_id` = DBT_INTERNAL_DEST.`dbt_scd_id`
    when matched
        and ( DBT_INTERNAL_DEST.`dbt_valid_to` = to_date('9999-12-31') or
                DBT_INTERNAL_DEST.`dbt_valid_to` is null )
        and DBT_INTERNAL_SOURCE.`dbt_change_type` in ('update', 'delete')
        then update
        set `dbt_valid_to` = DBT_INTERNAL_SOURCE.`dbt_valid_to`

    when not matched
        and DBT_INTERNAL_SOURCE.`dbt_change_type` = 'insert'
        then insert (`order_id`, `order_item_id`, `payment_method`, `order_status`, `order_timestamp`, `order_created_timestamp`, `order_updated_timestamp`, `order_is_active`, `order_processed_at`, `obt_b_processed_at`, `order_gold_processed_at`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
        values (`order_id`, `order_item_id`, `payment_method`, `order_status`, `order_timestamp`, `order_created_timestamp`, `order_updated_timestamp`, `order_is_active`, `order_processed_at`, `obt_b_processed_at`, `order_gold_processed_at`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
    ;

  