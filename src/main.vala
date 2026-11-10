using Gtk;
using Bdm;

public class Main : Gtk.Application {
	public Main () {
		Object (application_id: "mx.unam.BDM");
	}

	public override void activate () {
		var win = new Gui.Ventana(this);
		win.present ();
	}

	public override void startup () {
		base.startup();
		Dao.get_instancia();
	}

	public static int main (string[] args) {
		var app = new Main ();
		return app.run (args);
	}
}
