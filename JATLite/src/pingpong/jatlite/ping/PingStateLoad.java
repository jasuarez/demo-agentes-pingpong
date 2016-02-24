/*
 * Created on 15-dic-2004
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
public abstract class PingStateLoad extends PingState {
	/**
	 * El agente propietario del estado.
	 */
	protected PingAgentLoad _context;
}
