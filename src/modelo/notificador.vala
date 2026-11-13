using GLib;

namespace Bdm {
	public class Notificador : Object {
		public static Notificador instancia;

		public signal void rola_agregada(ResultadoInsertar resul);
		
		public signal void rola_editada(ResultadoEditarRola resul);
		public signal void album_editado(Album album);
		public signal void performer_editado(Performer p);

		private Notificador() {}

		public static Notificador get_instancia() {
			if(instancia == null)
				instancia = new Notificador();
			return instancia;
		}

		public void notificar_rola_agregada(ResultadoInsertar resul) {
			GLib.Idle.add(() => {
                rola_agregada(resul);
                return Source.REMOVE; 
            });
        }

		public void notificar_rola_editada(ResultadoEditarRola resul) {
			rola_editada(resul);
		}

		public void notificar_album_editado(Album album){
			album_editado(album);
		}

		public void notificar_performer_editado(Performer performer) {
			performer_editado(performer);
		}
	}
}