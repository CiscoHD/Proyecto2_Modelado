using GLib;
using Sqlite;

namespace Bdm {
	public class Dao {
		public static Dao instancia; 
		private Database db;

		private Dao() {
			string dir_datos = Path.build_filename(Environment.get_user_data_dir(), "bd_smusical");
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
						
			string insertar = "INSERT INTO rolas (id_performer, id_album, path, title, track, year, genre) VALUES (?, ?, ?, ?, ?, ?, ?);";

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
			stmt.bind_int (2, id_album);
			stmt.bind_text(3, rola.path);
			stmt.bind_text(4, rola.title);
			stmt.bind_int (5, rola.track);
			stmt.bind_int (6, rola.album.year);
			stmt.bind_text(7, rola.genre);

			res = stmt.step();
			if (res != DONE) {
				stderr.printf("Error al ejecutar la inserción: %s\n", db.errmsg());
				return;
			}
			resul_insert = new ResultadoInsertar(rola, true, album_insertado, performer_insertado);
			Notificador.get_instancia().notificar_rola_agregada(resul_insert);
			stdout.printf("Canción '%s' insertada correctamente.\n", rola.path);
		}

		
		private int agregar_album(Album a) {
			string insertar = "INSERT INTO albums (path, name, year) VALUES (?, ?, ?);";
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

		private int agregar_performer(Performer p) {
			string insertar = "INSERT INTO performers (id_type, name) VALUES (2, ?);";

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
		
		/*
		  Regresa el id de la rola recibida o -1 si no está en la base
		  de datos.
		*/
		private int id_rola(Rola r) {
			string buscar = "SELECT id_rola FROM rolas WHERE path = ? LIMIT 1;";
			Statement stmt_buscar;

			int res = db.prepare_v2(buscar, buscar.length, out stmt_buscar);
			if(res != OK) {
				stderr.printf("Error: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt_buscar.bind_text(1, r.path);
			
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
		private int id_album(Album a) {
			if(a.name == "Unknown")
				return 0;
			
			string buscar = "SELECT id_album FROM albums WHERE path = ? AND name = ? LIMIT 1;";
			Statement stmt_buscar;

			int res = db.prepare_v2(buscar, buscar.length, out stmt_buscar);
			if(res != OK) {
				stderr.printf("Error al preparar: %d: %s\n", db.errcode(), db.errmsg());
				return -1;
			}

			stmt_buscar.bind_text(1, a.path);
			stmt_buscar.bind_text(2, a.name);

			res = stmt_buscar.step();
			if(res == ROW)
				return stmt_buscar.column_int(0);
			return -1;
		}

		/*
		  Regresa el id del performer recibido o -1 si no está en la
		  base de datos.
		*/
		private int id_performer(Performer p) {
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
	}
}