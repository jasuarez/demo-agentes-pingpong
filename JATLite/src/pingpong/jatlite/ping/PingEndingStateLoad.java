/*
 * Created on 18-nov-2004
 *
 * Estado que envia y recibe mensajes hasta que todos los agentes hayan
 * tomado sus medidas. Durante los envíos se carga la máquina durante un
 * segundo.
 * 
 * $Id$
 */
package pingpong.jatlite.ping;

import pingpong.jatlite.Contador;
import pingpong.jatlite.FullLoad;
import KQMLLayer.KQMLmessage;
import RouterLayer.AgentClient.KQMLmail;

/**
 * Estado que envia y recibe mensajes hasta que detecte que todos los
 * agentes hayan realizado sus medidas. Durante los envíos se carga la
 * máquina durante un segundo.
 * 
 * @author jota
 * @version $Revision$
 */
public class PingEndingStateLoad extends PingStateLoad {
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
	 * El valor calculado como consecuencia de la operación.
	 */
	int valPing = 0;
	/**
	 * El valor devuelto por el agente Pong.
	 */
	int valPong = 0;
	/**
	 * La clase que carga al sistema.
	 */
	FullLoad _fl;

	/**
	 * El constructor del estado.
	 * 
	 * @param context El agente propietario del estado
	 * @param idtfy El identificador del agente
	 */
	public PingEndingStateLoad(PingAgentLoad context, int idtfy) {
		_context = context;
		ID = idtfy;
		_fl = new FullLoad();
		Contador.dec();
		enviar();
		valPing = _fl.load(ID);
	}

	/**
	 * @see pingpong.jatlite.ping.PingState#Act(java.lang.Object)
	 */
	public boolean Act(Object obj) {
		try {
			KQMLmail mail = new KQMLmail((String) obj, 0);
			KQMLmessage kqml = mail.getKQMLmessage();
			valPong = Integer.parseInt(kqml.getValue("content"));
			System.out.println("PING" + ID + "> El valor es "
					+ (valPing + valPong));
			_countRetries--;
			if (_countRetries > 0) {
				enviar();
				valPing = _fl.load(ID);
			} else {
				_countRetries = _RETRIES;
				// Si aun hay agentes seguimos enviando
				if (!Contador.isLower()) {
					enviar();
					valPing = _fl.load(ID);
				}
			}
		} catch (Exception e) {
			System.out.println("PING" + ID + "> Error al recibir!!");
			e.printStackTrace();
		}
		return true;
	}

	/**
	 * Envía un mensaje.
	 * 
	 * @see pingpong.jatlite.ping.PingState#enviar()
	 */
	public void enviar() {
		String msg = "(achieve :sender ping" + ID + " :receiver pong" + ID
				+ " :language java :ontology none :content " + ID + ")";
		try {
			_context.sendMessage(msg);
		} catch (Exception e) {
			System.out.println("PING" + ID + "> Error al enviar mensaje!!");
			e.printStackTrace();
		}
	}
}