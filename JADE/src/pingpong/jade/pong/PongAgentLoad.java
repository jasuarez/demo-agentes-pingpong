/*
 * Created on 24-nov-2004
 * 
 * Agente que realiza un pong. Antes de contestar carga al sistema.
 * 
 * $Id$
 */
package pingpong.jade.pong;

import jade.core.Agent;
import jade.core.behaviours.CyclicBehaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;
import pingpong.jade.*;

/**
 * Agente que contesta con un pong al agente que le envia un ping.
 * El contenido del pong es el resultado de una operación que carga
 * al sistema durante un segundo.
 * 
 * @author jota
 * @version $Revision$
 */public class PongAgentLoad extends Agent {
	
	/**
	 * El comportamiento del agente que hace que conteste con un pong al
	 * recibir un ping. El contenido es el resultado de una operación.
	 * 
	 * @author jota
	 * @version $Revision$
	 */
	public class Contestar extends CyclicBehaviour {
		/**
		 * @see jade.core.behaviours.Behaviour#action()
		 */
		public void action() {
			int contenido;
			
			FullLoad fl = new FullLoad();
			// Aqui debemos contestar al mensaje
			ACLMessage msg = blockingReceive(MessageTemplate.MatchPerformative(ACLMessage.QUERY_REF));
			if (msg != null) {
				ACLMessage reply = msg.createReply();
				reply.setPerformative(ACLMessage.INFORM_REF);
				contenido = Integer.parseInt(msg.getContent());
				reply.setContent(String.valueOf(fl.load(contenido)));
				send(reply);
			} else {
				block();
			}
		}
	}
	
	/**
	 * @see jade.core.Agent#setup()
	 */
	protected void setup() {
		addBehaviour(new Contestar());
		Contador.inc();
	}
}
