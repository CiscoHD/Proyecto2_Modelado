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
								Album a = new AlbumBuilder().
									with_path(ruta_dir).
									with_name(datos.album).
									with_year(datos.year).
									build_album();

								Performer p = new PerformerBuilder().
									with_name(datos.performer).
									build_performer();

								Rola r = new RolaBuilder().
									with_path(ruta_archivo).
									with_title(datos.title).
									with_track(datos.track).
									with_year(datos.year).
									with_genre(datos.genre).
									with_album(a).
									with_performer(p).
									build_rola();

								dao.agregar_rola(r);
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