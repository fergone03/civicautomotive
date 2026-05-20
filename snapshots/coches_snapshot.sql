{% snapshot coches_snapshot %}

{{
    config(
        target_schema='snapshots',
        target_database=env_var('DBT_ENVIRONMENTS') ~ '_SILVER_DB',
        unique_key='ID',
        strategy='check',
        check_cols=[
            'ESTADO',
            'KILOMETRAJE',
            'ESTADO_DOCUMENTACION',
            'PRECIO_VENTA',
            'PRECIO_COMPRA'
        ]
    )
}}

select
    ID,
    VIN,
    ESTADO,
    KILOMETRAJE,
    ESTADO_DOCUMENTACION,
    PRECIO_VENTA,
    PRECIO_COMPRA,
    FECHA_COMPRA,
    FECHA_VENTA,
    CONCESIONARIO
from {{ source('coches', 'COCHES_RAW') }}

{% endsnapshot %}