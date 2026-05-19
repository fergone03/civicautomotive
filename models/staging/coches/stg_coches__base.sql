with source as (

    select * from {{ source('coches', 'COCHES_RAW') }}

),

renamed as (

    select
        -- identificador
        ID                                                    as ID_RAW,

        -- atributos del vehículo
        ANIO                                                  as anio,
        MARCA                                                 as marca,
        MODELO                                                as modelo,
        MOTOR                                                 as motor,
        COMBUSTIBLE                                           as combustible,
        TRANSMISION                                           as transmision,
        TRACCION                                              as traccion,
        TAMANO                                                as tamano,
        TIPO_VEHICULO                                         as tipo_vehiculo,
        COLOR                                                 as color,
        VIN                                                   as vin,
        KILOMETRAJE                                           as kilometraje,
        ESTADO                                                as estado,

        -- documentación
        ESTADO_DOCUMENTACION                                  as estado_documentacion,

        -- concesionario
        CONCESIONARIO                                         as concesionario,
        CALLE                                                 as calle,
        CODIGO_POSTAL                                         as codigo_postal,
        LATITUD                                               as latitud,
        LONGITUD                                              as longitud,

        -- precios: limpieza de varchar sucio
        try_cast(
            replace(replace(replace(PRECIO_VENTA, '€', ''), ',', '.'), ' ', '')
            as decimal(10,2)
        )                                                     as precio_venta,

        try_cast(
            replace(replace(replace(PRECIO_COMPRA, '€', ''), ',', '.'), ' ', '')
            as decimal(10,2)
        )                                                     as precio_compra,

        -- fechas
        FECHA_COMPRA                                          as fecha_compra,
        FECHA_VENTA                                           as fecha_venta

    from source

)

select * from renamed