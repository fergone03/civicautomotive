with source as (
    select distinct
        MODELO         as modelo,
        MARCA          as marca,
        TIPO_VEHICULO  as tipo_vehiculo,
        TAMANO         as tamano
    from {{ source('coches', 'COCHES_RAW') }}
    where MODELO is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['modelo', 'marca']) }}  as modelo_id,
        modelo                                                         as nombre,
        {{ dbt_utils.generate_surrogate_key(['marca']) }}             as marca_id,
        {{ dbt_utils.generate_surrogate_key(['tipo_vehiculo']) }}     as tipo_vehiculo_id,
        {{ dbt_utils.generate_surrogate_key(['tamano']) }}            as tamano_id
    from source
)

select * from final
