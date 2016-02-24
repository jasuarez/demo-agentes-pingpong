/*
 * Created on 24-nov-2004
 *
 * Comportamiento que envia y recibe mensajes hasta que todos los agentes esten
 * listos para iniciar las medidas.
 * 
 * $Id$
 */
package pingpong.jade.ping;

import jade.core.AID;
import jade.core.Agent;
import jade.core.behaviours.SequentialBehaviour;
import jade.core.behaviours.SimpleBehaviour;
import jade.lang.acl.ACLMessage;
import pingpong.jade.Contador;

/**
 * Comportamiento que envia y recibe mensajes hasta que detecte que todos los
 * agentes estén listos para iniciar las medidas.
 * 
 * @author jota
 * @version $Revision$
 */
public class PingStartingBehaviour extends SimpleBehaviour {
	/**
	 * Cada cuantos envios comprobamos que todos los agentes
	 * agentes estén listos.
	 */
	private int _RETRIES=1;
	/**
	 * Cuenta el numero de envios que llevamos realizados.
	 */
	private int _count=0;
	/**
	 * El identificador del agente.
	 */
	private int _id;
	/**
	 * Variable para indicar que ya hemos incrementado
	 * una vez el contador.
	 */
	private boolean _notInc=true;
	/**
	 * El agente propietario de este comportamiento.
	 */
	private Agent _agent;
	
	/**
	 * Constructor del comportamiento.
	 * 
	 * @param ag El agente propietario
	 * @param id El identificador del agente
	 * @param retries Cada cuantos intentos comprobamos si todos están listos
	 */
	public PingStartingBehaviour(Agent ag, int id, int retries) {
		super(ag);
		_RETRIES=retries;
		_id=id;
		_agent=ag;
		enviar();
	}

	/**
	 * @see jade.core.behaviours.Behaviour#action()
	 */
	public void action() {
		ACLMessage reply = _agent.blockingReceive();
		//Suponemos que la respuesta es correcta, por lo que no la comprobamos
		_count++;
		if (_count<_RETRIES) {
			enviar();
		}
	}

	/**
	 * @see jade.core.behaviours.Behaviour#done()
	 */
	public boolean done() {
		if (_count < _RETRIES) {
			return false;			//No hemos acabado de enviar el paquete de mensajes
		} else {
			if (_notInc) {			//Evitamos incrementar el contador más de una vez
				_notInc=false;
				Contador.inc();
			}
			if (Contador.isUpper()) {
				((SequentialBehaviour) getParent()).addSubBehaviour(new PingMeasuringBehaviour(_agent,_id,100));
				return true;		//Ya estan todos los agentes en marcha
			} else {
				_count = 0;			//Todavia faltan agentes; seguir enviando mensajes
				enviar();
				return false;
			}
		}
	}

	/**
	 * Envia un mensaje al agente Pong correspondiente.
	 */
	private void enviar() {
		ACLMessage msg = new ACLMessage(ACLMessage.QUERY_REF);
		msg.setContent("(ping)");
		//Si el agente pong esta en la misma máquina plataforma hay que descomentar
		//la siguiente linea y comentar la de más abajo.

		//msg.addReceiver(new AID("pong"+_id, AID.ISLOCALNAME));
		msg.addReceiver(new AID("pong"+_id+"@quinlan", AID.ISGUID));
		_agent.send(msg);
	}
}
