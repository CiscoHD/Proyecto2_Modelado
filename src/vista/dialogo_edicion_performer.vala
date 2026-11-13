using Gtk;
using Bdm;

namespace Gui {
	[GtkTemplate (ui = "/mx/unam/BDM/vista/ui/dialogo_edicion_performer.ui")]
	public class DialogoEdicionPerformer : Dialog {

		[GtkChild]
		private unowned Gtk.Stack stack_tipo;

		[GtkChild]
		private unowned Gtk.DropDown drop_type;

		[GtkChild]
		private unowned Gtk.Entry entry_stage_name;

		[GtkChild]
		private unowned Gtk.Entry entry_real_name;

		[GtkChild]
		private unowned Gtk.Entry entry_birth_date;

		[GtkChild]
		private unowned Gtk.Entry entry_death_date;

		[GtkChild]
		private unowned Gtk.Entry entry_group_name;

		[GtkChild]
		private unowned Gtk.Entry entry_start_date;

		[GtkChild]
		private unowned Gtk.Entry entry_end_date;

		[GtkChild]
		private unowned Gtk.Image img_performer;

		[GtkChild]
		private unowned Gtk.Button btn_editar;

		[GtkChild]
		private unowned Gtk.Button btn_cancelar;

		private Performer performer;
		
		public signal void editado(Performer performer_editado);

		public DialogoEdicionPerformer(Performer performer, Window ventana_padre) {
			Object(transient_for: ventana_padre);
			this.performer = performer;

			drop_type.notify["selected"].connect(on_type_changed);
			
			if(performer is Person) {
				Person person = (Person) performer;
				drop_type.selected = 0;

				entry_stage_name.text = person.stage_name;
                entry_real_name.text = person.real_name;
                entry_birth_date.text = person.birth_date;
                entry_death_date.text = person.death_date;
			} else if(performer is Group) {
				Group group = (Group) performer;
                drop_type.selected = 1;

                entry_group_name.text = group.name;
                entry_start_date.text = group.start_date;
                entry_end_date.text = group.end_date;
			} else {
				drop_type.selected = 2;
				entry_stage_name.text = performer.name;
				entry_group_name.text = performer.name;
			}

			actualizar_vista(drop_type.selected);

			btn_cancelar.clicked.connect(() => {
					this.close();
				});
			
			btn_editar.clicked.connect(() => {
					editado(obtener_performer_editado());
					this.close();
				});
		}

		private Performer obtener_performer_editado() {
			uint tipo_seleccionado = drop_type.selected;

			if(tipo_seleccionado == 0) {
				Person person = new PersonBuilder()
					.with_id_performer(this.performer.id_performer)
					.with_id_person(this.performer.id_performer)
					.with_name(entry_stage_name.text)
					.with_stage_name(entry_stage_name.text)
					.with_real_name(entry_real_name.text)
					.with_birth_date(entry_birth_date.text)
					.with_death_date(entry_death_date.text)
					.build_person();
				
				return person;
			} else if(tipo_seleccionado == 1) {
				Group group = new GroupBuilder()
					.with_id_performer(this.performer.id_performer)
					.with_id_group(this.performer.id_performer)
					.with_name(entry_group_name.text)
					.with_start_date(entry_start_date.text)
					.with_end_date(entry_end_date.text)
					.build_group();
				
				return group;
			} else {
				Performer performer = new PerformerBuilder()
					.with_id_performer(this.performer.id_performer)
					.with_id_type(2)
					.with_name(this.performer.name)
					.build_performer();

                return performer;
			}
		}

		private void on_type_changed () {
            actualizar_vista(drop_type.selected);
        }
		
		private void actualizar_vista(uint id_type) {
			switch(id_type) {
			case 0:
				stack_tipo.visible_child_name = "vista_person";
				img_performer.icon_name = "avatar-default-symbolic";
				break;
			case 1:
				stack_tipo.visible_child_name = "vista_group";
				img_performer.icon_name = "system-users-symbolic";
				break;
			default:
				stack_tipo.visible_child_name = "vista_unknown";
				img_performer.icon_name = "help-browser-symbolic";
				break;
			}
		}
	}
}