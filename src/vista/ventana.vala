using Gtk;

namespace Gui {

	[GtkTemplate (ui = "/mx/unam/BDM/vista/ui/ventana_principal.ui")]
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

		[GtkChild]
		private unowned Gtk.Button boton_minero;

		public Ventana(Gtk.Application app) {
			Object(application : app);

			boton_play.clicked.connect(Btn.on_play_clicked);
			boton_anterior.clicked.connect(Btn.on_anterior_clicked);
			boton_siguiente.clicked.connect(Btn.on_siguiente_clicked);
			boton_minero.clicked.connect(Btn.on_minar_clicked);
		}
	}
}