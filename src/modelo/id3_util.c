#include "id3_util.h"

void recuperar_artista(char *ruta_archivo) {
  if(ruta_archivo == NULL) {
    printf("Cadena nula");
    return;
  }

  struct id3_file *file = id3_file_open(ruta_archivo, ID3_FILE_MODE_READONLY);
  if (!file) {
    printf("Archivo inválido");
    return;
  }

  struct id3_tag *tag = id3_file_tag(file);
  if (!tag) {
    printf("Etiqueta inválida");
    id3_file_close(file);
    return;
  }

  if (tag->version != 0x0400) {
    printf("Version inválida");
    id3_file_close(file);
    return;
  }

  struct id3_frame *frame = id3_tag_findframe(tag, "TPE1", 0);
  if (frame && frame->nfields > 1) {

    union id3_field *field = id3_frame_field(frame, 1);
    if (field) {

      const id3_ucs4_t *ucs4 = id3_field_getstrings(field, 0);
      if(ucs4) {
        const id3_utf8_t *utf8 = id3_ucs4_utf8duplicate(ucs4);
        printf("Artista: %s\n", (const char *)utf8);
      }
    }
  }

  id3_file_close(file);
  return;
}
