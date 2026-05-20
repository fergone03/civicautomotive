with base as (
    select distinct CONCESIONARIO as concesionario
    from {{ source('coches', 'COCHES_RAW') }}
    where CONCESIONARIO is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['concesionario']) }} as concesionario_id,
        concesionario                                              as nombre,
        {{ dbt_utils.generate_surrogate_key(['concesionario']) }} as direccion_id
    from base
)

select * from final
