# Civicautomotive · 



> Plataforma de datos end-to-end para analizar el negocio de venta de vehículos de Civicautomotive. Implementa arquitectura **Medallion** (Bronze → Silver → Gold) sobre **Snowflake** usando **dbt** como motor de transformación, con SCD2, modelos incrementales, gobernanza con `dbt_project_evaluator` y testing en las tres capas.

![dbt](https://img.shields.io/badge/dbt-1.10-orange) ![Snowflake](https://img.shields.io/badge/Snowflake-cloud-29B5E8) ![License](https://img.shields.io/badge/license-internal-lightgrey) ![Tests](https://img.shields.io/badge/tests-60%2B-success)

---

## 🎬 Presentación interactiva

> **Ver la presentación →** [**https://civicautomotive.netlify.app**](https://civicautomotive.netlify.app)

La presentación es **interactiva** e incluye dos terminales en vivo y un canvas navegable. Antes de empezar:

### 🖥️ Terminal 1 · tema hacker
Es una terminal libre con estética hacker. **Escribe lo que quieras** — comandos, frases, lo que se te ocurra. Está pensada para experimentar mientras se explica.

### 🖥️ Terminal 2 · `dbt build`
Ejecuta el comando:

```bash
dbt build
```

Aparecerán los errores **tal y como salieron en dbt durante el desarrollo** — los tests fallidos sobre precios sucios, VINs duplicados, márgenes negativos, etc. Sirve para ver el flujo real de detección de problemas de calidad de datos.

### 🖱️ A partir de la slide 15
Algunas slides pueden mostrar **errores de resolución** porque el canvas es más grande que la pantalla. No es un bug — **al ser un canvas, solo hay que arrastrar con el ratón** para moverse por él y ver el contenido completo.

---

## Tabla de contenidos

1. [Visión general](#vision-general)
2. [Arquitectura Medallion](#arquitectura-medallion)
3. [Stack y dependencias](#stack-y-dependencias)
4. [Estructura del repositorio](#estructura-del-repositorio)
5. [Modelo dimensional](#modelo-dimensional)
6. [Ingesta en Bronze](#ingesta-en-bronze)
7. [Multi-entorno (DEV / PRO)](#multi-entorno-dev--pro)
8. [Modelos incrementales](#modelos-incrementales)
9. [SCD Tipo 2](#scd-tipo-2)
10. [Testing y calidad de datos](#testing-y-calidad-de-datos)
11. [Gobernanza · `dbt_project_evaluator`](#gobernanza--dbt_project_evaluator)
12. [Cómo ejecutar el proyecto](#como-ejecutar-el-proyecto)
13. [Documentación generada](#documentacion-generada)
14. [Decisiones de arquitectura](#decisiones-de-arquitectura)

---

## Visión general

Civicautomotive es un concesionario multi-región. El dato llega como un **CSV plano y sucio** (precios con `€`, comas decimales, VINs inválidos, kilometrajes corruptos) que hay que convertir en un modelo dimensional **listo para BI**.

Este repositorio lo hace:

| Métrica | Valor |
|---|---|
| Fuentes | 1 (`COCHES_RAW` en Snowflake) |
| Modelos staging | 15 |
| Modelos intermediate | 4 |
| Dimensiones | 4 (vehículo, concesionario, fecha compra, fecha venta) |
| Tablas de hechos | 1 (`fct_ventas` incremental) |
| Snapshots SCD2 | 1 (cambios de estado / km / precios) |
| Seeds | 2 (concesionarios + excepciones de gobernanza) |
| Tests (genéricos + singulares) | 60+ en tres capas |
| Paquetes dbt | 4 (`dbt_utils`, `codegen`, `dbt_expectations`, `elementary`) |

---

## Arquitectura Medallion

```
                 ┌─────────────┐      ┌──────────────────┐      ┌────────────────┐
   CSV  ───────► │   BRONZE    │ ───► │     SILVER       │ ───► │     GOLD       │
                 │ COCHES_RAW  │      │ staging (15)     │      │ dims + fct     │
                 │  + seeds    │      │ intermediate (4) │      │  + intermediate │
                 │             │      │ snapshot SCD2    │      │                │
                 └─────────────┘      └──────────────────┘      └────────────────┘
                  raw, sin tocar       normalizado 3FN           star schema
```

| Capa | Objetivo | Materialización | DB en Snowflake |
|---|---|---|---|
| **Bronze** | Aterrizaje del CSV sin transformar | Table | `*_BRONZE_DB` |
| **Silver** | Normalización 3FN, surrogate keys, snapshot SCD2 | View (staging) / Table (snapshot) | `*_SILVER_DB` |
| **Gold** | Esquema en estrella para analítica | Table (dims/fct), View (intermediate) | `*_GOLD_DB` |

> Cada capa vive en una **base de datos separada de Snowflake**. El dato nunca retrocede.

---

## Stack y dependencias

```yaml
# packages.yml
- dbt-labs/dbt_utils          (>=1.3.3, <2.0.0)   # generate_surrogate_key, helpers
- dbt-labs/codegen            (>=0.12.0, <1.0.0)  # autogeneración de YAMLs
- metaplane/dbt_expectations  (>=0.10.0, <1.0.0)  # tests tipo Great Expectations
- elementary-data/elementary  (>=0.14.0, <1.0.0)  # observabilidad y anomalías
```

Más, integrado pero opcional: `dbt_project_evaluator` para auditoría continua de antipatrones (fanout, fuentes sin freshness, joins indebidos).

---

## Estructura del repositorio

```
civicautomotive/
├── dbt_project.yml                  # configuración global, materializations, env_vars
├── packages.yml                     # dependencias
│
├── macros/
│   ├── generate_schema_name.sql     # override del schema naming
│   ├── limpiar_precio.sql           # macro reutilizable: VARCHAR sucio → DECIMAL
│   └── positive_values.sql          # test genérico custom
│
├── models/
│   ├── staging/coches/              # 15 stagings (3FN sobre el source)
│   │   ├── __sources.yml            # contrato del CSV + tests Bronze
│   │   ├── __models.yml             # docs + tests Silver
│   │   ├── stg_coches__marca.sql
│   │   ├── stg_coches__modelo.sql
│   │   ├── stg_coches__vehiculo.sql
│   │   ├── stg_coches__venta.sql
│   │   └── ...
│   │
│   └── marts/core/
│       ├── intermediate/            # joins progresivos
│       │   ├── int_vehiculo__atributos.sql
│       │   ├── int_vehiculo__completo.sql
│       │   ├── int_concesionario__completo.sql
│       │   └── int_fechas__ventas.sql
│       ├── dim_vehiculo.sql
│       ├── dim_concesionario.sql
│       ├── dim_fecha_compra.sql
│       ├── dim_fecha_venta.sql
│       └── fct_ventas.sql           # ← INCREMENTAL (merge sobre id_venta)
│
├── snapshots/
│   └── coches_snapshot.sql          # SCD2 (estrategia check)
│
├── seeds/
│   ├── concesionarios.csv                       # jerarquía geográfica enriquecida
│   └── dbt_project_evaluator_exceptions.csv     # excepciones documentadas
│
├── tests/singular/                  # tests de lógica de negocio
│   ├── assert_fecha_venta_mayor_compra.sql
│   └── assert_precio_venta_mayor_compra.sql
│
└── docs/_core__docs.md              # docs blocks para columnas clave
```

---

## Modelo dimensional

```
                       dim_fecha_compra
                              │
                              │ fecha_compra_sk
                              ▼
       dim_vehiculo ─────► fct_ventas ◄───── dim_concesionario
       vehiculo_sk            │              concesionario_sk
                              │
                              │ fecha_venta_sk
                              ▼
                       dim_fecha_venta
```

### 📐 Capa semántica · regla de negocio clave

> **Un coche con `fecha_compra` pero sin `fecha_venta` se considera *en inventario en nuestros concesionarios — todavía no vendido*.** No es una venta cerrada.

Esto define la semántica del grain de `fct_ventas`:

| `fecha_compra` | `fecha_venta` | Significado de negocio |
|---|---|---|
| ✅ | ✅ | **Venta cerrada** — métricas (`margen`, `dias_stock`) totalmente calculables. |
| ✅ | ❌ NULL | **Coche en inventario** — adquirido por el concesionario pero aún no vendido. `margen` y `dias_stock` son NULL. |
| ❌ NULL | ✅ | Error de datos — venta sin compra registrada. Lo recoge el test singular `assert_fecha_venta_mayor_compra`. |
| ❌ NULL | ❌ NULL | Registro sin información temporal. Se conserva por id_raw pero queda fuera de análisis temporal. |

> Para queries de **"ventas reales"** filtrar por `fecha_venta_sk is not null`. Para queries de **"stock actual"** filtrar por `fecha_compra_sk is not null and fecha_venta_sk is null`.

**`fct_ventas` (grain = una venta):**

| Columna | Tipo | Origen |
|---|---|---|
| `id_venta` | varchar (sk) | `generate_surrogate_key(['ID'])` |
| `vehiculo_sk` | varchar | FK → `dim_vehiculo` |
| `concesionario_sk` | varchar | FK → `dim_concesionario` |
| `fecha_compra_sk` | integer (YYYYMMDD) | cast directo |
| `fecha_venta_sk` | integer (YYYYMMDD) | cast directo |
| `precio_compra` | decimal(10,2) | `limpiar_precio()` |
| `precio_venta` | decimal(10,2) | `limpiar_precio()` |
| `margen` | decimal | `precio_venta − precio_compra` |
| `dias_stock` | integer | `datediff('day', fecha_compra, fecha_venta)` |

---

## Ingesta en Bronze

El CSV se sube a Snowflake con `snowsql` siguiendo el patrón estándar **PUT → COPY INTO**:

```sql
-- 1. File format reutilizable
CREATE OR REPLACE FILE FORMAT coches_csv
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL');

-- 2. Stage interno
CREATE OR REPLACE STAGE coches_stage FILE_FORMAT = coches_csv;

-- 3. Subir el CSV desde local
PUT file://coches.csv @coches_stage;

-- 4. Cargar a la tabla raw
COPY INTO DEV_BRONZE_DB.PUBLIC.COCHES_RAW
    FROM @coches_stage/coches.csv.gz
    ON_ERROR = CONTINUE;
```

> Los precios entran como `VARCHAR` **a propósito**. La limpieza se hace en Silver con la macro `limpiar_precio` para no perder filas en la ingesta.

---

## Multi-entorno (DEV / PRO)

Una sola variable de entorno (`DBT_ENVIRONMENTS`) determina la base de datos de cada capa. Cero duplicación de código entre entornos:

```yaml
# dbt_project.yml — extracto
models:
  civicautomotive:
    staging:
      coches:
        +database: "{{ env_var('DBT_ENVIRONMENTS') }}_SILVER_DB"
    marts:
      core:
        +database: "{{ env_var('DBT_ENVIRONMENTS') }}_GOLD_DB"
seeds:
  civicautomotive:
    +database: "{{ env_var('DBT_ENVIRONMENTS', 'FAIL') }}_BRONZE_DB"
```

| Capa | DEV | PRO |
|---|---|---|
| Bronze | `DEV_BRONZE_DB` | `PRO_BRONZE_DB` |
| Silver | `DEV_SILVER_DB` | `PRO_SILVER_DB` |
| Gold | `DEV_GOLD_DB` | `PRO_GOLD_DB` |

**Beneficios:** portabilidad, aislamiento total entre entornos, despliegue homogéneo desde dbt Cloud y fail-fast (`'FAIL'` como default obliga a definir la variable).

---

## Modelos incrementales

`fct_ventas` es el único modelo **incremental** del proyecto. Procesa solo las ventas nuevas desde la última ejecución, pasando de **O(N)** a **O(ΔN)**.

```sql
{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = 'id_venta'
) }}

{% if is_incremental() %}
    {% set max_fecha_query %}
        select max(fecha_venta_sk) from {{ this }}
    {% endset %}
    {% set max_fecha = run_query(max_fecha_query).columns[0].values()[0] %}
{% endif %}

with venta as (
    select * from {{ ref('stg_coches__venta') }}

    {% if is_incremental() and max_fecha %}
        where cast(to_char(fecha_venta, 'YYYYMMDD') as integer) > {{ max_fecha }}
    {% endif %}
)
...
```

**Cómo funciona el WHERE:**

- **Primera ejecución** → la tabla destino no existe → `is_incremental()` = `false` → el WHERE no se aplica → carga completa.
- **Ejecuciones siguientes** → `is_incremental()` = `true` → dbt corre `select max(fecha_venta_sk) from {{ this }}` y lo inyecta como literal en el WHERE. Snowflake solo escanea filas posteriores.
- **`merge` + `unique_key`** → si llega un `id_venta` ya existente (corrección retroactiva), se actualiza la fila en lugar de duplicarla. Operación **idempotente**.

> Si llega una venta retroactiva con fecha anterior al máximo procesado, se rebuilda con `dbt run --select fct_ventas --full-refresh`.

---

## SCD Tipo 2

`coches_snapshot` captura los cambios temporales sobre atributos volátiles de `COCHES_RAW`:

```sql
{{ config(
    target_schema='snapshots',
    target_database=env_var('DBT_ENVIRONMENTS') ~ '_SILVER_DB',
    unique_key='ID',
    strategy='check',
    check_cols=['ESTADO', 'KILOMETRAJE', 'ESTADO_DOCUMENTACION',
                'PRECIO_VENTA', 'PRECIO_COMPRA']
) }}
```

- **Estrategia `check`** porque el CSV **no tiene `updated_at`** fiable.
- Cada cambio en las columnas vigiladas cierra la fila anterior (`dbt_valid_to`) y abre una nueva.
- Como red de seguridad adicional → **Time Travel** de Snowflake.

---

## Testing y calidad de datos

Tests en las tres capas. El pipeline solo avanza si los tests anteriores pasan.

### Bronze (`__sources.yml`)
- `unique` + `not_null` sobre PK del CSV.
- **regex** sobre `PRECIO_VENTA` / `PRECIO_COMPRA` → detecta `€`, comas y espacios.
- **rangos** sobre `ANIO` (1990–2030), `LATITUD` (−90/90), `LONGITUD` (−180/180).
- **longitud exacta** del `VIN` = 17 (`dbt_expectations`).
- `accepted_values` sobre todos los categóricos.

### Silver (`__models.yml`)
- PKs únicas y no nulas en todas las entidades.
- **FKs validadas con `relationships`** entre stagings.
- `generate_surrogate_key` siempre protegido con `CASE WHEN` para no generar hashes a partir de NULL.

### Gold + singular tests
```sql
-- tests/singular/assert_fecha_venta_mayor_compra.sql
select venta_id, fecha_compra, fecha_venta
from {{ ref('stg_coches__venta') }}
where fecha_compra is not null
  and fecha_venta  is not null
  and fecha_venta  < fecha_compra
```

### Observabilidad
```yaml
tests:
  +severity: error
  +store_failures: true
  +store_failures_as: view
```

Las filas que fallan se persisten como views en Snowflake (`schema dbt_test__audit`) → debug directo con SQL.

### Test genérico custom
```sql
-- macros/positive_values.sql
{% test positive_values(model, column_name) %}
select {{ column_name }} as valor_invalido
from {{ model }}
where {{ column_name }} is not null and {{ column_name }} <= 0
{% endtest %}
```

---

## Gobernanza · `dbt_project_evaluator`

El proyecto **cumple** las reglas estructurales de `dbt_project_evaluator`:

- `staging/` solo lee de `source()`.
- `intermediate/` solo lee de `staging/`.
- No hay `int_*` en `staging/`.
- Sin fanout en stagings (>1 hijo directo se evita con `int_fechas__ventas`).

Las excepciones legítimas se documentan en un seed:

```csv
fct_name,model_name,reason
fct_sources_without_freshness,coches.COCHES_RAW,CSV estático sin actualizaciones periódicas. Freshness no aplica.
fct_source_fanout,coches.COCHES_RAW,Normalización intencional de un CSV plano en 12 entidades.
```

> Las excepciones se aplican **solo donde están justificadas**. Cualquier futuro modelo que viole una regla seguirá apareciendo en el reporte.

---

## Cómo ejecutar el proyecto

### Pre-requisitos
- Python 3.10+ con `dbt-snowflake` instalado.
- Acceso a una cuenta Snowflake con permisos sobre los DBs `*_BRONZE_DB`, `*_SILVER_DB`, `*_GOLD_DB`.
- Variable de entorno `DBT_ENVIRONMENTS` definida (`DEV` o `PRO`).

### Ingesta inicial (una sola vez)
```bash
# Subir el CSV a Bronze
snowsql -f scripts/load_bronze.sql
```

### Pipeline completo
```bash
# Instalar paquetes
dbt deps

# Cargar seeds (concesionarios + excepciones)
dbt seed

# Snapshot SCD2
dbt snapshot

# Build completo (modelos + tests + snapshots) en orden topológico
dbt build
```

### Comandos útiles
```bash
# Solo capa staging
dbt run --select staging

# Reconstruir fct_ventas desde cero
dbt run --select fct_ventas --full-refresh

# Solo tests sobre Bronze
dbt test --select source:coches

# Generar documentación
dbt docs generate && dbt docs serve
```

### CI/CD (dbt Cloud)
El job de producción se dispara automáticamente al hacer **merge a `main`**. Encadena:

```
dbt deps → dbt seed → dbt snapshot → dbt build
```

Si cualquier test falla, el job rompe y el dato malo **no llega a Gold**.

---

## Documentación generada

Cada modelo, cada columna y cada test están documentados en YAML. Los términos de negocio reutilizables viven en `docs/_core__docs.md` como **doc blocks**:

```jinja
{% docs vehiculo_sk %}
Surrogate key de la dimensión vehículo generada con
dbt_utils.generate_surrogate_key a partir del vehiculo_id...
{% enddocs %}
```

Y se referencian desde el YAML con `'{{ doc("vehiculo_sk") }}'`. Esto evita duplicar descripciones entre dim y fct.

---

## Decisiones de arquitectura

Las seis decisiones más relevantes del diseño:

### 1. Sin `stg_coches__base` intermedio
- **Qué hago**: cada staging lee directamente de `source()`. La limpieza de precios vive en la macro `limpiar_precio`.
- **Por qué**: el evaluador marca como antipatrón que un staging lea de otro staging. Concentrar la lógica de limpieza en una macro reutilizable es más limpio y respeta las reglas.

### 2. Pipeline de vehículo en dos pasos
- **Qué hago**: `int_vehiculo__atributos` (5 joins básicos) → `int_vehiculo__completo` (5 joins extra).
- **Por qué**: dos pasos cortos son más legibles y debuggables que uno con 10 joins. Si mañana otra dimensión solo necesita atributos básicos, `int_vehiculo__atributos` ya está listo.

### 3. Intermediate `int_fechas__ventas`
- **Qué hago**: las dos `dim_fecha_*` leen de `int_fechas__ventas`, no de `stg_coches__venta`.
- **Por qué**: `stg_coches__venta` tenía 3 hijos directos (fanout). Con el intermediate baja a 1 hijo directo y el antipatrón desaparece.

### 4. `fct_ventas` incremental con `merge` por `id_venta`
- **Qué hago**: estrategia `merge` con `unique_key` y filtro por `max(fecha_venta_sk)`.
- **Por qué**: `merge` protege contra reprocesos accidentales (idempotente); comparar `fecha_venta_sk` (integer YYYYMMDD) es más rápido que comparar fechas.

### 5. SCD2 con estrategia `check`, no `timestamp`
- **Qué hago**: vigilo el hash de las 5 columnas que sí cambian (`ESTADO`, `KILOMETRAJE`, `ESTADO_DOCUMENTACION`, `PRECIO_*`).
- **Por qué**: el CSV no tiene un `updated_at` fiable. `check` es más caro pero correcto. Time Travel de Snowflake da la red de seguridad operacional.

### 6. Surrogate keys con `CASE WHEN`
- **Qué hago**: `case when col is null then null else generate_surrogate_key(['col']) end as col_id`.
- **Por qué**: si una columna que entra en el hash es NULL, dbt generaría un hash "válido" que pasaría el test `unique` pero apuntaría a nada. El `CASE WHEN` garantiza que un ID solo existe si sus componentes existen.

### 7. Limpiar sin ocultar
- **Qué hago**: `try_cast` en `limpiar_precio` y NULLs honestos cuando un valor no se puede parsear.
- **Por qué**: prefiero un NULL documentado a un 0 mentiroso que sesga métricas. Los singular tests (`assert_precio_venta_mayor_compra`, `assert_fecha_venta_mayor_compra`) actúan como **contratos de calidad** sobre el dato.

---

## Filosofía

> **Data quality first.** Un test que falla bloquea el deploy a Gold. Mejor que el pipeline rompa en CI a que un dashboard muestre dato malo en producción.

---

## Recursos dbt

- [Documentación oficial](https://docs.getdbt.com/docs/introduction)
- [Discourse · preguntas frecuentes](https://discourse.getdbt.com/)
- [Comunidad dbt](https://getdbt.com/community)
- [Blog dbt](https://blog.getdbt.com/)
