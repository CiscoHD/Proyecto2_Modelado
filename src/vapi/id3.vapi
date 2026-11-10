[CCode (cheader_filename = "id3_util.h")]
namespace Id3 {
	[CCode (cname = "Datos", free_function = "liberar_datos")]
	[Compact]
	public class Datos {
        public string? performer;
		public string? title;
		public string? album;
        public string? year;
		public string? genre;
		public string? track;
		public string  path;
    }

	[CCode (cname = "recuperar_datos")]
	public Datos? recuperar_datos(string ruta_archivo);
	
}