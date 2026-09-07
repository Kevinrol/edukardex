# EduKardex - MVP Registro de Estudiantes

MVP funcional de la funcionalidad **Registro de Estudiantes** de EduKardex,
primer eslabón del flujo Registro → Kardex → Reportes.

## ¿Qué incluye?

- **Formulario de registro** con validación de campos obligatorios,
  selector de fecha de nacimiento, curso y paralelo, y datos del tutor.
- **Validación de CI duplicado** para evitar registros repetidos.
- **Listado de estudiantes** con búsqueda en tiempo real (nombre, CI, curso).
- **Persistencia local** (SharedPreferences) para que el MVP funcione
  sin necesidad de backend todavía.
- **Tema visual institucional** (azul EduKardex, tipografía limpia,
  Material 3) coherente con el prompt de diseño del proyecto.

## Instalación

1. Copia la carpeta `lib/` y el `pubspec.yaml` a tu proyecto Flutter
   (o usa este proyecto directamente si es nuevo).
2. Instala dependencias:
   ```
   flutter pub get
   ```
3. Ejecuta:
   ```
   flutter run
   ```

## Estructura

```
lib/
├── models/
│   └── estudiante.dart          # Modelo de datos
├── services/
│   └── estudiante_service.dart  # Persistencia (fácil de migrar a API REST)
├── screens/
│   ├── registro_estudiante_screen.dart
│   └── lista_estudiantes_screen.dart
├── theme/
│   └── app_theme.dart           # Colores/tipografía institucionales
└── main.dart
```

## Siguiente paso: conectar a backend real

`EstudianteService` está diseñado para que sea el ÚNICO archivo que
tengas que tocar al migrar de SharedPreferences a una API real. Los
métodos públicos (`listar`, `agregar`, `eliminar`, `ciYaRegistrado`)
ya tienen la firma que necesitarías con `http` o `dio`; solo cambia
la implementación interna, por ejemplo:

```dart
Future<List<Estudiante>> listar() async {
  final response = await http.get(Uri.parse('$baseUrl/estudiantes'));
  final data = jsonDecode(response.body) as List;
  return data.map((e) => Estudiante.fromJson(e)).toList();
}
```

## Fuera de alcance de este MVP (por diseño)

- Edición de estudiantes ya registrados (solo alta y baja)
- Carga de foto/documentos del estudiante
- Autenticación (login) — se asume acceso directo para la demo
- Conexión a base de datos real / API

Estos se agregan en iteraciones siguientes según el roadmap del proyecto.
