using GLib;
using Id3;

namespace Bdm {
	public class Minero {
		private File dir;

		public Minero(File dir) {
			this.dir = dir;
		}

		public int minar() {
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
							Cancion? cancion = recuperar_datos(elem.get_parse_name());
							agregar_rola(cancion);
						}
					}
				} catch (Error e) {
					stderr.printf ("Error al acceder a '%s': %s\n", actual.get_parse_name (), e.message);
				}
			}
			return 0;
		}

		private void agregar_rola(Cancion cancion) {
			stdout.printf("Artista: %s\n", cancion.performer);
		}
	}
}