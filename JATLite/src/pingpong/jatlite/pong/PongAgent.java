/*
 * Created on 15-nov-2004
 *
 * Agente que responde mediante un "pong" a un "ping" realizado
 * por otro agente.
 * 
 * $Id$
 */
package pingpong.jatlite.pong;

import Abstract.Address;
import Abstract.ConnectionException;
import KQMLLayer.KQMLmessage;
import RouterLayer.AgentClient.KQMLmail;
import RouterLayer.AgentClient.RouterClientAction;
import pingpong.jatlite.*;

/**
 * Agente que contesta con un pong al agente que le envia un ping.
 * 
 * @author jota
 * @version $Revision$
 */
public class PongAgent extends RouterClientAction {
	/**
	 * Identificador (número) de agente.
	 */
	private int _id;
	
	/**
	 * Crea un agente.
	 * 
	 * @param id Identificador del agente
	 * @param myAddress Dirección del agente
	 * @param rterAddress Dirección del Router
	 * @param regAddres Dirección del Registrador
	 */
	public PongAgent (int id, Address myAddress, Address rterAddress, Address regAddres) {
		super();
		setMyAddress (myAddress);
		setRouterAddress (rterAddress);
		setRegistrarAddress (regAddres);
		_id = id;
		setName("pong"+_id);
		try {
			register();
			connect();
		} catch (ConnectionException e) {
			System.out.println ("PONG"+_id+"> Error de conexion!!");
			e.printStackTrace();
		}
		Contador.inc();
		start ();
	}

	/**
	 * @see RouterLayer.AgentClient.RouterClientAction#processMessage(java.lang.String, java.lang.Object)
	 */
	public void processMessage(String command, Object obj) {	
	}
	
	/**
	 * @see Abstract.AgentAction#Act(java.lang.Object)
	 */
	public boolean Act(Object obj) {
		try {
			KQMLmail mail = new KQMLmail ((String) obj, 0);
			KQMLmessage kqml = mail.getKQMLmessage ();
			String perf = kqml.getValue ("performative");
			String content = kqml.getValue ("content");
			String receiver = kqml.getValue ("sender");
			if (perf.equals ("achieve") && content.equals ("(ping)")) {
				String sendMsg = "(reply :sender " + getName () + " :receiver " + receiver + " :language java :ontology none :content (pong))";
				sendMessage (sendMsg);
				yield();
			}
		} catch (Exception e) {
			System.out.println ("PONG"+_id+"> Error al contestar!!");
			e.printStackTrace();
		}
		return true;
	}
}
