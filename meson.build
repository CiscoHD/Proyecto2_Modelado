project('proyecto2_BDMusical', ['c', 'vala'])

unity_dep = dependency(
    'unity',
    fallback : ['unity', 'unity_dep']
)

glib_dep = dependency('glib-2.0')
gobject_dep =  dependency('gobject-2.0')
gtk4_dep = dependency('gtk4')
id3tag_dep = dependency('id3tag')

subdir('src')
