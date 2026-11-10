using GLib;

namespace Bdm {
	public class Rola : Object {
		public string     path      { get; set;}
		public string     title     { get; set;}
		public int        track     { get; set;}
		public string     genre     { get; set;}
		public Album?     album     { get; set;}
		public Performer? performer { get; set;}

		public Rola() {}
	}

	public class RolaBuilder {
		private Rola rola;

		public RolaBuilder() {
			this.rola = new Rola();
		}

		public RolaBuilder with_path(string path) {
			this.rola.path = path;
			return this;
		}
		
		public RolaBuilder with_title(string? title) {
			if(title != null && title.strip().length != 0)
				this.rola.title = title;
			else
				this.rola.title = "Unknown";
			return this;
		}
		
		public RolaBuilder with_track(string? track) {
			if(track != null) {
				int pos = track.index_of_char('/', 0);
				string num_track = (pos != -1) ? track.substring(0, pos) : track;
				this.rola.track = int.parse(num_track);
			}
			return this;
		}
		
		public RolaBuilder with_genre(string? genre) {
			if(genre != null && genre.strip().length != 0)
				this.rola.genre = genre;
			else
				this.rola.genre = "Unknown";
			return this;
		}
		
		public RolaBuilder with_album(Album? a) {
			if(a != null)
				this.rola.album = a;
			return this;
		}
		
		public RolaBuilder with_performer(Performer? p) {
			if(p != null)
				this.rola.performer = p;
			return this;
		}

		public Rola build_rola() {
			return this.rola;
		}
	}
}