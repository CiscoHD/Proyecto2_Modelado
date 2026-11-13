using GLib;

namespace Bdm {
	public class ResultadoEditarRola {

		public Rola rola;
		public bool es_nuevo_album     { get; set;}
		public bool es_nuevo_performer { get; set;}
		
		public ResultadoEditarRola(Rola r, bool nuevo_album, bool nuevo_performer) {
			this.rola = r;
			this.es_nuevo_album     = nuevo_album;
			this.es_nuevo_performer = nuevo_performer;
		}
		
	}
}