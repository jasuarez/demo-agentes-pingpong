/*
 * Created on 24-nov-2004
 *
 * Agente que realiza un pong.
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
 * 
 * @author jota
 * @version $Revision$
 */
public class PongAgent extends Agent {
	
	/**
	 * El comportamiento del agente que hace que conteste con un pong al
	 * recibir un ping.
	 * 
	 * @author jota
	 * @version $Revision$
	 */
	public class Contestar extends CyclicBehaviour {

		/**
		 * @see jade.core.behaviours.Behaviour#action()
		 */
		public void action() {
			// Aqui debemos contestar al mensaje
			ACLMessage msg = blockingReceive(MessageTemplate.MatchPerformative(ACLMessage.QUERY_REF));
			//System.out.println("Mensaje recibido");
			if (msg != null) {
				ACLMessage reply = msg.createReply();
				reply.setPerformative(ACLMessage.INFORM_REF);
				reply.setContent("(pong)");
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
