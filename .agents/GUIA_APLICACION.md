# Guía funcional de EduKardex

Documento de referencia para agentes: qué debe hacer la aplicación, qué está implementado y qué falta. Mantenerlo actualizado cuando se agregue o conecte un módulo.

## Propósito

EduKardex ("Tu Conexión Escolar") es una app móvil de gestión académica y de convivencia para colegios. Digitaliza el ciclo **Registro → Kardex → Reportes**: registrar la comunidad educativa, abrir un kardex por estudiante y trimestre, anotar incumplimientos y notificar a los responsables.

Cada colegio es un tenant aislado: todos los datos operativos cuelgan de `colegio_id`.

## Alcance implementado hoy

- Splash de 3 segundos y panel administrador con listado de colegios y alta de colegio.
- Detalle de colegio con tabs de **Gestiones** y **Cursos**.
- Alta de gestión académica con año, fechas y los 3 trimestres; listado de gestiones.
- Alta de curso con nombre, paralelo, nivel y gestión; listado de cursos por colegio.
- Servicios y modelos Supabase para colegios, gestiones/trimestres, cursos, estudiantes y docentes.

Pantallas que existen pero **no están enlazadas** al flujo: selección de tipo de registro, alta/listado de estudiantes y alta de docente. El alta de estudiante usa un `colegio_id` placeholder (`000...`) y el alta de docente usa `usuario_id`/`colegio_id` placeholder; no completan un registro válido contra el schema y tampoco asignan curso ni gestión.

## Roles previstos

- **administrativo**: configura el colegio, gestiones, cursos y registros; consulta reportes.
- **director**: supervisa la información del colegio.
- **docente**: registra incumplimientos de sus cursos.
- **responsable** (padre/madre/tutor): consulta y recibe notificaciones.

Todavía no hay login ni autorización por rol. La app opera como anónimo con políticas RLS temporales.

## Entidades y reglas de negocio

- **Colegio**: raíz del sistema, con datos de contacto, director y estado activo.
- **Gestión académica**: año lectivo con fechas de inicio/fin y estado activo. Única por `(colegio, año)`.
- **Trimestre**: exactamente 3 por gestión, numerados 1–3, con fechas propias.
- **Curso**: pertenece a un colegio y una gestión; tiene nombre, paralelo, nivel y docente guía opcional.
- **Estudiante**: nombres, apellidos, CI y fecha de nacimiento. La CI es única **por colegio**, no global.
- **Matrícula** (`curso_estudiante`): un estudiante tiene un solo curso por gestión.
- **Responsable**: datos de contacto del tutor; se relaciona con estudiantes mediante `estudiante_responsable` (puede haber varios, uno principal).
- **Kardex**: uno por estudiante y trimestre; guarda observaciones generales.
- **Incumplimiento**: falta de un estudiante en un kardex, registrada por un docente, con tipo, fecha, descripción, gravedad (`leve`, `grave`, `muy_grave`) y acción tomada.
- **Notificación**: al insertar un incumplimiento, un trigger crea una notificación pendiente por cada responsable del estudiante. Canales: `push`, `email`, `sms`; estados: `pendiente`, `enviado`, `fallido`.

## Flujos objetivo

1. **Configuración**: colegio → gestión con 3 trimestres → cursos → docentes.
2. **Registro**: alta de estudiante con datos personales, tutor/responsable y asignación a curso y gestión.
3. **Kardex**: apertura del kardex del estudiante en el trimestre y registro de incumplimientos.
4. **Notificación**: generación automática de avisos pendientes y actualización de estado tras el envío real.
5. **Reportes**: consultas por estudiante, curso, trimestre, fecha o gravedad.

## Interfaz

- Móvil Android, textos en español, Material 3 y tipografía Poppins.
- Paleta institucional en `lib/theme/app_theme.dart`: azul `#1c2f57`, con colores de estado para éxito, alerta y error.
- Formularios con validación de campos obligatorios, errores por `SnackBar`, listas con pull-to-refresh y estados vacíos.
- Estilo visual predominante: header azul, tarjeta blanca redondeada y botones de acción al pie.

## Fuera de alcance por ahora

- Autenticación real y RLS por colegio/rol.
- Envío efectivo de push/SMS/email (no hay Edge Function ni webhook en el repo).
- Edición de estudiantes, carga de fotos o documentos.
- Reportes exportables y funcionamiento offline.
