#include "id3_util.h"

static int es_id3v24(char *ruta_archivo) {
  FILE *archivo = fopen(ruta_archivo, "rb");

  if(!archivo)
     return 0;

  char header[4];
  size_t bytes_leidos = fread(header, 1, 4, archivo);

  if(bytes_leidos < 4)
    return 0;

  if (header[0] == 'I' && header[1] == 'D' && header[2] == '3')
    return 1;
  
  fclose(archivo);
  return 0;
}

static char* recuperar_marco(struct id3_tag *tag, char *marco) {
  struct id3_frame *frame = id3_tag_findframe(tag, marco, 0);
  if(!frame || frame->nfields <= 1) 
    return NULL;

  union id3_field *field = id3_frame_field(frame, 1);
  if(!field) 
    return NULL;
  
  const id3_ucs4_t *ucs4 = id3_field_getstrings(field, 0);
  if(!ucs4)
    return NULL;

  const id3_utf8_t *utf8 = id3_ucs4_utf8duplicate(ucs4);
  if(!utf8)
    return NULL;

  return (char *) utf8;
}

Datos* recuperar_datos(char *ruta_archivo) {
  if(ruta_archivo == NULL) {
    return NULL;
  }

  if (!es_id3v24(ruta_archivo)) {
    return NULL;
  }

  struct id3_file *file = id3_file_open(ruta_archivo, ID3_FILE_MODE_READONLY);
  if(!file) {
    return NULL;
  }
  
  struct id3_tag *tag = id3_file_tag(file);
  if(!tag) {
    id3_file_close(file);
    return NULL;
  }
  
  if(tag->version != 0x0400) {
    id3_file_close(file);
    return NULL;
  }

  Datos *datos = (Datos *) malloc(sizeof(Datos));
  memset(datos, 0, sizeof(Datos));
 
  datos->performer = recuperar_marco(tag, "TPE1");
  datos->title     = recuperar_marco(tag, "TIT2");
  datos->album     = recuperar_marco(tag, "TALB");
  datos->year      = recuperar_marco(tag, "TDRC");
  datos->genre     = recuperar_marco(tag, "TCON");
  datos->track     = recuperar_marco(tag, "TRCK");
  datos->path      = strdup(ruta_archivo);
    
  return datos;
}

void liberar_datos(Datos *datos) {
  if(!datos)
    return;
  
  if(datos->performer != NULL)
    free(datos->performer);

  if(datos->title != NULL)
    free(datos->title);

  if(datos->year != NULL)
    free(datos->year);

  if(datos->genre != NULL)
    free(datos->genre);

  if(datos->track != NULL)
    free(datos->track);

  if(datos->path != NULL)
    free(datos->path);

  free(datos);
}
