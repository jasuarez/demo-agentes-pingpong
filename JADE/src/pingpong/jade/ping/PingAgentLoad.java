/*
 * Created on 24-nov-2004
 *
 * Agente que realiza un ping durante el cual carga el sistema.
 * 
 * $Id$
 */
package pingpong.jade.ping;

import jade.core.Agent;
import jade.core.behaviours.SequentialBehaviour;

/**
 * Agente que lanza un ping, ejecuta una operación durante un segundo, espera
 * la respuesta y vuelve a repetir el proceso. Cuando detecta que todos los
 * agentes están creados (para ello se emplea un contador global) toma la
 * medida del tiempo de ida y vuelta de mensaje. Posteriormente sigue
 * repitiendo el proceso hasta que todos los agentes hayan hecho sus medidas.
 * 
 * @author jota
 * @version $Revision$
 */

public class PingAgentLoad extends Agent {
	/**
	 * Identificador (número) del agente
	 */
	private int _id;
	
	/**
	 * @see jade.core.Agent#setup()
	 */
	protected void setup() {
		SequentialBehaviour sb = new SequentialBehaviour();
		//Obtenemos nuestro identificador (número de agente) y luego comenzamos
		//el proceso de envio y recepción de mensajes.
		_id = new Integer(getAID().getLocalName().substring(4)).intValue();
		sb.addSubBehaviour(new PingStartingBehaviourLoad(this,_id,2));
		addBehaviour(sb);
	}
}
