/*
 * Created on 18-nov-2004
 *
 * El estado del agente.
 * 
 * $Id$
 */
package pingpong.jatlite.ping;

/**
 * Clase que encapsula el estado del agente (ver subclases).
 * 
 * @author jota
 * @version $Revision$
 */
public abstract class PingState {
	/**
	 * Tiempo de comienzo de las medidas.
	 */
	public long TIEMPO = -1;
	/**
	 * El identificador del agente propietario del estado.
	 */
	public int ID;
	/**
	 * El agente propietario del estado.
	 */
	protected PingAgent _context;
	
	public abstract boolean Act(Object obj);
	
	/**
	 * Envia un mensaje. 
	 */
	public abstract void enviar ();
}
