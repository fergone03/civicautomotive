with segmentos as (
    select 1 as segmento_sk, 'Económico'  as nombre, 0      as precio_min, 9999.99   as precio_max union all
    select 2,                'Medio',                 10000,                 24999.99 union all
    select 3,                'Premium',                25000,                 49999.99 union all
    select 4,                'Lujo',                   50000,                 9999999.99
)

select * from segmentos