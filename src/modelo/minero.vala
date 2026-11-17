using GLib;
using Id3;

namespace Bdm {
	public class Minero {
		private File dir;

		public Minero(File dir) {
			this.dir = dir;
		}

		public int minar() {
			Dao dao = Dao.get_instancia();
			ResultadoInsertar resul_insert;
			Queue<File> cola = new Queue<File>();
			cola.push_tail(dir);

			while(!cola.is_empty()) {
				File actual = cola.pop_head();
				try {
					FileEnumerator enumerator = actual.enumerate_children (
						FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE,
						FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
						null
					);
					FileInfo? info = null;
					while((info = enumerator.next_file()) != null) {
						File elem = actual.get_child(info.get_name());
						FileType tipo = info.get_file_type();
						
						if(tipo == FileType.DIRECTORY) {
							cola.push_tail(elem);
						} else {
							string ruta_archivo = elem.get_parse_name();
							Datos? datos = recuperar_datos(ruta_archivo);
							
							if(datos != null) {
								string ruta_dir = actual.get_parse_name();
								stdout.printf("%s\n", actual.get_basename());
								bool album_insertado = false;
								bool performer_insertado = false;
								
								Album a = new AlbumBuilder().
									with_path(ruta_dir).
									with_name(datos.album ?? actual.get_basename()).
									with_year(datos.year).
									build_album();

								Performer p = new PerformerBuilder().
									with_name(datos.performer).
									with_id_type(2).
									build_performer();

								Rola r = new RolaBuilder().
									with_path(ruta_archivo).
									with_title(datos.title ?? elem.get_basename()).
									with_track(datos.track).
									with_year(datos.year).
									with_genre(datos.genre).
									with_album(a).
									with_performer(p).
									build_rola();

								int id_rola = dao.id_rola(r);
								if(id_rola != -1) {
									resul_insert = new ResultadoInsertar(r, false, false, false);
									Notificador.get_instancia().notificar_rola_agregada(resul_insert);
									stdout.printf("Canción '%s' ya insertada.\n", r.path);
									continue;
								}

								int id_album = dao.id_album(a);
								if(id_album == -1) {
									id_album = dao.agregar_album(a);
									album_insertado = true;
								} else
									stdout.printf("Se encontró album '%s' \n", a.name);

								a.id = id_album;

								int id_performer = dao.id_performer(p);
								if(id_performer == -1) {
									id_performer = dao.agregar_performer(p);
									performer_insertado = true;
								} else
									stdout.printf("Se encontró performer '%s' \n", p.name);

								p.id_performer = id_performer;
								
								id_rola = dao.agregar_rola(r);
								r.id = id_rola;
								resul_insert =
									new ResultadoInsertar(r, true, album_insertado, performer_insertado);
								Notificador.get_instancia().notificar_rola_agregada(resul_insert);
							}
						}
					}
				} catch (Error e) {
					stderr.printf ("Error al acceder a '%s': %s\n", actual.get_parse_name (), e.message);
				}
			}
			return 0;
		}

	}
}