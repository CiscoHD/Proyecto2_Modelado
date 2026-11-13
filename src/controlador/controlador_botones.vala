using GLib;
using Gtk;
using Gui;
using Bdm;

namespace Btn{
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
					
					new Thread<void*> ("hilo-minero", () => {
							Minero minero = new Minero(dir);
							minero.minar();
							return null;
						});
				}
			} catch (GLib.Error e) {
				stderr.printf ("Selección cancelada o error: %s\n", e.message);
			}
	    });
	}

	public void on_editar_rola_clicked(Rola rola, Window ventana_padre) {
		DialogoEdicionRola dialogo = new DialogoEdicionRola(rola, ventana_padre);
        dialogo.present();

		dialogo.editado.connect((rola_editada) => {
				Editor.editar_rola(rola, rola_editada);
				dialogo.destroy();
			});
		
		return;
	}

	public void on_editar_album_clicked(Album album, Window ventana_padre) {
		DialogoEdicionAlbum dialogo = new DialogoEdicionAlbum(album, ventana_padre);
		dialogo.present();

		dialogo.editado.connect((album_editado) => {
				Editor.editar_album(album, album_editado);
				dialogo.destroy();
			});
		
		return;
	}

	public void on_editar_performer_clicked(Performer performer, Window ventana_padre) {
		DialogoEdicionPerformer dialogo = new DialogoEdicionPerformer(performer, ventana_padre);
		dialogo.present();

		dialogo.editado.connect((performer_editado) => {
				Editor.editar_performer(performer, performer_editado);
				dialogo.destroy();
			});
		return;
	}

}