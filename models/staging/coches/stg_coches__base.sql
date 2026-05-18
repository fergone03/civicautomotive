with 

source as (

    select * from {{ source('coches', 'COCHES_RAW') }}

),

renamed as (

    select
        id,
        anio,
        marca,
        modelo,
        estado,
        motor,
        combustible,
        kilometraje,
        estado_documentacion,
        transmision,
        vin,
        traccion,
        tamano,
        tipo_vehiculo,
        color,
        fecha_venta,
        fecha_compra,
        concesionario,
        calle,
        codigo_postal,
        latitud,
        longitud,
        precio_venta,
        precio_compra

    from source

)

select * from renamed