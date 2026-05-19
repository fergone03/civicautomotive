with base as (
    select distinct
        modelo,
        marca,
        tipo_vehiculo,
        tamano
    from {{ ref('int_coches__base') }}
    where modelo is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['modelo', 'marca']) }}     as modelo_id,
        modelo                                                            as nombre,
        {{ dbt_utils.generate_surrogate_key(['marca']) }}                as marca_id,
        {{ dbt_utils.generate_surrogate_key(['tipo_vehiculo']) }}        as tipo_vehiculo_id,
        {{ dbt_utils.generate_surrogate_key(['tamano']) }}               as tamano_id
    from base
)

select * from final