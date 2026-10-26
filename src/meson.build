include_dir = include_directories('modelo/include')

src = [
    'main.vala',
    'vista/ventana.vala',
    'controlador/controlador_botones.vala',
    'modelo/minero.vala',
    'modelo/id3_util.c',
    'vapi/id3.vapi'
]

gnome = import('gnome')

resources = gnome.compile_resources(
    'bdm-resources',
    'gresource.xml',
    source_dir: '.',
    c_name: 'resources'
)


executable(
    'bd_musical',
    resources,
    sources : src,
    include_directories : include_dir,
    dependencies : [
        gobject_dep,
        gio_dep,
        glib_dep,
        gtk4_dep,
        id3_dep,
        sqlite3_dep
    ],
    vala_args: [
        '--gresources=' + meson.current_source_dir() / 'gresource.xml',
        '--vapidir=' + meson.current_source_dir() / 'vapi',
    ]
)
