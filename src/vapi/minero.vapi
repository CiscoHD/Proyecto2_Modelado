[CCode (cheader_filename = "minero.h")]
namespace Minero {
	[CCode (cname = "minar_directorio")]
	public void minar_directorio(string ruta_dir);

	[CCode (cname = "recuperar_artista")]
	public void recuperar_artista(string ruta_archivo);
}