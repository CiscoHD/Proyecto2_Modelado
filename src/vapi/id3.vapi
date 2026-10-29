[CCode (cheader_filename = "id3_util.h")]
namespace Id3 {
	[CCode (cname = "Cancion", free_function = "liberar_datos")]
	[Compact]
	public class Cancion {
        public string? performer;
		public string? title;
		public string? album;
        public string? year;
		public string? genre;
		public string? track;
    }

	[CCode (cname = "recuperar_datos")]
	public Cancion? recuperar_datos(string ruta_archivo);
	
}