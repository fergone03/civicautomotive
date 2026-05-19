with base as (
    select distinct concesionario
    from {{ ref('int_coches__base') }}
    where concesionario is not null
),

seed as (
    select *
    from {{ ref('concesionarios') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['base.concesionario']) }}  as concesionario_id,
        base.concesionario                                               as nombre,
        {{ dbt_utils.generate_surrogate_key(['seed.concesionario']) }}  as direccion_id
    from base
    left join seed
        on base.concesionario = seed.concesionario
)

select * from final