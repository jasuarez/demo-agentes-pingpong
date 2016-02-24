/*
 * Created on 18-nov-2004
 *
 * Estado que envia y recibe mensajes hasta que todos los agentes hayan
 * tomado sus medidas.
 * 
 * $Id$
 */
package pingpong.jatlite.ping;

import pingpong.jatlite.Contador;
import KQMLLayer.KQMLmessage;
import RouterLayer.AgentClient.KQMLmail;

/**
 * Estado que envia y recibe mensajes hasta que detecte que todos los
 * agentes hayan realizado sus medidas.
 * 
 * @author jota
 * @version $Revision$
 */
public class PingEndingState extends PingState {
	/**
	 * Cada cuantos envios comprobamos si hay agentes
	 * que no hayan acabado sus medidas.
	 */
	protected int _RETRIES = 2;
	/**
	 * Cuenta el numero de envios que llevamos realizados.
	 */
	int _countRetries = _RETRIES;

	/**
	 * Constructor del estado.
	 * 
	 * @param context El agente propietario del estado
	 * @param idtfy El identificador del agente
	 */
	public PingEndingState (PingAgent context, int idtfy) {
		_context = context;
		ID = idtfy;
		Contador.dec();
		enviar();
	}

	/**
	 * @see pingpong.jatlite.ping.PingState#Act(java.lang.Object)
	 */
	public boolean Act(Object obj) {
		try {
			KQMLmail mail = new KQMLmail ((String) obj, 0);
			KQMLmessage kqml = mail.getKQMLmessage ();
			//Para ahorrar tiempo suponemos que el mensaje es de respuesta
			_countRetries--;
			if (_countRetries>0) {
				enviar();
			} else {
				_countRetries=_RETRIES;
				// Si aun hay agentes seguimos enviando
				if (!Contador.isLower()) {
					enviar();
				}
			}
		} catch (Exception e) {
			System.out.println ("PING"+ID+"> Error al recibir!!");
			e.printStackTrace();
		}
		return true;
	}

	/**
	 * Envía un mensaje.
	 * 
	 * @see pingpong.jatlite.ping.PingState#enviar()
	 */
	public void enviar () {
		String msg = "(achieve :sender ping" + ID + " :receiver pong" + ID + " :language java :ontology none :content (ping))";
		try {
			_context.sendMessage(msg);
		} catch (Exception e) {
			System.out.println ("PING"+ID+"> Error al enviar mensaje!!");
			e.printStackTrace();
		}
	}
}
