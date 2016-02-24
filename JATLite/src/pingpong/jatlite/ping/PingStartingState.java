/*
 * Created on 18-nov-2004
 *
 * Estado que envia y recibe mensajes hasta que todos los agentes esten
 * listos para iniciar las medidas.
 * 
 * $Id$
 */
package pingpong.jatlite.ping;

import pingpong.jatlite.Contador;
import KQMLLayer.KQMLmessage;
import RouterLayer.AgentClient.KQMLmail;

/**
 * Estado que envia y recibe mensajes hasta que detecte que todos los
 * agentes estén listos para iniciar las medidas.
 * 
 * @author jota
 * @version $Revision$
 */
public class PingStartingState extends PingState {
	/**
	 * Cada cuantos envios comprobamos que todos los agentes
	 * agentes estén listos.
	 */
	protected int _RETRIES = 2;
	/**
	 * Cuenta el numero de envios que llevamos realizados.
	 */
	int _countRetries = _RETRIES;

	/**
	 * Constructor del estado.
	 * 
	 * @param context El agente propietario
	 * @param idtfy El identificador del agente
	 */
	public PingStartingState (PingAgent context, int idtfy) {
		_context = context;
		ID = idtfy;
		Contador.inc();
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
				//Si no estan todos los agentes seguimos enviando
				if (!Contador.isUpper()) {
					enviar();
				} else {
				//Cambiamos de estado
				 _context.setState (new PingMeasuringState (_context, ID));
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
