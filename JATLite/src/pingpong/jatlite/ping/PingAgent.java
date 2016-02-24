/*
 * Created on 16-nov-2004
 *
 * Agente que realiza un ping.
 * 
 * $Id$
 */
package pingpong.jatlite.ping;

import Abstract.Address;
import Abstract.ConnectionException;
import RouterLayer.AgentClient.RouterClientAction;

/**
 * Agente que lanza un ping, espera la respuesta y vuelve a repetir el proceso.
 * Cuando detecta que todos los agentes están creados (para ello se emplea un
 * contador global) toma la medida del tiempo de ida y vuelta de mensaje.
 * Posteriormente sigue enviando y recibiendo mensajes hasta que todos los
 * agentes hayan hecho sus medidas.
 * 
 * @author jota
 * @version $Revision$
 */
public class PingAgent extends RouterClientAction {
	/**
	 * El estado del agente (esperando, midiendo o finalizando)
	 */
	private PingState _state;
	
	/**
	 * Crea un agente.
	 * 
	 * @param id Identificador del agente
	 * @param myAddress Dirección del agente
	 * @param rterAddress Dirección del router
	 * @param regAddres Dirección del Registrador
	 */
	public PingAgent (int id, Address myAddress, Address rterAddress, Address regAddres) {
		super();
		setMyAddress (myAddress);
		setRouterAddress (rterAddress);
		setRegistrarAddress (regAddres);
		setName("ping"+id);
		try {
			register();
			connect();
		} catch (ConnectionException e) {
			System.out.println ("PING"+id+"> Error de conexion!!");
			e.printStackTrace();
		}
		//Enviamos hasta que todos los agentes estén iniciados
		setState(new PingStartingState (this, id));
		_state.ID = id;
		start ();
	}


	/**
	 * Cambia el estado del agente (empezando, midiendo o finalizando)
	 * @param state Nuevo estado
	 */
	public void setState(PingState state) {
		_state = state;
	}


	/**
	 * @see RouterLayer.AgentClient.RouterClientAction#processMessage(java.lang.String, java.lang.Object)
	 */
	public void processMessage(String command, Object obj) {
	}
	
	/**
	 * @see Abstract.AgentAction#Act(java.lang.Object)
	 */
	public boolean Act (Object obj) {
		return _state.Act(obj);
	}
}
