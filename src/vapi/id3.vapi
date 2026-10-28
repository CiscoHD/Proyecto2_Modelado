[CCode (cheader_filename = "id3_util.h")]
namespace Id3 {
	[CCode (cname = "DatosId3", free_function = "liberar_datos")]
	[Compact]
	public class DatosId3 {
        public string? performer;
		public string? title;
		public string? album;
        public string? year;
		public string? genre;
		public string? track;
    }

	[CCode (cname = "recuperar_datos")]
	public DatosId3? recuperar_datos(string ruta_archivo);
	
}