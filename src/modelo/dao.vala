using GLib;
using Sqlite;

namespace Bdm {
	public class Dao {
		public static Dao instancia; 
		private Database db;

		private Dao() {
			string dir_datos = Path.build_filename(Environment.get_user_data_dir(), "bd_musical");
			if(!FileUtils.test(dir_datos, FileTest.IS_DIR)) {
				DirUtils.create_with_parents(dir_datos, 0700);
			}
			
			string ruta_db = Path.build_filename(dir_datos, "datos.db");
			bool existe_db = FileUtils.test(ruta_db, FileTest.EXISTS);

			int res = Database.open(ruta_db, out this.db); 
			if(res != OK) {
				stderr.printf("ERROR: No se puede abrir la base de datos\n");
				return;
			}
			
			if(!existe_db) {
				iniciar_esquema(db);
			}
		}

		public static Dao get_instancia() {
			if(instancia == null)
				instancia = new Dao();
			return instancia;
		}
	
		private static void iniciar_esquema(Database db) {
			try {
				var recurso_bytes = resources_lookup_data("/mx/unam/BDM/rolas.sql", ResourceLookupFlags.NONE);
				string recurso_sql = (string) recurso_bytes.get_data();
				string errmsg;

				int res = db.exec(recurso_sql, null, out errmsg);
				if(res != OK) {
					stderr.printf("Error: %s\n", errmsg);
					return;
				}
			} catch(Error e) {
				stderr.printf("ERROR: No se pudo cargar el esquema del recurso.\n");
			}
		}

		public List<Rola> obtener_toda_rola() {
			return buscar_rolas("");
		}

		public List<Rola> buscar_rolas(string consulta) {
			List<Rola> lista_rolas = new List<Rola>();
			string filtro = consulta.strip();

			string buscar = """
				SELECT r.id_rola, r.path, r.title, r.track, r.year, r.genre,
				       a.id_album, a.path, a.name, a.year,
				       perf.id_performer, perf.id_type, perf.name,
				       p.id_person, p.stage_name, p.real_name, p.birth_date, p.death_date,
				       g.id_group, g.start_date, g.end_date
				FROM rolas r
				LEFT JOIN albums a        ON r.id_album = a.id_album
				LEFT JOIN performers perf ON r.id_performer = perf.id_performer
				LEFT JOIN persons p       ON perf.id_performer = p.id_person
				LEFT JOIN groups g        ON perf.id_performer = g.id_group
				WHERE r.title LIKE ?1
				   OR a.name LIKE ?1
				   OR perf.name LIKE ?1
				   OR r.genre LIKE ?1
				ORDER BY r.id_rola ASC;
			""";

			Statement stmt;

			if(db.prepare_v2(buscar, buscar.length, out stmt) != OK) {
				stderr.printf("Error en buscar_rolas: %s\n", db.errmsg());
				return lista_rolas;
			}

			stmt.bind_text(1, "%" + filtro + "%");

			while(stmt.step() == ROW) {
				var album = new AlbumBuilder()
					.with_id(stmt.column_int(6))
					.with_path(stmt.column_text(7))
					.with_name(stmt.column_text(8))
					.with_year(stmt.column_int(9).to_string())
					.build_album();

				int id_perf = stmt.column_int(10);
				int id_type = stmt.column_int(11);
				string perf_name = stmt.column_text(12);
				Performer performer;

				if(id_type == 0) {
					Person person = new PersonBuilder()
						.with_id_performer(id_perf)
						.with_name(perf_name)
						.with_id_person(stmt.column_int(13))
						.with_stage_name(stmt.column_text(14))
						.with_real_name(stmt.column_text(15))
						.with_birth_date(stmt.column_text(16))
						.with_death_date(stmt.column_text(17))
						.build_person();
					
					performer = person;
				} else if(id_type == 1) {
					Group group = new GroupBuilder()
						.with_id_performer(id_perf)
						.with_name(perf_name)
						.with_id_group(stmt.column_int(18))
						.with_start_date(stmt.column_text(19))
						.with_end_date(stmt.column_text(20))
						.build_group();

					performer = group;
				} else {
					performer = new PerformerBuilder()
						.with_id_performer(id_perf)
						.with_id_type(id_type)
						.with_name(perf_name)
						.build_performer();
				}

				var rola = new RolaBuilder()
					.with_id(stmt.column_int(0))
					.with_path(stmt.column_text(1))
					.with_title(stmt.column_text(2))
					.with_track(stmt.column_int(3).to_string())
					.with_year(stmt.column_int(4).to_string())
					.with_genre(stmt.column_text(5))
					.with_album(album)
					.with_performer(performer)
					.build_rola();

				lista_rolas.append(rola);
			}
			return lista_rolas;
		}

		public List<Album> obtener_todo_album() {
			return buscar_albums("");
		}
		
		public List<Album> buscar_albums(string consulta) {
			List<Album> lista_albums = new List<Album>();
			string filtro = consulta.strip();

			string buscar =
				"SELECT id_album, path, name, year FROM albums WHERE name LIKE ?1 OR year LIKE ?1 ORDER BY id_album ASC;";

			Statement stmt;

			int res = db.prepare_v2(buscar, buscar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error: %d: %s\n", db.errcode(), db.errmsg());
				return lista_albums;
			}

			stmt.bind_text(1, "%" + filtro + "%");

			while(stmt.step() == ROW) {
				Album album = new AlbumBuilder()
					.with_id(stmt.column_int(0))
					.with_path(stmt.column_text(1))
					.with_name(stmt.column_text(2))
					.with_year(stmt.column_int(3).to_string())
					.build_album();
				
				lista_albums.append(album);
			}
			
			return lista_albums;
		}

		public List<Performer> obtener_todo_performer() {
			return buscar_performers("");
		}

		public List<Performer> buscar_performers(string consulta) {
			List<Performer> lista_performers = new List<Performer>();
			string filtro = consulta.strip();

			string buscar = """
				SELECT perf.id_performer, perf.id_type, perf.name,
				       p.id_person, p.stage_name, p.real_name, p.birth_date, p.death_date,
				       g.id_group, g.start_date, g.end_date
				FROM performers perf
				LEFT JOIN persons p ON perf.id_performer = p.id_person
				LEFT JOIN groups g  ON perf.id_performer = g.id_group
				WHERE perf.name LIKE ?1
					   OR p.stage_name LIKE ?1
					   OR p.real_name LIKE ?1
				ORDER BY perf.id_performer ASC;
			""";

			Statement stmt;
			
			int res = db.prepare_v2(buscar, buscar.length, out stmt);
			if (res != OK) {
				stderr.printf("Error en buscar_performers: %s\n", db.errmsg());
				return lista_performers;
			}

			stmt.bind_text(1, "%" + filtro + "%");

			while (stmt.step() == ROW) {
				int id_perf = stmt.column_int(0);
				int id_type = stmt.column_int(1);
				string name = stmt.column_text(2);

				switch (id_type) {
				case 0: 
					Person person = new PersonBuilder()
						.with_id_performer(id_perf)
						.with_name(name)
						.with_id_person(stmt.column_int(3))
						.with_stage_name(stmt.column_text(4))
						.with_real_name(stmt.column_text(5))
						.with_birth_date(stmt.column_text(6))
						.with_death_date(stmt.column_text(7))
						.build_person();
						
					lista_performers.append(person);
					break;

				case 1: 
					Group group = new GroupBuilder()
						.with_id_performer(id_perf)
						.with_name(name)
						.with_id_group(stmt.column_int(8))
						.with_start_date(stmt.column_text(9))
						.with_end_date(stmt.column_text(10))
						.build_group();

					lista_performers.append(group);
					break;

				default: 
					Performer performer = new PerformerBuilder()
						.with_id_performer(id_perf)
						.with_id_type(id_type)
						.with_name(name)
						.build_performer();
						
					lista_performers.append(performer);
					break;
				}
			}
			
			return lista_performers;
		}

		public void actualizar_rola(Rola r) {
			string actualizar =
				"UPDATE rolas SET id_performer = ?, id_album = ?, title = ?, track = ?, year = ?, genre = ? WHERE id_rola = ?;";
			Statement stmt;

			int res = db.prepare_v2(actualizar, actualizar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error: %d: %s\n", db.errcode(), db.errmsg());
				return;
			}

			stmt.bind_int (1, r.performer.id_performer);
			stmt.bind_int (2, r.album.id);
			stmt.bind_text(3, r.title);
			stmt.bind_int (4, r.track);
			stmt.bind_int (5, r.year);
			stmt.bind_text(6, r.genre);
			stmt.bind_int (7, r.id);

			res = stmt.step();
			if(res != DONE) {
				stderr.printf("Error al actualizar rola: %d: %s\n", db.errcode(), db.errmsg());
				return;
			}

			stdout.printf("Canción '%s'(ID: %d) actualizada correctamente.\n", r.title, r.id);
			return;
		}

		public void actualizar_album(Album a) {
			string actualizar =
				"UPDATE albums SET  name = ?, year = ?, path = ? WHERE id_album = ?;";
			Statement stmt;

			int res = db.prepare_v2(actualizar, actualizar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error: %d: %s\n", db.errcode(), db.errmsg());
				return;
			}

			stmt.bind_text(1, a.name);
			stmt.bind_int (2, a.year);
			stmt.bind_text(3, a.path);
			stmt.bind_int (4, a.id);			

			res = stmt.step();
			if(res != DONE) {
				stderr.printf("Error al actualizar album: %d: %s\n", db.errcode(), db.errmsg());
				return;
			}
			stdout.printf("Canción '%s'(ID: %d) actualizada correctamente.\n", a.name, a.id);
			return;
		}

		public void actualizar_performer(Performer p) {
			string actualizar =
				"UPDATE performers SET id_type = ?, name = ? WHERE id_performer = ?;";

			Statement stmt;

			int res = db.prepare_v2(actualizar, actualizar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error: %d: %s\n", db.errcode(), db.errmsg());
				return;
			}

			stmt.bind_int (1, p.id_type);
			stmt.bind_text(2, p.name);
			stmt.bind_int (3, p.id_performer);

			res = stmt.step();
			if(res != DONE) {
				stderr.printf("Error al actualizar performer: %d: %s\n", db.errcode(), db.errmsg());
				return;
			}
			stdout.printf("Canción '%s'(ID: %d) actualizada correctamente.\n", p.name, p.id_performer);
			return;
		}

		public void actualizar_person(Person p) {
			string actualizar = 
				"UPDATE persons SET stage_name = ?, real_name = ?, birth_date = ?, death_date = ? WHERE id_person = ?;";
			Statement stmt;

			if (db.prepare_v2(actualizar, actualizar.length, out stmt) != OK) {
				stderr.printf("Error: %s\n", db.errmsg());
				return;
			}

			stmt.bind_text(1, p.stage_name);
			stmt.bind_text(2, p.real_name);
			stmt.bind_text(3, p.birth_date);
			stmt.bind_text(4, p.death_date);
			stmt.bind_int (5, p.id_person);

			if (stmt.step() != DONE) {
				stderr.printf("Error al actualizar person: %s\n", db.errmsg());
				return;
			}
			
			return;
		}

		public void actualizar_group(Group g) {
			string actualizar = "UPDATE groups SET start_date = ?, end_date = ? WHERE id_group = ?;";
			Statement stmt;

			int res = db.prepare_v2(actualizar, actualizar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error: %s\n", db.errmsg());
				return;
			}

			stmt.bind_text(1, g.start_date);
			stmt.bind_text(2, g.end_date);
			stmt.bind_int (3, g.id_group);

			res = stmt.step();
			if (res != DONE) {
				stderr.printf("Error al actualizar group: %s\n", db.errmsg());
				return;
			}
			
			return;
		}

		public void agregar_rola(Rola rola) {
			ResultadoInsertar resul_insert;
			bool album_insertado = false;
			bool performer_insertado = false;

			if(id_rola(rola) != -1) {
				resul_insert = new ResultadoInsertar(rola, false, false, false);
				Notificador.get_instancia().notificar_rola_agregada(resul_insert);
				stdout.printf("Canción '%s' ya insertada.\n", rola.path);
				return;
			}
						
			string insertar =
				"INSERT INTO rolas (id_performer, id_album, path, title, track, year, genre) VALUES (?, ?, ?, ?, ?, ?, ?);";

			Statement stmt;
			int res = db.prepare_v2(insertar, insertar.length, out stmt);
			if (res != OK) {
				stderr.printf("Error: %d: %s\n", db.errcode(), db.errmsg());
				return;
			}
			
			int id_performer = id_performer(rola.performer);
			if(id_performer == -1){
				id_performer = agregar_performer(rola.performer);
				performer_insertado = true;
			} else
				stdout.printf("Se encontró perfomer '%s' \n", rola.performer.name);

			int id_album = id_album(rola.album);
			if(id_album == -1) {
				id_album = agregar_album(rola.album);
				album_insertado = true;
			} else
				stdout.printf("Se encontró album '%s' \n", rola.album.name);
			
			stmt.bind_int (1, id_performer);
			rola.performer.id_performer = id_performer;
			rola.performer.id_type = 2;       // Type: 2 -> "Unknown"
			
			stmt.bind_int (2, id_album);
			rola.album.id = id_album;
			
			stmt.bind_text(3, rola.path);
			stmt.bind_text(4, rola.title);
			stmt.bind_int (5, rola.track);
			stmt.bind_int (6, rola.year);
			stmt.bind_text(7, rola.genre);

			res = stmt.step();
			if (res != DONE) {
				stderr.printf("Error al ejecutar la inserción: %s\n", db.errmsg());
				return;
			}

			rola.id = (int) db.last_insert_rowid();
			resul_insert = new ResultadoInsertar(rola, true, album_insertado, performer_insertado);
			Notificador.get_instancia().notificar_rola_agregada(resul_insert);
			stdout.printf("Canción '%s' insertada correctamente.\n", rola.path);
		}

		
		public int agregar_album(Album a) {
			string insertar =
				"INSERT INTO albums (path, name, year) VALUES (?, ?, ?);";
			Statement stmt;

			int res = db.prepare_v2(insertar, insertar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error al preparar: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt.bind_text(1, a.path);
			stmt.bind_text(2, a.name);
			stmt.bind_int (3, a.year);

			res = stmt.step();
			if(res != DONE) {
				stderr.printf("Error al ejecutar la inserción: %s\n", db.errmsg());
				return -1;
			}
			
			return (int) db.last_insert_rowid();
		}

		public int agregar_performer(Performer p) {
			string insertar =
				"INSERT INTO performers (id_type, name) VALUES (2, ?);";

			Statement stmt;
			int res = db.prepare_v2(insertar, insertar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error al preparar: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt.bind_text(1, p.name);
			
			res = stmt.step();
			if(res != DONE) {
				stderr.printf("Error al ejecutar la inserción: %s\n", db.errmsg());
				return -1;
			}
			
			return (int) db.last_insert_rowid();
		}

		public int agregar_person(Person person) {
			string insertar =
				"INSERT INTO persons (id_person, stage_name, real_name, birth_date, death_date) VALUES (?, ?, ?, ?, ?);";

			Statement stmt;
			int res = db.prepare_v2(insertar, insertar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error al preparar: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt.bind_int (1, person.id_person);
			stmt.bind_text(2, person.stage_name);
			stmt.bind_text(3, person.real_name);
			stmt.bind_text(4, person.birth_date);
			stmt.bind_text(5, person.death_date);
			
			res = stmt.step();
			if(res != DONE) {
				stderr.printf("Error al ejecutar la inserción: %s\n", db.errmsg());
				return -1;
			}
			
			return (int) db.last_insert_rowid();
		}

		public int agregar_group(Group group) {
			string insertar =
				"INSERT INTO groups (id_group, name, start_date, end_date) VALUES (?, ?, ?, ?);";

			Statement stmt;
			int res = db.prepare_v2(insertar, insertar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error al preparar: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt.bind_int (1, group.id_group);
			stmt.bind_text(2, group.name);
			stmt.bind_text(3, group.start_date);
			stmt.bind_text(4, group.end_date);
			
			res = stmt.step();
			if(res != DONE) {
				stderr.printf("Error al ejecutar la inserción: %s\n", db.errmsg());
				return -1;
			}
			
			return (int) db.last_insert_rowid();
		}

		public void eliminar_person(Person p) {
			string eliminar = "DELETE FROM persons WHERE id_person = ?;";
			Statement stmt;
			
			int res = db.prepare_v2(eliminar, eliminar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error: %d: %s\n", db.errcode(), db.errmsg());
				return;
			}
			
			stmt.bind_int(1, p.id_person);

			res = stmt.step();
			if(res != DONE) {
				stderr.printf("Error al ejecutar la eliminación: %s\n", db.errmsg());
			}
			
			return;
		}

		public void eliminar_group(Group g) {
			string eliminar =
				"DELETE FROM groups WHERE id_group = ?;";

			Statement stmt;

			int res = db.prepare_v2(eliminar, eliminar.length, out stmt);
			if(res != OK) {
				stderr.printf("Error: %d: %s\n", db.errcode(), db.errmsg());
				return;
			}
			
			stmt.bind_int(1, g.id_group);
			
			res = stmt.step();
			if(res != DONE) {
				stderr.printf("Error al ejecutar la eliminación: %s\n", db.errmsg());
			}
			
			return;
		}
		
		/*
		  Regresa el id de la rola recibida o -1 si no está en la base
		  de datos.
		*/
		public int id_rola(Rola r) {
			string buscar =
				"SELECT id_rola FROM rolas WHERE path = ? AND title = ? AND track = ? AND year = ? AND genre = ? LIMIT 1;";
			Statement stmt_buscar;

			int res = db.prepare_v2(buscar, buscar.length, out stmt_buscar);
			if(res != OK) {
				stderr.printf("Error: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt_buscar.bind_text(1, r.path);
			stmt_buscar.bind_text(2, r.title);
			stmt_buscar.bind_int (3, r.track);
			stmt_buscar.bind_int (4, r.year);
			stmt_buscar.bind_text(5, r.genre);
			
			res = stmt_buscar.step();
			if(res == ROW) {
				return stmt_buscar.column_int(0);
			}
			return -1;
		}

		/*
		  Regresa el id del album recibido o -1 si no está en la base
		  de datos.
		*/
		public int id_album(Album a) {

			string buscar =
				"SELECT id_album FROM albums WHERE path = ? AND name = ? AND year = ? LIMIT 1;";
			Statement stmt_buscar;

			int res = db.prepare_v2(buscar, buscar.length, out stmt_buscar);
			if(res != OK) {
				stderr.printf("Error al preparar: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt_buscar.bind_text(1, a.path);
			stmt_buscar.bind_text(2, a.name);
			stmt_buscar.bind_int (3, a.year);

			res = stmt_buscar.step();
			if(res == ROW)
				return stmt_buscar.column_int(0);
			return -1;
		}

		/*
		  Regresa el id del performer recibido o -1 si no está en la
		  base de datos.
		*/
		public int id_performer(Performer p) {
			string buscar = "SELECT id_performer FROM performers WHERE name = ? LIMIT 1;";
			Statement stmt_buscar;

			int res = db.prepare_v2(buscar, buscar.length, out stmt_buscar);
			if(res != OK) {
				stderr.printf("Error al preparar: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt_buscar.bind_text(1, p.name);
			
			res = stmt_buscar.step();
			if(res == ROW) {
				return stmt_buscar.column_int(0);
			}
			return -1;
		}

		/*
		  Regresa el id del person recibido o -1 si no está en la
		  base de datos
		 */
		public int id_person(Person person) {
			string buscar =
				"SELECT id_person FROM persons WHERE id_person = ?;";
			Statement stmt_buscar;
			
			int res = db.prepare_v2(buscar, buscar.length, out stmt_buscar);
			if(res != OK) {
				stderr.printf("Error al preparar: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt_buscar.bind_int(1, person.id_person);
			
			res = stmt_buscar.step();
			if(res == ROW) {
				return stmt_buscar.column_int(0);
			}
			return -1;
		}

		/*
		  Regresa el id del group recibido o -1 si no está en la
		  base de datos
		 */
		public int id_group(Group group) {
			string buscar =
				"SELECT id_group FROM groups WHERE id_group = ?;";
			Statement stmt_buscar;
			
			int res = db.prepare_v2(buscar, buscar.length, out stmt_buscar);
			if(res != OK) {
				stderr.printf("Error al preparar: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt_buscar.bind_int(1, group.id_group);
			
			res = stmt_buscar.step();
			if(res == ROW) {
				return stmt_buscar.column_int(0);
			}
			return -1;
		}

		
	}
}