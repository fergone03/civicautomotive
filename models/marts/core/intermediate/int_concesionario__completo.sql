with concesionario as (
    select * from {{ ref('stg_coches__concesionario') }}
),

direccion as (
    select * from {{ ref('stg_coches__direccion') }}
),

ciudad as (
    select * from {{ ref('stg_coches__ciudad') }}
),

region as (
    select * from {{ ref('stg_coches__region') }}
),

pais as (
    select * from {{ ref('stg_coches__pais') }}
),

final as (
    select
        concesionario.concesionario_id,
        concesionario.nombre            as concesionario,
        direccion.calle,
        direccion.codigo_postal,
        ciudad.nombre                   as ciudad,
        region.nombre                   as region,
        pais.nombre                     as pais,
        direccion.latitud,
        direccion.longitud
    from concesionario
    left join direccion
        on concesionario.direccion_id = direccion.direccion_id
    left join ciudad
        on direccion.ciudad_id = ciudad.ciudad_id
    left join region
        on ciudad.region_id = region.region_id
    left join pais
        on region.pais_id = pais.pais_id
)

select * from final