using Gtk;


public class Main : Gtk.Application {
	public Main () {
		Object (application_id: "BDM");
	}

	public override void activate () {
		var win = new GUI.Ventana(this);
		win.present ();
	}

	public static int main (string[] args) {
		var app = new Main ();
		return app.run (args);
	}
}
