using Gtk;

public class Main : Gtk.Application {
  public Main () {
    Object (application_id: "Main");
  }

  public override void activate () {
    var win = new Gtk.ApplicationWindow (this);

    var btn = new Gtk.Button.with_label ("Hello World");
    btn.clicked.connect (win.close);

    win.child = btn;
    win.present ();
  }

  public static int main (string[] args) {
    var app = new Main ();
    return app.run (args);
  }
}
