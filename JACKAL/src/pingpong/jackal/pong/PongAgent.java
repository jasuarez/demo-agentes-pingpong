/*
 * Created on 21-sep-2004
 *
 * Agente que responde mediante un "pong" a un "ping" realizado
 * por otro agente.
 * 
 * $Id$
 */
package pingpong.jackal.pong;

import J3.*;
import pingpong.jackal.*;


/**
 * Agente que contesta con un pong al agente que le envia un ping.
 * 
 * @author jota
 * @version $Revision$
 */
public class PongAgent extends Thread {
	/**
	 * Identificador (número) de agente.
	 */
	private int _id;
	/**
	 * El intercomunicador de Jackal.
	 */
	private Intercom _intercom;
	/**
	 * El fichero de configuración.
	 */
	String _resource = "file:///home/jota/eclipse/pingpong-JACKAL/server.kqmlrc";
	
	/**
	 * Crea un agente.
	 * 
	 * @param id Identificador del agente
	 */
	public PongAgent (int id) {
		_id = id;
		setName("pong"+_id);
		start ();
	}
	
	/**
	 * Crea un agente.
	 * 
	 * @param id Identificador del agente
	 * @param resource Fichero con la configuración del agente
	 */
	public PongAgent (int id, String resource) {
		_id = id;
		_resource = resource;
		setName("pong"+_id);
		start();
	}
	
	/**
	 * @see java.lang.Runnable#run()
	 */
	public void run () {
		Message msg, reply;
		FIFO queue;
		
		_intercom = new Intercom ("pong" + _id, _resource);
		Contador.inc();
		queue = _intercom.attend(null,"(achieve)", null, 8, true, true, 1, true, false);
		while ((msg = (Message) queue.dequeue()) != null) {
			try {
				//System.out.println ("Mensaje recibido");
				reply = new Message ("(reply :language jif :ontology none :content (pong))");
				reply.put ("in-reply-to", msg.get("reply-with"));
				reply.put ("receiver", msg.get("sender"));
				_intercom.send_message (reply);
				yield();
			} catch (Exception e) {
				System.err.println ("PONG"+_id+"> ERROR!!");
				e.printStackTrace();
			}
		}
	}
}
