include_dir = include_directories('modelo/include')

src = [
    'main.vala',
    'vista/ventana.vala',
    'modelo/minero.c',
    'vapi/minero.vapi'
]

gnome = import('gnome')

resources = gnome.compile_resources(
    'bdm-resources',
    'gresource.xml',
    source_dir: '.',
    c_name: 'resources'
)

c_compiler = meson.get_compiler('c')
id3_dep = c_compiler.find_library('id3tag', required: true)

executable(
    'bd_musical',
    resources,
    sources : src,
    include_directories : include_dir,
    dependencies : [
        gobject_dep,
        glib_dep ,
        gtk4_dep,
        id3_dep
    ],
    vala_args: [
        '--gresources=' + meson.current_source_dir() / 'gresource.xml',
        '--vapidir=' + meson.current_source_dir() / 'vapi',
    ]
)
