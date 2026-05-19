with vehiculo as (
    select * from {{ ref('stg_coches__vehiculo') }}
),

modelo as (
    select * from {{ ref('stg_coches__modelo') }}
),

marca as (
    select * from {{ ref('stg_coches__marca') }}
),

tipo_vehiculo as (
    select * from {{ ref('stg_coches__tipo_vehiculo') }}
),

tamano as (
    select * from {{ ref('stg_coches__tamano_vehiculo') }}
),

final as (
    select
        vehiculo.vehiculo_id,
        vehiculo.vin,
        vehiculo.anio,
        vehiculo.kilometraje,
        vehiculo.motor_id,
        vehiculo.transmision_id,
        vehiculo.traccion_id,
        vehiculo.color_id,
        marca.nombre       as marca,
        modelo.nombre      as modelo,
        tipo_vehiculo.nombre as tipo_vehiculo,
        tamano.nombre      as tamano
    from vehiculo
    left join modelo
        on vehiculo.modelo_id = modelo.modelo_id
    left join marca
        on modelo.marca_id = marca.marca_id
    left join tipo_vehiculo
        on modelo.tipo_vehiculo_id = tipo_vehiculo.tipo_vehiculo_id
    left join tamano
        on modelo.tamano_id = tamano.tamano_id
)

select * from final
