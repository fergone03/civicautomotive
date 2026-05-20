{% docs vehiculo_sk %}
Surrogate key de la dimensión vehículo generada con dbt_utils.generate_surrogate_key a partir del vehiculo_id. Es la PK de dim_vehiculo y la FK usada en fct_ventas.
{% enddocs %}

{% docs concesionario_sk %}
Surrogate key de la dimensión concesionario generada con dbt_utils.generate_surrogate_key a partir del concesionario_id. Es la PK de dim_concesionario y la FK usada en fct_ventas.
{% enddocs %}

{% docs fecha_sk %}
Surrogate key de fecha en formato YYYYMMDD (ej: 20230415). Es un entero que permite ordenación cronológica directa y es la PK de dim_fecha_compra y dim_fecha_venta.
{% enddocs %}

{% docs margen %}
Diferencia entre precio_venta y precio_compra expresada en la misma moneda. Puede ser negativo si la venta se realizó a pérdida. Durante el análisis de calidad de datos se encontraron registros con margen negativo — documentados en el test singular assert_precio_venta_mayor_compra.
{% enddocs %}

{% docs dias_stock %}
Número de días transcurridos entre la fecha de adquisición del vehículo por el concesionario (fecha_compra) y la fecha de venta al cliente final (fecha_venta). Indica la rotación del inventario. Un valor negativo indica un error en los datos — documentado en el test singular assert_fecha_venta_mayor_compra.
{% enddocs %}

{% docs surrogate_key %}
Identificador hash MD5 generado por dbt_utils.generate_surrogate_key a partir de una o varias columnas. Es reproducible — el mismo valor de entrada siempre produce el mismo hash — lo que permite reconstruir las relaciones entre tablas aunque se rebuilde el modelo desde cero.
{% enddocs %}

{% docs precio_venta %}
Precio de venta del vehículo al cliente final expresado en decimal. En Bronze llegaba como VARCHAR con posibles símbolos de moneda (€), comas como separador decimal y espacios. La limpieza se aplica en stg_coches__base con TRY_CAST después de eliminar los caracteres no numéricos. Si el valor original no era parseable el resultado es NULL.
{% enddocs %}

{% docs precio_compra %}
Precio de adquisición del vehículo por el concesionario expresado en decimal. Mismo proceso de limpieza que precio_venta aplicado en stg_coches__base.
{% enddocs %}