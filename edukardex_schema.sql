-- ============================================================
-- EDUKARDEX - Schema de Base de Datos para Supabase (PostgreSQL)
-- Tu Conexión Escolar
-- ============================================================
-- Orden de creación respeta dependencias (FKs).
-- Ejecutar completo en el SQL Editor de Supabase.
-- ============================================================

-- Extensión para generar UUIDs
create extension if not exists "uuid-ossp";

-- ============================================================
-- 1. COLEGIOS (raíz del sistema, multi-tenancy)
-- ============================================================
create table colegios (
    id uuid primary key default uuid_generate_v4(),
    nombre text not null,
    direccion text,
    telefono text,
    director_nombre text,
    activo boolean not null default true,
    created_at timestamptz not null default now()
);

-- ============================================================
-- 2. GESTIONES ACADÉMICAS (años lectivos)
-- ============================================================
create table gestiones_academicas (
    id uuid primary key default uuid_generate_v4(),
    colegio_id uuid not null references colegios(id) on delete cascade,
    anio int not null,
    fecha_inicio date not null,
    fecha_fin date not null,
    activa boolean not null default true,
    created_at timestamptz not null default now(),
    unique (colegio_id, anio)
);

-- ============================================================
-- 3. TRIMESTRES (cada gestión tiene 3)
-- ============================================================
create table trimestres (
    id uuid primary key default uuid_generate_v4(),
    gestion_id uuid not null references gestiones_academicas(id) on delete cascade,
    numero smallint not null check (numero between 1 and 3),
    fecha_inicio date not null,
    fecha_fin date not null,
    unique (gestion_id, numero)
);

-- ============================================================
-- 4. USUARIOS (puente con auth.users + rol del sistema)
-- ============================================================
create type rol_usuario as enum ('administrativo', 'director', 'docente', 'responsable');

create table usuarios (
    id uuid primary key references auth.users(id) on delete cascade,
    colegio_id uuid not null references colegios(id) on delete cascade,
    rol rol_usuario not null,
    nombre_completo text not null,
    email text not null,
    telefono text,
    activo boolean not null default true,
    created_at timestamptz not null default now()
);

-- ============================================================
-- 5. DOCENTES
-- ============================================================
create table docentes (
    id uuid primary key default uuid_generate_v4(),
    usuario_id uuid not null unique references usuarios(id) on delete cascade,
    colegio_id uuid not null references colegios(id) on delete cascade,
    item_codigo text,
    especialidad text,
    tipo_contrato text,
    created_at timestamptz not null default now()
);

-- ============================================================
-- 6. CURSOS
-- ============================================================
create table cursos (
    id uuid primary key default uuid_generate_v4(),
    colegio_id uuid not null references colegios(id) on delete cascade,
    gestion_id uuid not null references gestiones_academicas(id) on delete cascade,
    nombre text not null,          -- ej: "1ro Secundaria"
    paralelo text,                 -- ej: "A"
    nivel text,                    -- ej: "primaria" / "secundaria"
    docente_guia_id uuid references docentes(id) on delete set null,
    created_at timestamptz not null default now()
);

-- Materias que dicta un docente en un curso (opcional, útil si hay varios docentes por curso)
create table curso_docente (
    id uuid primary key default uuid_generate_v4(),
    curso_id uuid not null references cursos(id) on delete cascade,
    docente_id uuid not null references docentes(id) on delete cascade,
    materia text not null,
    unique (curso_id, docente_id, materia)
);

-- ============================================================
-- 7. ESTUDIANTES
-- ============================================================
create table estudiantes (
    id uuid primary key default uuid_generate_v4(),
    colegio_id uuid not null references colegios(id) on delete cascade,
    ci text not null,
    nombres text not null,
    apellido_paterno text not null,
    apellido_materno text,
    fecha_nacimiento date,
    activo boolean not null default true,
    created_at timestamptz not null default now(),
    unique (colegio_id, ci)
);

-- Matrícula del estudiante en un curso, por gestión
create table curso_estudiante (
    id uuid primary key default uuid_generate_v4(),
    curso_id uuid not null references cursos(id) on delete cascade,
    estudiante_id uuid not null references estudiantes(id) on delete cascade,
    gestion_id uuid not null references gestiones_academicas(id) on delete cascade,
    fecha_inscripcion date not null default current_date,
    unique (estudiante_id, gestion_id)  -- un estudiante, un curso por gestión
);

-- ============================================================
-- 8. RESPONSABLES (padres/tutores)
-- ============================================================
create table responsables (
    id uuid primary key default uuid_generate_v4(),
    usuario_id uuid unique references usuarios(id) on delete set null, -- null hasta que se le generen credenciales
    colegio_id uuid not null references colegios(id) on delete cascade,
    nombre_completo text not null,
    ci text,
    telefono text not null,        -- clave para notificaciones (SMS/WhatsApp/push)
    email text,
    parentesco text,               -- padre, madre, tutor legal
    created_at timestamptz not null default now()
);

-- Relación estudiante-responsable (un estudiante puede tener 2+ responsables)
create table estudiante_responsable (
    id uuid primary key default uuid_generate_v4(),
    estudiante_id uuid not null references estudiantes(id) on delete cascade,
    responsable_id uuid not null references responsables(id) on delete cascade,
    es_principal boolean not null default true,
    unique (estudiante_id, responsable_id)
);

-- ============================================================
-- 9. KARDEX (uno por estudiante por trimestre)
-- ============================================================
create table kardex (
    id uuid primary key default uuid_generate_v4(),
    estudiante_id uuid not null references estudiantes(id) on delete cascade,
    trimestre_id uuid not null references trimestres(id) on delete cascade,
    curso_id uuid not null references cursos(id) on delete cascade,
    fecha_apertura date not null default current_date,
    observaciones_generales text,
    created_at timestamptz not null default now(),
    unique (estudiante_id, trimestre_id)  -- regla de negocio no-negociable
);

-- ============================================================
-- 10. TIPOS DE FALTA (catálogo, facilita reportes consistentes)
-- ============================================================
create table tipos_falta (
    id uuid primary key default uuid_generate_v4(),
    nombre text not null unique,       -- ej: "Impuntualidad", "Falta de respeto"
    gravedad_default text not null check (gravedad_default in ('leve', 'grave', 'muy_grave'))
);

-- ============================================================
-- 11. INCUMPLIMIENTOS (faltas registradas en el kardex)
-- ============================================================
create table incumplimientos (
    id uuid primary key default uuid_generate_v4(),
    kardex_id uuid not null references kardex(id) on delete cascade,
    docente_id uuid not null references docentes(id) on delete restrict,
    tipo_falta_id uuid references tipos_falta(id) on delete set null,
    fecha date not null default current_date,
    descripcion text not null,
    gravedad text not null check (gravedad in ('leve', 'grave', 'muy_grave')),
    accion_tomada text,
    created_at timestamptz not null default now()
);

-- ============================================================
-- 12. NOTIFICACIONES (trazabilidad del aviso al responsable)
-- ============================================================
create table notificaciones (
    id uuid primary key default uuid_generate_v4(),
    incumplimiento_id uuid not null references incumplimientos(id) on delete cascade,
    responsable_id uuid not null references responsables(id) on delete cascade,
    canal text not null check (canal in ('push', 'email', 'sms')),
    estado text not null default 'pendiente' check (estado in ('pendiente', 'enviado', 'fallido')),
    detalle_error text,
    fecha_envio timestamptz,
    created_at timestamptz not null default now()
);

-- ============================================================
-- ÍNDICES para las consultas más frecuentes
-- ============================================================
create index idx_estudiantes_colegio on estudiantes(colegio_id);
create index idx_curso_estudiante_estudiante on curso_estudiante(estudiante_id);
create index idx_kardex_estudiante on kardex(estudiante_id);
create index idx_incumplimientos_kardex on incumplimientos(kardex_id);
create index idx_estudiante_responsable_estudiante on estudiante_responsable(estudiante_id);
create index idx_notificaciones_incumplimiento on notificaciones(incumplimiento_id);

-- ============================================================
-- TRIGGER: al crear un incumplimiento, generar automáticamente
-- las filas de notificación pendientes para cada responsable
-- del estudiante (el envío real lo hace una Edge Function
-- disparada por un Database Webhook sobre esta tabla).
-- ============================================================
create or replace function fn_generar_notificaciones()
returns trigger as $$
begin
    insert into notificaciones (incumplimiento_id, responsable_id, canal, estado)
    select
        new.id,
        er.responsable_id,
        'push',
        'pendiente'
    from estudiante_responsable er
    join kardex k on k.id = new.kardex_id
    where er.estudiante_id = k.estudiante_id;

    return new;
end;
$$ language plpgsql security definer;

create trigger trg_notificaciones_incumplimiento
after insert on incumplimientos
for each row execute function fn_generar_notificaciones();

-- ============================================================
-- ROW LEVEL SECURITY (activar; políticas detalladas se ajustan
-- según el rol en `usuarios` - dejo la estructura base)
-- ============================================================
alter table colegios enable row level security;
alter table gestiones_academicas enable row level security;
alter table trimestres enable row level security;
alter table usuarios enable row level security;
alter table docentes enable row level security;
alter table cursos enable row level security;
alter table curso_docente enable row level security;
alter table estudiantes enable row level security;
alter table curso_estudiante enable row level security;
alter table responsables enable row level security;
alter table estudiante_responsable enable row level security;
alter table kardex enable row level security;
alter table tipos_falta enable row level security;
alter table incumplimientos enable row level security;
alter table notificaciones enable row level security;

-- Ejemplo de política: cada usuario solo ve datos de SU colegio
-- (repetir el patrón ajustando la tabla según corresponda)
create policy "usuarios_ven_su_colegio" on estudiantes
    for select
    using (
        colegio_id in (
            select colegio_id from usuarios where id = auth.uid()
        )
    );

-- Ejemplo: solo docentes y administrativos pueden insertar incumplimientos
create policy "docentes_insertan_incumplimientos" on incumplimientos
    for insert
    with check (
        docente_id in (
            select d.id from docentes d
            join usuarios u on u.id = d.usuario_id
            where u.id = auth.uid() and u.rol in ('docente', 'administrativo')
        )
    );

-- ============================================================
-- DATOS INICIALES SUGERIDOS: catálogo de tipos de falta
-- ============================================================
insert into tipos_falta (nombre, gravedad_default) values
    ('Impuntualidad', 'leve'),
    ('Inasistencia no justificada', 'leve'),
    ('Incumplimiento de tareas', 'leve'),
    ('Falta de respeto a docente', 'grave'),
    ('Falta de respeto a compañero', 'grave'),
    ('Uso indebido de dispositivo electrónico', 'leve'),
    ('Daño a bienes del colegio', 'grave'),
    ('Agresión física', 'muy_grave'),
    ('Portación de sustancias prohibidas', 'muy_grave');

-- ============================================================
-- CHANGELOG - HISTORIAL DE CAMBIOS EN BASE DE DATOS
-- Registrar SIEMPRE aquí cualquier cambio aplicado en Supabase.
-- Formato: Fecha | Autor | Descripción
-- ============================================================

-- ------------------------------------------------------------
-- [2026-08-09] | Dev | POLÍTICAS RLS TEMPORALES (MVP sin login)
-- ------------------------------------------------------------
-- MOTIVO: La app Flutter se conecta como usuario anónimo
-- (sin sistema de autenticación implementado aún). Supabase
-- bloquea por defecto toda operación con RLS activo y sin
-- política que lo permita. Se agregaron políticas permisivas
-- temporales para poder probar el registro de datos del MVP.
--
-- TABLAS AFECTADAS: colegios, estudiantes, docentes,
--   gestiones_academicas, cursos, usuarios
--
-- ACCIÓN A FUTURO: Cuando se implemente auth (login), estas
-- políticas deben eliminarse y reemplazarse por políticas
-- que verifiquen auth.uid() y el colegio_id del usuario.
--
-- SQL EJECUTADO EN SUPABASE:
CREATE POLICY "temp_allow_all_colegios" ON colegios
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "temp_allow_all_estudiantes" ON estudiantes
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "temp_allow_all_docentes" ON docentes
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "temp_allow_all_gestiones" ON gestiones_academicas
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "temp_allow_all_cursos" ON cursos
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "temp_allow_all_usuarios" ON usuarios
  FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------
-- [2026-08-09] | Dev | POLÍTICA RLS PARA TRIMESTRES
-- ------------------------------------------------------------
-- MOTIVO: Se agregó el CRUD para Gestiones Académicas (con trimestres) 
-- y Cursos desde la app Flutter. La política de cursos ya existía desde
-- la entrada anterior. Se agrega solo la de trimestres.
--
-- TABLAS AFECTADAS: trimestres
--
-- ACCIÓN A FUTURO: Restringir a director/administrativo de su respectivo colegio_id.
--
-- SQL EJECUTADO EN SUPABASE:
CREATE POLICY "temp_allow_all_trimestres" ON trimestres
  FOR ALL USING (true) WITH CHECK (true);
-- ------------------------------------------------------------