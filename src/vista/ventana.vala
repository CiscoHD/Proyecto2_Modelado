using Gtk;
using Bdm;

namespace Gui {

	[GtkTemplate (ui = "/mx/unam/BDM/vista/ui/ventana_principal.ui")]
	public class Ventana : Gtk.ApplicationWindow {
		[GtkChild]
		private unowned Gtk.Stack stack_vistas;

		[GtkChild]
		private unowned Gtk.ListBox lista_rolas;

		[GtkChild]
		private unowned Gtk.FlowBox fb_albums;

		[GtkChild]
		private unowned Gtk.FlowBox fb_performers;

		[GtkChild]
		private unowned Gtk.Label nom_cancion;

		[GtkChild]
		private unowned Gtk.Label nom_interprete;
		
		[GtkChild]
		private unowned Gtk.Button boton_anterior;

		[GtkChild]
		private unowned Gtk.Button boton_play;

		[GtkChild]
		private unowned Gtk.Button boton_siguiente;

		[GtkChild]
		private unowned Gtk.Button boton_minero;

		public Ventana(Gtk.Application app) {
			Object(application : app);

			boton_play.clicked.connect(Btn.on_play_clicked);
			boton_anterior.clicked.connect(Btn.on_anterior_clicked);
			boton_siguiente.clicked.connect(Btn.on_siguiente_clicked);
			boton_minero.clicked.connect(Btn.on_minar_clicked);

			Notificador notificador = Notificador.get_instancia();
			notificador.rola_agregada.connect(on_rola_agregada);
		}

		private void on_rola_agregada(ResultadoInsertar resul) {
			if(resul.es_nuevo_album)
				fb_albums.append(crear_flowbox_album(resul.rola.album));
			if(resul.es_nuevo_performer)
				fb_performers.append(crear_flowbox_performer(resul.rola.performer));
			if(resul.rola_insertada) 
				lista_rolas.append(crear_fila_rola(resul.rola));
		}

		private Widget crear_fila_rola(Rola rola) {
            Box box = new Box(Orientation.HORIZONTAL, 12);
			box.homogeneous = true;
			box.margin_start = 8;
			box.margin_end = 8;
			box.margin_top = 4;
			box.margin_bottom = 4;
			
            Image img = new Image.from_icon_name("folder-music-symbolic");
            Label lbl_title = new Label(rola.title);
			lbl_title.xalign = 0.0f;
			lbl_title.ellipsize = Pango.EllipsizeMode.END;
			lbl_title.max_width_chars = 25;
			
            Label lbl_performer = new Label(rola.performer.name);
			lbl_performer.ellipsize = Pango.EllipsizeMode.END;
			lbl_performer.xalign = 0.0f;
			lbl_performer.max_width_chars = 20;

			Label lbl_album = new Label(rola.album.name);
			lbl_album.xalign = 0.0f;
			lbl_album.ellipsize = Pango.EllipsizeMode.END;
			lbl_album.max_width_chars = 20;

			Label lbl_genre = new Label(rola.genre);
			lbl_genre.xalign = 0.0f;
			lbl_genre.ellipsize = Pango.EllipsizeMode.END;
			lbl_genre.max_width_chars = 15;
			
			
            box.append(img);
            box.append(lbl_title);
            box.append(lbl_performer);
			box.append(lbl_album);
			box.append(lbl_genre);
            return box;
        }

		private Widget crear_flowbox_album(Album album) {
			Box box = new Box(Orientation.VERTICAL, 0);
			//box.set_homogeneous(true);
			box.set_size_request (140, -1);
			box.margin_start = 6;
			box.margin_end = 6;
			box.margin_top = 6;
			box.margin_bottom = 6;

			Image img = new Image.from_icon_name("media-optical-cd-audio-symbolic");
			img.pixel_size = 64;
			
			Label lbl_name = new Label(album.name);
			lbl_name.wrap = true;
			lbl_name.lines = 2;
			lbl_name.ellipsize = Pango.EllipsizeMode.END;
			lbl_name.max_width_chars = 18;
			lbl_name.justify = Gtk.Justification.CENTER;
			
			Label lbl_year = new Label(album.year.to_string());
			lbl_year.ellipsize = Pango.EllipsizeMode.END;
			lbl_year.max_width_chars = 18;
			lbl_year.justify = Gtk.Justification.CENTER;

			box.append(img);
			box.append(lbl_name);
			box.append(lbl_year);
			return box;
		}

		private Widget crear_flowbox_performer(Performer performer) {
			Box box = new Box(Orientation.VERTICAL, 0);
			box.set_homogeneous(true);
			
			Image img = new Image.from_icon_name("user-info-symbolic");
			img.pixel_size = 64;

			Label lbl_name = new Label(performer.name);
			lbl_name.ellipsize = Pango.EllipsizeMode.END;
			lbl_name.max_width_chars = 18;
			lbl_name.justify = Gtk.Justification.CENTER;

			box.append(img);
			box.append(lbl_name);
			return box;
		}
	}
}