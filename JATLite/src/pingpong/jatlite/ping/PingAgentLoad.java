/*
 * Created on 16-nov-2004
 *
 * Agente que realiza un ping que carga al sistema.
 * 
 * $Id$
 */
package pingpong.jatlite.ping;

import Abstract.Address;
import Abstract.ConnectionException;
import RouterLayer.AgentClient.RouterClientAction;

/**
 * Agente que lanza un ping, ejecuta una operación durante un segundo, espera
 * la respuesta y vuelve a repetir el proceso. Cuando detecta que todos los
 * agentes están creados (para ello se emplea un contador global) toma la
 * medida del tiempo de ida y vuelta de mensaje. Posteriormente sigue
 * repitiendo el proceso hasta que todos los agentes hayan hecho sus medidas.
 * Entre envio y respuesta carga al sistema durante un segundo.
 * 
 * @author jota
 * @version $Revision$
 */
public class PingAgentLoad extends RouterClientAction {
	/**
	 * El estado del agente (esperando, midiendo o finalizando)
	 */
	private PingStateLoad _state;
	
	/**
	 * Crea un agente.
	 * 
	 * @param id Identificador del agente
	 * @param myAddress Dirección del agente
	 * @param rterAddress Dirección del router
	 * @param regAddres Dirección del Registrador
	 */
	public PingAgentLoad (int id, Address myAddress, Address rterAddress, Address regAddres) {
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
		setState(new PingStartingStateLoad (this, id));
		_state.ID = id;
		start ();
	}


	/**
	 * Cambia el estado del agente (empezando, midiendo o finalizando)
	 * @param state Nuevo estado
	 */
	public void setState(PingStateLoad state) {
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
