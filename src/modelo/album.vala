using GLib;

namespace Bdm {
	public class Album : Object {
		public string  path { get; set;}
		public string  name { get; set;}
		public int     year { get; set;}

		public Album() {}
	}

	public class AlbumBuilder {
		private Album album;

		public AlbumBuilder() {
			this.album = new Album();
		}

		public AlbumBuilder with_path(string path) {
			this.album.path = path;
			return this;
		}

		public AlbumBuilder with_name(string? name) {
			if(name != null && name.strip().length != 0)
				this.album.name = name;
			else
				this.album.name = "Unknown";
			return this; 
		}

		public AlbumBuilder with_year(string? year) {
			if(year != null) 
				this.album.year = int.parse(year);
			return this;
		}

		public Album build_album() {
			return this.album;
		}
	}
}