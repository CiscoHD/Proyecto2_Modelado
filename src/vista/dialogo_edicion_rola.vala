using Gtk;
using Bdm;

namespace Gui {
	[GtkTemplate (ui = "/mx/unam/BDM/vista/ui/dialogo_edicion_rola.ui")]
	public class DialogoEdicionRola : Dialog {

		[GtkChild]
		private unowned Gtk.Entry entry_path;
		
        [GtkChild]
		private unowned Gtk.Entry entry_title;
		
        [GtkChild]
		private unowned Gtk.Entry entry_track;
		
        [GtkChild]
		private unowned Gtk.Entry entry_year;
		
        [GtkChild]
		private unowned Gtk.Entry entry_genre;

		[GtkChild]
		private unowned Gtk.Entry entry_album_name;

		[GtkChild]
		private unowned Gtk.Entry entry_album_year;

		[GtkChild]
		private unowned Gtk.Entry entry_performer_name;

        [GtkChild]
		private unowned Gtk.Button btn_editar;
		
        [GtkChild]
		private unowned Gtk.Button btn_cancelar;

		private Rola rola;
		
		public signal void editado(Rola rola_editada);

		public DialogoEdicionRola(Rola r, Window ventana_padre) {
			Object(transient_for: ventana_padre);
			this.rola = r;

			entry_path.text = r.path;
            entry_title.text = r.title;
            entry_track.text = r.track.to_string();
			entry_year.text = r.year.to_string();
            entry_genre.text = r.genre;

			if(r.album != null) {
				entry_album_name.text = r.album.name;
				entry_album_year.text = r.album.year.to_string();
			}

			if(r.performer != null)
				entry_performer_name.text = r.performer.name;

			btn_cancelar.clicked.connect(() => {
                this.close();
            });

            btn_editar.clicked.connect(() => {
                editado(obtener_rola_editada());
                this.close();
            });
		}

		public Rola obtener_rola_editada() {
			Performer performer = new Bdm.PerformerBuilder()
				.with_id_performer(rola.performer.id_performer)
				.with_id_type(2)
				.with_name(entry_performer_name.text)
                .build_performer();

            Album album = new Bdm.AlbumBuilder()
				.with_id(rola.album.id)
                .with_path(rola.album.path)
                .with_name(entry_album_name.text)
                .with_year(entry_album_year.text)
                .build_album();

            Rola rola_editada = new Bdm.RolaBuilder()
				.with_id(rola.id)
                .with_path(rola.path)
                .with_title(entry_title.text)
                .with_track(entry_track.text)
				.with_year(entry_year.text)
                .with_genre(entry_genre.text)
                .with_album(album)
                .with_performer(performer)
                .build_rola();

			return rola_editada;
		}
	}
}