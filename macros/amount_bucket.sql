{% macro amount_bucket(column_name)%}

    CASE 
        WHEN {{ column_name }} IS NULL THEN 'UNKNOWN'
        WHEN {{ column_name }} < 0 THEN 'INVALID'
        WHEN {{ column_name }} < 50 THEN 'LOW'
        WHEN {{ column_name }} < 200 THEN 'MEDIUM'
        WHEN {{ column_name }} < 1000 THEN 'HIGH'
        ELSE 'VERY_HIGH'
    END

{% endmacro %}