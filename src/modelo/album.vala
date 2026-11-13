using GLib;

namespace Bdm {
	public class Album {
		public int?    id       { get; set;}
		public string  path     { get; set;}
		public string  name     { get; set;}
		public int     year     { get; set;}

		public Album() {}

		public bool equals (Album? other) {
			if (other == null)
				return false;
			
			if (this == other)
				return true;

			return this.id == other.id &&
			       this.path == other.path &&
			       this.name == other.name &&
			       this.year == other.year;
		}
	}

	public class AlbumBuilder {
		private Album album;

		public AlbumBuilder() {
			this.album = new Album();
		}

		public AlbumBuilder with_id(int id_album) {
			if(id_album >= 0)
				this.album.id = id_album;
			return this;
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