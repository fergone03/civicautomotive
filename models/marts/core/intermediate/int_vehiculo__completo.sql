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

motor as (
    select * from {{ ref('stg_coches__motor') }}
),

combustible as (
    select * from {{ ref('stg_coches__combustible') }}
),

transmision as (
    select * from {{ ref('stg_coches__transmision') }}
),

traccion as (
    select * from {{ ref('stg_coches__traccion') }}
),

color as (
    select * from {{ ref('stg_coches__color') }}
),

final as (
    select
        vehiculo.vehiculo_id,
        vehiculo.vin,
        vehiculo.anio,
        vehiculo.kilometraje,
        marca.nombre                as marca,
        modelo.nombre               as modelo,
        tipo_vehiculo.nombre        as tipo_vehiculo,
        tamano.nombre               as tamano,
        motor.descripcion           as motor,
        combustible.nombre          as combustible,
        transmision.nombre          as transmision,
        traccion.nombre             as traccion,
        color.nombre                as color
    from vehiculo
    left join modelo
        on vehiculo.modelo_id = modelo.modelo_id
    left join marca
        on modelo.marca_id = marca.marca_id
    left join tipo_vehiculo
        on modelo.tipo_vehiculo_id = tipo_vehiculo.tipo_vehiculo_id
    left join tamano
        on modelo.tamano_id = tamano.tamano_id
    left join motor
        on vehiculo.motor_id = motor.motor_id
    left join combustible
        on motor.combustible_id = combustible.combustible_id
    left join transmision
        on vehiculo.transmision_id = transmision.transmision_id
    left join traccion
        on vehiculo.traccion_id = traccion.traccion_id
    left join color
        on vehiculo.color_id = color.color_id
)

select * from final