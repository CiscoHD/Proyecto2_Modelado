src = [
    'main.vala',
    'vista/ventana.vala'
]

gnome = import('gnome')

dep = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk4')
]

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
    dependencies : dep,
    vala_args: [
        '--gresources=' + meson.project_source_root() / 'src/gresource.xml'
    ]
)
