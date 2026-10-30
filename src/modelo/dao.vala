using GLib;
using Sqlite;

namespace Bdm {
	public class Dao {
		public static Dao instancia; 
		private unowned Database db {get; private set;}

		private Dao() {
			string dir_datos = Path.build_filename(Environment.get_user_data_dir(), "bd_musical");
			if(!FileUtils.test(dir_datos, FileTest.IS_DIR)) {
				DirUtils.create_with_parents(dir_datos, 0700);
			}
			
			string ruta_db = Path.build_filename(dir_datos, "datos.db");
			bool existe_db = FileUtils.test(ruta_db, FileTest.EXISTS);

			Database db_tmp;
			int resul = Database.open(ruta_db, out db_tmp); 
			if(resul != OK) {
				stderr.printf("ERROR: No se puede abrir la base de datos\n");
				return;
			}
			db = db_tmp;
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

				int resul = db.exec(recurso_sql, null, out errmsg);
				if(resul != OK) {
					stderr.printf("Error: %s\n", errmsg);
					return;
				}
			} catch(Error e) {
				stderr.printf("ERROR: No se pudo cargar el esquema del recurso.\n");
			}
		}
	}
}