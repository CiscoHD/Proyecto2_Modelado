using Gtk;

public class Main : Gtk.Application {
	public Main () {
		Object (application_id: "Main");
	}

	public override void activate () {
		var builder 

		win.present ();
	}

	public static int main (string[] args) {
		var app = new Main ();
		return app.run (args);
	}
}
