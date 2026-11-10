using GLib;

namespace Bdm {
	public class Performer {
		public string name { get; set;}

		public Performer() {}
	}

	public class PerformerBuilder {
		private Performer performer;

		public PerformerBuilder() {
			this.performer = new Performer();
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