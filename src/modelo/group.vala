using GLib;

namespace Bdm {
	public class Group : Performer {
		public int?   id_group   { get; set;}
		public string start_date { get; set;}
		public string end_date   { get; set;}

		public Group() {
			this.id_type = 1; // Type: 1 -> "Group"
		}
		public override bool equals (Performer? other) {
			if (!base.equals (other))
				return false;

			Group group = other as Group;
			if (group == null)
				return false;

			return this.id_group == group.id_group &&
			       this.start_date == group.start_date &&
			       this.end_date == group.end_date;
		}
	}

	public class GroupBuilder {
		private Group group;

		public GroupBuilder() {
			this.group = new Group();
		}

		public GroupBuilder with_id_performer(int id_performer) {
			if (id_performer >= 0)
				this.group.id_performer = id_performer;
			return this;
		}

		public GroupBuilder with_id_group(int id_group) {
			if (id_group >= 0)
				this.group.id_group = id_group;
			return this;
		}

		public GroupBuilder with_name(string? name) {
			if (name != null && name.strip().length != 0)
				this.group.name = name;
			else
				this.group.name = "Unknown";
			return this;
		}

		public GroupBuilder with_start_date(string? start_date) {
			if (start_date != null && start_date.strip().length != 0)
				this.group.start_date = start_date;
			else
				this.group.start_date = "Unknown";
			return this;
		}

		public GroupBuilder with_end_date(string? end_date) {
			if (end_date != null && end_date.strip().length != 0)
				this.group.end_date = end_date;
			else
				this.group.end_date = "Unknown";
			return this;
		}

		public Group build_group() {
			return this.group;
		}
	}
}