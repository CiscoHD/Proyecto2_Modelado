using Gtk;

namespace GUI {

	[GtkTemplate (ui = "/BDM/vista/ui/ventana_principal.ui")]
	public class Ventana : Gtk.ApplicationWindow {
		[GtkChild]
		private unowned Gtk.Stack stack_vistas;

		[GtkChild]
		private unowned Gtk.ListBox lista_canciones;

		[GtkChild]
		private unowned Gtk.FlowBox fb_albumes;

		[GtkChild]
		private unowned Gtk.FlowBox fb_interpretes;

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

		public Ventana(Gtk.Application app) {
			Object(application : app);

			boton_play.clicked.connect(on_play_clicked);
			boton_anterior.clicked.connect(on_anterior_clicked);
			boton_siguiente.clicked.connect(on_siguiente_clicked);
		}

		private void on_anterior_clicked() {
			stdout.printf("Anterior presionado\n");
		}

		private void on_play_clicked() {
			stdout.printf("Play presionado\n");
		}

		private void on_siguiente_clicked() {
			stdout.printf("Siguiente presionado\n");
		}
	}
}