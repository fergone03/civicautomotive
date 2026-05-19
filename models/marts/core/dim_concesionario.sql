with final as (
    select
        {{ dbt_utils.generate_surrogate_key(['concesionario_id']) }}  as concesionario_sk,
        concesionario_id                                               as id_concesionario,
        concesionario,
        calle,
        codigo_postal,
        ciudad,
        region,
        pais,
        latitud,
        longitud
    from {{ ref('int_concesionario__completo') }}
)

select * from final