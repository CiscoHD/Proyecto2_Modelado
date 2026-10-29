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

Cancion* recuperar_datos(char *ruta_archivo) {
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

  Cancion *cancion = (Cancion *) malloc(sizeof(Cancion));
  memset(cancion, 0, sizeof(Cancion));
  
  cancion->performer = recuperar_artista(tag);
    
  return cancion;
}

void liberar_datos(Cancion *cancion) {
  if(!cancion)
    return;
  
  if(cancion->performer != NULL)
    free(cancion->performer);

  if(cancion->title != NULL)
    free(cancion->title);

  if(cancion->year != NULL)
    free(cancion->year);

  if(cancion->genre != NULL)
    free(cancion->genre);

  if(cancion->track != NULL)
    free(cancion->track);

  free(cancion);
}
