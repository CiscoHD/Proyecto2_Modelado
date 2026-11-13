using GLib;

namespace Bdm {
	public class Editor {

		public Editor() {}

		public static void editar_rola(Rola original, Rola editada) {
			Dao dao = Dao.get_instancia();
			if(original.equals(editada)) {
				stdout.printf("No se editó la rola \n");
				return;
			}

			bool es_nuevo_album = false;
			bool es_nuevo_performer = false;

			if(!original.album.equals(editada.album)) {
				stdout.printf("Se editó el album desde rola \n");
				int id_album = dao.id_album(editada.album);

				/* Si no existe el album con los datos editados lo
				  creamos */
				if(id_album == -1) {
					id_album = dao.agregar_album(editada.album);
					es_nuevo_album = true;
				}
				// Actualizamos el id del album editado
				editada.album.id = id_album;
			}

			if(!original.performer.equals(editada.performer)) {
				stdout.printf("Se editó el performer desde rola \n");
				int id_performer = dao.id_performer(editada.performer);

				if(id_performer == -1) {
					id_performer = dao.agregar_performer(editada.performer);
					es_nuevo_performer = true;
				}
				editada.performer.id_performer = id_performer;
			}

			dao.actualizar_rola(editada);
			ResultadoEditarRola resul = new ResultadoEditarRola(editada, es_nuevo_album, es_nuevo_performer);
			Notificador.get_instancia().notificar_rola_editada(resul);
		}

		public static void editar_album(Album original, Album editado) {
			Dao dao = Dao.get_instancia();
			
			if(original.equals(editado)) {
				stdout.printf("No se editó el album\n");
				return ;
			}

			dao.actualizar_album(editado);
			Notificador.get_instancia().notificar_album_editado(editado);
		}

		public static void editar_performer(Performer original, Performer editado) {
			Dao dao = Dao.get_instancia();
			
			if(original.equals(editado)) {
				stdout.printf("No se editó el performer\n");
				return;
			}

			dao.actualizar_performer(editado);
			
			if(original is Person && !(editado is Person)) 
				dao.eliminar_person((Person) original);
			else if(original is Group && !(editado is Group))
				dao.eliminar_group((Group) original);

			if(editado is Person) {
				Person person = (Person) editado;
				int id_person = dao.id_person(person);

				if(id_person == -1) {
					id_person = dao.agregar_person(person);
				} else {
					person.id_person = id_person;
					dao.actualizar_person(person);
				}
				
			} else if(editado is Group) {
				Group group = (Group) editado;
				int id_group = dao.id_group(group);

				if (id_group == -1) {
					id_group = dao.agregar_group(group);
					group.id_group = id_group;
				} else {
					group.id_group = id_group;
					dao.actualizar_group(group);
				}
			}

			Notificador.get_instancia().notificar_performer_editado(editado);
		}
	}
}