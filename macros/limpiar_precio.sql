{% macro limpiar_precio(columna) %}
    try_cast(
        replace(replace(replace({{ columna }}, '€', ''), ',', '.'), ' ', '')
        as decimal(10,2)
    )
{% endmacro %}
