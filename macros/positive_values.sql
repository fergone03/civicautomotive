{% test positive_values(model, column_name) %}

select
    {{ column_name }} as valor_invalido
from {{ model }}
where {{ column_name }} is not null
  and {{ column_name }} <= 0

{% endtest %}