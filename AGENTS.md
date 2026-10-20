# AGENTS.md

EduKardex es una app Flutter (solo Android) + Supabase para gestión académica escolar. UI, modelos y nombres de archivos están en español.

## Comandos

```powershell
flutter pub get
copy .env.example .env   # completar SUPABASE_URL y SUPABASE_ANON_KEY antes de ejecutar
flutter run
flutter analyze          # única verificación automatizada; debe quedar sin issues
```

- No existe `test/`: `flutter test` no ejecuta nada. No inventes suites ni comandos de test.
- No hay CI, formatter config, codegen ni migraciones automáticas.
- Para solo compilar: `flutter build apk --debug`.

## Setup

- `.env` está declarado como asset en `pubspec.yaml` y se carga en `main.dart`; no uses `--dart-define`.
- La `SUPABASE_ANON_KEY` viaja dentro del APK. Es una clave pública, así que la seguridad real depende de RLS. Hoy RLS usa políticas temporales `temp_allow_all_*` (ver schema) porque no hay login.

## Arquitectura

- Flujo real: `lib/main.dart` → `SplashScreen` (3 s) → `AdminHomeScreen` → `ColegioDetailScreen` (tabs Gestiones/Cursos). Navegación imperativa con `Navigator`; no hay rutas nombradas ni gestor de estado. `provider` está en pubspec pero no se usa.
- `lib/services/*_service.dart` concentra las consultas Supabase (una por tabla); `lib/models/*.dart` mapea columnas snake_case manualmente; `lib/screens/admin/` es la UI real.
- La persistencia es Supabase, **no** SharedPreferences. `README.md` está desactualizado (describe el MVP local anterior); prioriza el código y `edukardex_schema.sql`.
- Los IDs se generan en el cliente con `Uuid().v4()` y se envían explícitamente. `created_at` lo pone la BD y `toJson()` no lo envía.
- Los assets están duplicados en `assets/` y `lib/assets/`; ambos están declarados en pubspec. `Image.asset` usa rutas `assets/...`.
- Pantallas fuera del flujo actual: `seleccion_registro_screen.dart`, `registro_estudiante_screen.dart`, `lista_estudiantes_screen.dart`, `registro_docente_screen.dart`. No las conectes al flujo sin acordar alcance.
- `RegistroEstudianteScreen` usa `colegio_id = 000...` y `RegistroDocenteScreen` usa `usuario_id`/`colegio_id = 000...`; no funcionan contra las FKs del schema y tampoco asignan curso/gestión. No asumas que el alta de estudiantes/docentes está terminada.

## Base de datos

- `edukardex_schema.sql` es la fuente de verdad. Todo cambio aplicado en Supabase debe registrarse en su `CHANGELOG` con el SQL exacto; reglas en `.agents/AGENTS.md`.
- RLS está habilitado en todas las tablas, con políticas permisivas temporales para acceso anónimo. Al implementar auth hay que reemplazarlas.
- Restricciones ya codificadas en el schema: multi-tenant por `colegio_id`; CI única por `(colegio_id, ci)`; un curso por estudiante y gestión (`curso_estudiante`); un `kardex` por `(estudiante_id, trimestre_id)`; 3 trimestres por gestión; trigger que crea `notificaciones` pendientes por responsable al insertar un incumplimiento.
- Módulos del schema aún sin UI: `usuarios`, `responsables`, `estudiante_responsable`, `kardex`, `tipos_falta`, `incumplimientos`, `notificaciones`, `curso_estudiante`, `curso_docente`.

## Convenciones

- Mantén el español en UI, modelos, servicios y nombres de archivos; columnas SQL en snake_case.
- Usa `AppColors`/`AppTheme` (`lib/theme/app_theme.dart`, Poppins) para UI nueva. Varias pantallas antiguas tienen hex hardcodeados; no las tomes como referencia de estilo.
- La guía funcional (qué debe hacer la app, alcance actual y pendiente) está en `.agents/GUIA_APLICACION.md`; actualízala al agregar módulos.
