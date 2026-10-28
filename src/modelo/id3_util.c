#include "id3_util.h"

static char* recuperar_artista(struct id3_tag *tag) {
  struct id3_frame *frame = id3_tag_findframe(tag, "TPE1", 0);
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

DatosId3* recuperar_datos(char *ruta_archivo) {
  if(ruta_archivo == NULL) {
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

  DatosId3 *datos = (DatosId3 *) malloc(sizeof(DatosId3));
  memset(datos, 0, sizeof(DatosId3));
  
  datos->performer = recuperar_artista(tag);
    
  return datos;
}

void liberar_datos(DatosId3 *datos) {
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

  free(datos);
}
