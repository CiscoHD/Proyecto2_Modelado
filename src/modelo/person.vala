using GLib;

namespace Bdm {
	public class Person : Performer {
		public int?   id_person  { get; set;}
		public string stage_name { get; set;}
		public string real_name  { get; set;}
		public string birth_date { get; set;}
		public string death_date { get; set;}

		public Person() {
			this.id_type = 0; // Type: 0 -> "Person"
		}

		public override bool equals (Performer? other) {
			if (!base.equals (other))
				return false;

			Person person = other as Person;
			
			if (person == null)
				return false;

			return this.id_person == person.id_person &&
				this.stage_name == person.stage_name &&
				this.real_name == person.real_name &&
				this.birth_date == person.birth_date &&
				this.death_date == person.death_date;
		}	
	}

	public class PersonBuilder {
		private Person person;

		public PersonBuilder() {
			this.person = new Person();
		}

		public PersonBuilder with_id_performer(int id_performer) {
			if (id_performer >= 0)
				this.person.id_performer = id_performer;
			return this;
		}

		public PersonBuilder with_id_person(int id_person) {
			if (id_person >= 0)
				this.person.id_person = id_person;
			return this;
		}

		public PersonBuilder with_name(string? name) {
			if (name != null && name.strip().length != 0) {
				this.person.name = name;
				if (this.person.stage_name == null)
					this.person.stage_name = name;
			} else {
				this.person.name = "Unknown";
			}
			return this;
		}

		public PersonBuilder with_stage_name(string? stage_name) {
			if (stage_name != null && stage_name.strip().length != 0) {
				this.person.stage_name = stage_name;
				this.person.name = stage_name; 
			} else {
				this.person.stage_name = "Unknown";
			}
			return this;
		}

		public PersonBuilder with_real_name(string? real_name) {
			if (real_name != null && real_name.strip().length != 0)
				this.person.real_name = real_name;
			else
				this.person.real_name = "Unknown";
			return this;
		}

		public PersonBuilder with_birth_date(string? birth_date) {
			if (birth_date != null && birth_date.strip().length != 0)
				this.person.birth_date = birth_date;
			else
				this.person.birth_date = "Unknown";
			return this;
		}

		public PersonBuilder with_death_date(string? death_date) {
			if (death_date != null && death_date.strip().length != 0)
				this.person.death_date = death_date;
			else
				this.person.death_date = "Unknown";
			return this;
		}

		public Person build_person() {
			return this.person;
		}
	}
}