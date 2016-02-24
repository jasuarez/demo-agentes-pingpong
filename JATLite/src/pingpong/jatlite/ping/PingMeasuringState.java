/*
 * Created on 18-nov-2004
 *
 * Comportamiento que envia y recibe mensajes para medir el Round-Trip Time.
 * 
 * $Id$
 */
package pingpong.jatlite.ping;

import KQMLLayer.KQMLmessage;
import RouterLayer.AgentClient.KQMLmail;

/**
 * Estado que envia y recibe mensajes para medir el Round-Trip Time
 * medio. Para ello hace el envio y recepción varias veces, mide el tiempo y
 * calcula el tiempo medio por envio.
 * 
 * @author jota
 * @version $Revision$
 */
public class PingMeasuringState extends PingState {
	/**
	 * El numero de envios a medir.
	 */
	protected int _RETRIES = 100;
	/**
	 * Cuenta el numero de envios que llevamos realizados.
	 */
	protected int _countRetries = _RETRIES;
	
	/**
	 * Constructor del estado.
	 * 
	 * @param context El agente propietario
	 * @param idtfy El identificador del agente
	 */
	public PingMeasuringState (PingAgent context, int idtfy) {
		_context = context;
		ID = idtfy;
		System.out.println("PING"+ID+"> Inicio de la medida");
		TIEMPO = System.currentTimeMillis();
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
			if (_countRetries > 0) {
				enviar();
			} else {
				//Acabamos la medida, por lo que mostramos el tiempo y cambiamos de estado
				System.out.println("PING"+ID+"> Fin de la medida");
				System.out.println ("\n@PING"+ID+","+(System.currentTimeMillis() - TIEMPO)/_RETRIES);
				_context.setState (new PingEndingState (_context, ID));
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
