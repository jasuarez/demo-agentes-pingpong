/*
 * Created on 10-dic-2004
 *
 * Permite cargar el sistema durante el tiempo indicado.
 * 
 * $Id$
 */

package pingpong.jatlite;

/**
 * Clase para cargar el sistema durante un determinado tiempo.
 * 
 * @author jota
 * @version $Revision$
 */
public class FullLoad {
	/**
	 * La duraci�n de la carga en milisegundos.
	 */
	int _duracion = 1000;
	
	/**
	 * Constructor para cargar la m�quina durante 1 segundo.
	 */
	public FullLoad() {
	}
	
	/**
	 * Constructor para cargar la m�quina durante el tiempo indicado.
	 * 
	 * @param duracion El tiempo en milisegundos durante el cual hay que cargar
	 * la m�quina
	 */
	public FullLoad(int duracion) {
		_duracion=duracion;
	}

	/**
	 * Carga la m�quina durante un tiempo determinado. Para ello ejecuta una
	 * operaci�n durante ese tiempo.
	 * 
	 * @param vinit Una semilla empleada para la operaci�n
	 * @return El resultado de la operaci�n
	 */
	public int load(int vinit) {
		long actual = System.currentTimeMillis();
		int vreturn = vinit;
		while ((System.currentTimeMillis() - actual) < _duracion) {
			vreturn += Math.round(Math.cos(System.currentTimeMillis()%1000)*100);
		}
		return vreturn;
	}
}
