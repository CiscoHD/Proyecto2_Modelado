using Bdm;

namespace Btn{
	public void on_anterior_clicked() {
		stdout.printf("Anterior presionado\n");
	}

	public void on_play_clicked() {
		stdout.printf("Play presionado\n");
	}

	public void on_siguiente_clicked() {
		stdout.printf("Siguiente presionado\n");
	}

	public void on_minar_clicked() {
		var dialog = new Gtk.FileDialog();
		dialog.title = "Selecciona un directorio de música";
		GLib.File? dir = null;

		dialog.select_folder.begin (null, null, (obj, res) => {
		    try {
				dir = dialog.select_folder.end (res);
				
				if (dir != null) {
					string ruta = dir.get_path ();
					stdout.printf ("Directorio seleccionado: %s\n", ruta);
					Minero minero = new Minero(dir);
					minero.minar();
				}
			} catch (GLib.Error e) {
				stderr.printf ("Selección cancelada o error: %s\n", e.message);
			}
	    });
	}
}