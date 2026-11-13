using Gtk;
using Bdm;

namespace Gui {
	[GtkTemplate (ui = "/mx/unam/BDM/vista/ui/dialogo_edicion_album.ui")]
	public class DialogoEdicionAlbum : Dialog {
		
		[GtkChild]
		private unowned Entry entry_path;

		[GtkChild]
		private unowned Entry entry_name;

		[GtkChild]
		private unowned Entry entry_year;

		[GtkChild]
		private unowned Button btn_editar;

		[GtkChild]
		private unowned Button btn_cancelar;

		private Album album;

		public signal void editado(Album album_editado);
		
		public DialogoEdicionAlbum(Album a, Window ventana_padre) {
			Object(transient_for: ventana_padre);
			this.album = a;

			entry_path.text = a.path;
			entry_name.text = a.name;
			entry_year.text = a.year.to_string();

			btn_cancelar.clicked.connect(() => {
					this.close();
				});

			btn_editar.clicked.connect(() => {
					editado(obtener_album_editado());
					this.close();
				});
		}

		public Album obtener_album_editado() {
			Album album_editado =  new AlbumBuilder()
				.with_id(album.id)
				.with_path(album.path)
				.with_name(entry_name.text)
				.with_year(entry_year.text)
				.build_album();
			
			return album_editado;
		}
		
	}
}