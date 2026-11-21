Modelado y programación
========================

Base de Datos Musical
---------------------

Sistema para la catalogación, búsqueda y edición de colecciones
musicales en formato MP3 mediante una base de datos relacional local
(SQLite3).

La aplicación integra un minero de directorios para extraer etiquetas
ID3v2.4 sin alterar los archivos de audio originales, un buscador sin
necesidad de escribir SQL y una interfaz gráfica para visualizar y
editar datos de canciones, álbumes e intérpretes.

El proyecto se desarrolla en los lenguajes de programación Vala y C,
utilizando GTK4 para la interfaz gráfica.

# Requisitos previos

Es necesario contar con los compiladores de C y Vala, el sistema de
construcción Meson junto con Ninja, y las bibliotecas de desarrollo de
GLib, GTK4, SQLite3 y `libid3tag`.

## Debian / Ubuntu

```bash
$ sudo apt update
$ sudo apt install build-essential meson ninja-build pkg-config valac \
    libglib2.0-dev libglib2.0-dev-bin libgtk-4-dev libsqlite3-dev \
    libid3tag0-dev
```

## Fedora

```bash
$ sudo dnf install gcc meson ninja-build pkgconf-pkg-config vala \
    glib2-devel gtk4-devel sqlite-devel libid3tag-devel
```

## Arch Linux

```bash
$ sudo pacman -S --needed base-devel meson ninja pkgconf vala \
    glib2 gtk4 sqlite libid3tag
```

# Construcción del proyecto

Se usa Meson como sistema de construcción.

## Compilación.

Para compilar, dentro de la raíz del proyecto ejecuta:

```bash
$ meson setup build
$ meson compile -C build
```

# Ejecución

Para ejecutar la aplicación, dentro de la raíz del proyecto ejecuta:

```bash
$ ./build/src/bd_musical
```

Al iniciar por primera vez, el sistema crea automáticamente la base de
datos local en `~/.local/share/bd_musical/datos.db`.
