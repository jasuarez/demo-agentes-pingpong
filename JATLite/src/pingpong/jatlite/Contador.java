/*
 * Created on 03-nov-2004
 *
 * Mostramos un grafico de como funciona la histeresis
 * 
 *     contador
 *        ^
 *        |
 * limite +           ************
 *        |           *          *
 *        |           *          *
 *      0 +************          **********
 *        ---+-----------+-----------+--------> tiempo
 *        !isUpper()   isUpper()   isUpper()
 *        !isLower()   !islower()  isLower()
 * 
 * $Id$
 */

package pingpong.jatlite;

/**
 * Contador con histeresis.
 * 
 * @author jota
 * @version $Revision$
 */
public class Contador {
	/**
	 * El valor del contador.
	 */
	private static int _contador=0;
	/**
	 * El límite a partir del cual conmuta.
	 */
	private static int _limit=1;
	/**
	 * Verdadero si ha alcanzado alguna vez el límite
	 */
	private static boolean _upper = false;
	/**
	 * Verdadero si ha llegado a cero después de alcanzar el límite
	 */
	private static boolean _lower = false;
	
	/**
	 * Resetea el contador
	 */
	public static synchronized void reset() {
		_contador=0;
		_limit=1;
		_upper=false;
		_lower=false;
	}
	
	/**
	 * Incrementa en una unidad el contador.
	 * 
	 * @return El valor actual del contador
	 */
	public static synchronized int inc() {
		_contador++;
		_upper = _upper || _contador==_limit;
		return _contador;
	}
	
	/**
	 * Decrementa en una uniad el contador.
	 * 
	 * @return El valor actual del contador
	 */
	public static synchronized int dec() {
		_contador--;
		_lower = _upper && _contador==0;
		return _contador;
	}
	
	/**
	 * Establece el límite en el cual se produce el cambio de histeresis.
	 * Deberia ser la primera funcion a llamar.
	 * 
	 * @param lim El valor del limite
	 */
	public static synchronized void setLimit(int lim) {
		_limit = lim;
	}
	
	/**
	 * Indica si hemos llegado hasta abajo en el contador.
	 * 
	 * @return True si el contador llega a cero despues del cambio de histeresis
	 */
	public static boolean isLower() {
		return _lower;
	}
	
	/**
	 * Indica si se ha realizado un cambio de histeresis.
	 * 
	 * @return True si se ha producido dicho cambio (el contador llego al limite)
	 */
	public static boolean isUpper() {
		return _upper;
	}
	
	
	/**
	 * Devuelve el valor del contador.
	 * 
	 * @return el valor del contador
	 */
	public static int get() {
		return _contador;
	}
}
