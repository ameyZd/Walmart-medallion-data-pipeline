


SELECT 
    *,
    current_timestamp() AS processed_at
FROM 
    `walmart`.`bronze`.`products`
 


 
    WHERE updated_timestamp > (
        SELECT COALESCE(
            MAX(updated_timestamp),
            CAST('1900-01-01' AS TIMESTAMP)
        )
        FROM `walmart`.`silver_technical`.`products_t`
    )
