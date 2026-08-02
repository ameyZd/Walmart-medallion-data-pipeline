
      merge into `walmart`.`gold`.`dim_stores` as DBT_INTERNAL_DEST
        using `dim_stores__dbt_tmp` as DBT_INTERNAL_SOURCE
    on DBT_INTERNAL_SOURCE.`dbt_scd_id` = DBT_INTERNAL_DEST.`dbt_scd_id`
    when matched
        and ( DBT_INTERNAL_DEST.`dbt_valid_to` = to_date('9999-12-31') or
                DBT_INTERNAL_DEST.`dbt_valid_to` is null )
        and DBT_INTERNAL_SOURCE.`dbt_change_type` in ('update', 'delete')
        then update
        set `dbt_valid_to` = DBT_INTERNAL_SOURCE.`dbt_valid_to`

    when not matched
        and DBT_INTERNAL_SOURCE.`dbt_change_type` = 'insert'
        then insert (`store_id`, `store_name`, `store_city`, `store_province`, `store_country`, `store_created_timestamp`, `store_updated_timestamp`, `store_is_active`, `store_processed_at`, `store_gold_processed_at`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
        values (`store_id`, `store_name`, `store_city`, `store_province`, `store_country`, `store_created_timestamp`, `store_updated_timestamp`, `store_is_active`, `store_processed_at`, `store_gold_processed_at`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
    ;

  