with source as (
    select distinct
        MODELO         as modelo,
        MARCA          as marca,
        TIPO_VEHICULO  as tipo_vehiculo,
        TAMANO         as tamano
    from {{ source('coches', 'COCHES_RAW') }}
    where MODELO is not null and MARCA is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['modelo', 'marca', 'tipo_vehiculo', 'tamano']) }}  as modelo_id,
        modelo                                                                                    as nombre,
        {{ dbt_utils.generate_surrogate_key(['marca']) }}                                        as marca_id,
        case when tipo_vehiculo is null then null else {{ dbt_utils.generate_surrogate_key(['tipo_vehiculo']) }} end as tipo_vehiculo_id,
        case when tamano        is null then null else {{ dbt_utils.generate_surrogate_key(['tamano']) }}        end as tamano_id
    from source
)

select * from final