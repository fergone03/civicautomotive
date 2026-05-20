{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'id_venta'
    )
}}

{% if is_incremental() %}
{% set max_fecha_query %}
    select max(fecha_venta_sk) from {{ this }}
{% endset %}
{% set max_fecha = run_query(max_fecha_query).columns[0].values()[0] %}
{% endif %}

with venta as (
    select * from {{ ref('stg_coches__venta') }}

    {% if is_incremental() and max_fecha %}
        where cast(to_char(fecha_venta, 'YYYYMMDD') as integer) > {{ max_fecha }}
    {% endif %}
),

dim_vehiculo as (
    select * from {{ ref('dim_vehiculo') }}
),

dim_concesionario as (
    select * from {{ ref('dim_concesionario') }}
),

final as (
    select
        venta.venta_id                                              as id_venta,
        dim_vehiculo.vehiculo_sk,
        dim_concesionario.concesionario_sk,
        cast(to_char(venta.fecha_compra, 'YYYYMMDD') as integer)   as fecha_compra_sk,
        cast(to_char(venta.fecha_venta,  'YYYYMMDD') as integer)   as fecha_venta_sk,
        venta.precio_compra,
        venta.precio_venta,
        round(venta.precio_venta - venta.precio_compra, 2)         as margen,
        datediff('day', venta.fecha_compra, venta.fecha_venta)     as dias_stock
    from venta
    left join dim_vehiculo
        on venta.vehiculo_id = dim_vehiculo.id_vehiculo
    left join dim_concesionario
        on venta.concesionario_id = dim_concesionario.id_concesionario
)

select * from final