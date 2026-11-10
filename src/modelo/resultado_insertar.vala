namespace Bdm {
	public class ResultadoInsertar {
		public Rola rola               { get; set;}
		public bool rola_insertada     { get; set;}
		public bool es_nuevo_album     { get; set;}
		public bool es_nuevo_performer { get; set;}

		public ResultadoInsertar(Rola r, bool insertada, bool nuevo_album, bool nuevo_performer) {
			this.rola = r;
			this.rola_insertada     = insertada;
			this.es_nuevo_album     = nuevo_album;
			this.es_nuevo_performer = nuevo_performer;
		}
	}
}