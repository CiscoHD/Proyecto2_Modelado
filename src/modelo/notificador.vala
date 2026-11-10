using GLib;

namespace Bdm {
	public class Notificador : Object {
		public static Notificador instancia;

		public signal void rola_agregada(ResultadoInsertar resul);

		private Notificador() {}

		public static Notificador get_instancia() {
			if(instancia == null)
				instancia = new Notificador();
			return instancia;
		}

		public void notificar_rola_agregada(ResultadoInsertar resul) {
			GLib.Idle.add (() => {
                rola_agregada (resul);
                return Source.REMOVE; 
            });

        }
	}
}