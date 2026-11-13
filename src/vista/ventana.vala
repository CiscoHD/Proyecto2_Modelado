using Gtk;
using Bdm;

namespace Gui {

	[GtkTemplate (ui = "/mx/unam/BDM/vista/ui/ventana_principal.ui")]
	public class Ventana : Gtk.ApplicationWindow {
		[GtkChild]
		private unowned Gtk.ScrolledWindow sw_rolas;

		[GtkChild]
		private unowned Gtk.ScrolledWindow sw_albums;

		[GtkChild]
		private unowned Gtk.ScrolledWindow sw_performers;
		
		[GtkChild]
		private unowned Gtk.ListBox lista_rolas;

		[GtkChild]
		private unowned Gtk.FlowBox fb_albums;

		[GtkChild]
		private unowned Gtk.FlowBox fb_performers;
		
		[GtkChild]
		private unowned Gtk.Button boton_minero;

		[GtkChild]
		private unowned Gtk.SearchEntry entry_busqueda;
		
		private Gtk.ListBox lista_rolas_principal;
		private Gtk.FlowBox lista_albums_principal;
		private Gtk.FlowBox lista_performers_principal;

		private bool en_modo_busqueda = false;

		public Ventana(Gtk.Application app) {
			Object(application : app);

			boton_minero.clicked.connect(Btn.on_minar_clicked);

			Notificador notificador = Notificador.get_instancia();
			notificador.rola_agregada.connect(on_rola_agregada);
			
			notificador.rola_editada.connect(on_rola_editada);
			notificador.album_editado.connect(on_album_editado);
			notificador.performer_editado.connect(on_performer_editado);

			this.lista_rolas_principal = this.lista_rolas;
			this.lista_albums_principal = this.fb_albums;
			this.lista_performers_principal = this.fb_performers;
			
			reiniciar_biblioteca();
			entry_busqueda.search_changed.connect(() => {
					ejecutar_busqueda(entry_busqueda.text);
				});
		}

		private void ejecutar_busqueda(string texto) {
			Dao dao = Dao.get_instancia();
			string consulta = texto.strip();

			if(consulta.length == 0) {
				if(en_modo_busqueda) {
					sw_rolas.child = lista_rolas_principal;
					sw_albums.child = lista_albums_principal;
					sw_performers.child = lista_performers_principal;
					en_modo_busqueda = false;
				}
				return;
			}
			
			List<Rola>  resultados_rolas  = dao.buscar_rolas(consulta);
			List<Album> resultados_albums = dao.buscar_albums(consulta);
			List<Performer> resultados_performers = dao.buscar_performers(consulta);

			Gtk.ListBox lista_rolas_resultados = new Gtk.ListBox();
			lista_rolas_resultados.selection_mode = lista_rolas_principal.selection_mode;

			Gtk.FlowBox lista_albums_resultados = new Gtk.FlowBox();
			lista_albums_resultados.selection_mode = lista_albums_principal.selection_mode;

			Gtk.FlowBox lista_performers_resultados = new Gtk.FlowBox();
			lista_performers_resultados.selection_mode = lista_performers_principal.selection_mode;
					
			foreach(Rola rola in resultados_rolas) {
				lista_rolas_resultados.append(crear_fila_rola(rola));
			}

			foreach(Album album in resultados_albums) {
				lista_albums_resultados.append(crear_flowbox_album(album));
			}

			foreach(Performer performer in resultados_performers) {
				lista_performers_resultados.append(crear_flowbox_performer(performer));
			}

			sw_rolas.child = lista_rolas_resultados;
			sw_albums.child = lista_albums_resultados;
			sw_performers.child = lista_performers_resultados;
			
			en_modo_busqueda = true;
		}

		private void reiniciar_biblioteca() {
			Dao dao = Dao.get_instancia();

			lista_rolas.remove_all();
			fb_albums.remove_all(); 
			fb_performers.remove_all(); 

			foreach(Performer performer in dao.obtener_todo_performer()) {
				fb_performers.append(crear_flowbox_performer(performer));
			}
			
			foreach(Album album in dao.obtener_todo_album()) {
				fb_albums.append(crear_flowbox_album(album));
			}
			
			foreach(Rola rola in dao.obtener_toda_rola()) {
				lista_rolas.append(crear_fila_rola(rola));
			}
		}

		private void on_rola_agregada(ResultadoInsertar resul) {
			if(resul.es_nuevo_album)
				fb_albums.append(crear_flowbox_album(resul.rola.album));
			if(resul.es_nuevo_performer)
				fb_performers.append(crear_flowbox_performer(resul.rola.performer));
			if(resul.rola_insertada) 
				lista_rolas.append(crear_fila_rola(resul.rola));

		}

		private void on_rola_editada(ResultadoEditarRola resul) {
			int indice = resul.rola.id;

			ListBoxRow? fila_anterior = lista_rolas.get_row_at_index(indice);
			if(fila_anterior != null) {
				lista_rolas.remove(fila_anterior);
				lista_rolas.insert(crear_fila_rola(resul.rola), indice);
			}
			
			if(resul.es_nuevo_album)
				fb_albums.append(crear_flowbox_album(resul.rola.album));
			if(resul.es_nuevo_performer)
				fb_performers.append(crear_flowbox_performer(resul.rola.performer));

			reiniciar_biblioteca();
		}

		private void on_album_editado(Album album) {
			int indice = album.id;

			FlowBoxChild? fbc_anterior = fb_albums.get_child_at_index(indice);
			if(fbc_anterior != null) {
				fb_albums.remove(fbc_anterior);
				fb_albums.append(crear_flowbox_album(album));
			}
			
			reiniciar_biblioteca();
		}

		private void on_performer_editado(Performer performer) {
			int indice = performer.id_performer - 1;

			FlowBoxChild? fbc_anterior = fb_performers.get_child_at_index(indice);
			if(fbc_anterior != null) {
				fb_performers.remove(fbc_anterior);
				fb_performers.insert(crear_flowbox_performer(performer), indice);
			}

			reiniciar_biblioteca();
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
			
			Popover popover = new Popover();
			Button btn_editar_rola = new Button.with_label("Editar Datos");
			popover.child = btn_editar_rola;
			popover.set_parent(box);

			btn_editar_rola.clicked.connect(() => {
					popover.popdown();
					Btn.on_editar_rola_clicked(rola, this);
				});

			GestureClick gesture = new GestureClick();
			gesture.button = Gdk.BUTTON_SECONDARY;

			gesture.pressed.connect((n_press, x, y) => {
					Gdk.Rectangle rect = Gdk.Rectangle(); 
					rect.x = (int) x;
					rect.y = (int) y;
					
					popover.set_pointing_to(rect);
					popover.popup();
				});
			
            box.append(img);
            box.append(lbl_title);
            box.append(lbl_performer);
			box.append(lbl_album);
			box.append(lbl_genre);
			box.add_controller(gesture);
            return box;
        }

		private Widget crear_flowbox_album(Album album) {
			Box box = new Box(Orientation.VERTICAL, 0);
			//box.set_homogeneous(true);
			box.set_size_request(140, -1);
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

			Popover popover = new Popover();
			Button btn_editar_album = new Button.with_label("Editar Datos");
			popover.child = btn_editar_album;
			popover.set_parent(box);

			btn_editar_album.clicked.connect(() => {
					popover.popdown();
					Btn.on_editar_album_clicked(album, this);
				});

			GestureClick gesture = new GestureClick();
			gesture.button = Gdk.BUTTON_SECONDARY;

			gesture.pressed.connect((n_press, x, y) => {
					Gdk.Rectangle rect = Gdk.Rectangle(); 
					rect.x = (int) x;
					rect.y = (int) y;
					
					popover.set_pointing_to(rect);
					popover.popup();
				});

			box.append(img);
			box.append(lbl_name);
			box.append(lbl_year);
			box.add_controller(gesture);
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

			Popover popover = new Popover();
			Button btn_editar_performer = new Button.with_label("Editar Datos");
			popover.child = btn_editar_performer;
			popover.set_parent(box);

			btn_editar_performer.clicked.connect(() => {
					popover.popdown();
					Btn.on_editar_performer_clicked(performer, this);
				});

			GestureClick gesture = new GestureClick();
			gesture.button = Gdk.BUTTON_SECONDARY;

			gesture.pressed.connect((n_press, x, y) => {
					Gdk.Rectangle rect = Gdk.Rectangle(); 
					rect.x = (int) x;
					rect.y = (int) y;
					
					popover.set_pointing_to(rect);
					popover.popup();
				});

			box.append(img);
			box.append(lbl_name);
			box.add_controller(gesture);
			return box;
		}
	}
}