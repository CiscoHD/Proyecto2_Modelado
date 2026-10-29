#ifndef ID3_UTIL_H
#define ID3_UTIL_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <id3tag.h>

typedef struct {
  char *performer; //TPE1
  char *title;     //TIT2
  char *album;     //TALB
  char *year;      //TDRC
  char *genre;     //TCON
  char *track;     //TRCK
} Cancion;

Cancion* recuperar_datos(char *ruta_archivo);
void liberar_datos(Cancion *datos);

#endif
