COPY INTO
    ${snowflake_database}.${snowflake_schema}.${table_name} (${field_list})
FROM (
    SELECT
    ${source_list}
    FROM @${snowflake_database}.${snowflake_schema}.${snowflake_stage}/${s3_key_prefix_lvl_1}/${s3_key_prefix_lvl_2}
)