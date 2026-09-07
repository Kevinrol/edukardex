# Reglas del Proyecto EduKardex

## 📋 Regla: Registro obligatorio de cambios en la base de datos

**Cualquier cambio aplicado a la base de datos de Supabase DEBE registrarse en el archivo
[`edukardex_schema.sql`](file:///c:/Users/dante/Documents/edukardex_registro_mvp/edukardex_schema.sql)**
dentro de la sección `CHANGELOG` al final del archivo.

### Formato obligatorio del registro

```sql
-- ------------------------------------------------------------
-- [YYYY-MM-DD] | Autor | TÍTULO BREVE DEL CAMBIO
-- ------------------------------------------------------------
-- MOTIVO: Explicar por qué se hizo el cambio.
--
-- TABLAS AFECTADAS: tabla1, tabla2, ...
--
-- ACCIÓN A FUTURO: (si aplica) qué se debe hacer después.
--
-- SQL EJECUTADO EN SUPABASE:
<pegar aquí el SQL exacto que se corrió>
-- ------------------------------------------------------------
```

### ¿Cuándo aplica esta regla?

- Creación o eliminación de tablas
- Modificación de columnas (`ALTER TABLE`)
- Creación o eliminación de políticas RLS
- Creación o modificación de funciones y triggers
- Inserción de datos iniciales o de catálogo
- Cambios de configuración (habilitar/deshabilitar RLS, extensiones, etc.)

### ¿Por qué?

El archivo `edukardex_schema.sql` es la **fuente de verdad** del estado de la base de datos.
Si la BD en Supabase y este archivo no están sincronizados, es imposible reproducir
el entorno o entender qué cambios se hicieron y por qué.
