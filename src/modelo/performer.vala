using GLib;

namespace Bdm {
	public class Performer {
		public int?   id_performer { get; set;}
		public int?   id_type      { get; set;}
		public string name         { get; set;}

		public Performer() {}

		public virtual bool equals(Performer? other) {
			if(other == null)
				return false;
			
			if(this == other)
				return true;

			return this.id_performer == other.id_performer &&
			       this.id_type == other.id_type &&
			       this.name == other.name;
		}
	}

	public class PerformerBuilder {
		private Performer performer;

		public PerformerBuilder() {
			this.performer = new Performer();
		}

		public PerformerBuilder with_id_performer(int id_performer) {
			if(id_performer >= 0)
				this.performer.id_performer = id_performer;
			return this;
		}

		public PerformerBuilder with_id_type(int id_type) {
			if(id_type <= 2 && id_type >= 0)
				this.performer.id_type = id_type;
			return this;
		}

		public PerformerBuilder with_name(string? name) {
			if(name != null && name.strip().length != 0)
				this.performer.name = name;
			else
				this.performer.name = "Unknown";
			return this;
		}

		public Performer build_performer() {
			return this.performer;
		}
	}
}