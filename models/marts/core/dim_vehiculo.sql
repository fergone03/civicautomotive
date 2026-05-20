with final as (
    select
        {{ dbt_utils.generate_surrogate_key(['vehiculo_id']) }}  as vehiculo_sk,
        vehiculo_id                                               as id_vehiculo,
        marca,
        modelo,
        tipo_vehiculo,
        tamano,
        motor,
        combustible,
        transmision,
        traccion,
        color
    from {{ ref('int_vehiculo__completo') }}
)

select * from final