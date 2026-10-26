project('proyecto2_BDMusical', ['c', 'vala'])

unity_dep = dependency(
    'unity',
    fallback : ['unity', 'unity_dep']
)

c_compiler = meson.get_compiler('c')


glib_dep = dependency('glib-2.0')
gobject_dep =  dependency('gobject-2.0')
gio_dep = dependency('gio-2.0')
gtk4_dep = dependency('gtk4')
id3_dep = c_compiler.find_library('id3tag', required: true)
sqlite3_dep = dependency('sqlite3', fallback : ['sqlite3', 'sqlite3_dep'])

subdir('src')
