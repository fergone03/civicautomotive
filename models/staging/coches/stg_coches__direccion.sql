with seed as (
    select
        concesionario,
        calle,
        codigo_postal,
        ciudad,
        latitud,
        longitud
    from {{ ref('concesionarios') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['concesionario']) }}   as direccion_id,
        calle,
        codigo_postal,
        {{ dbt_utils.generate_surrogate_key(['ciudad']) }}          as ciudad_id,
        latitud,
        longitud
    from seed
)

select * from final