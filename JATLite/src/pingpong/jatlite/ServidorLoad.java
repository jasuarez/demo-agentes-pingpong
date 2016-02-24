/*
 * Created on 16-nov-2004
 *
 * Programa que instancia los agentes pong que se indican en la linea de comandos.
 * 
 * $Id$
 */

package pingpong.jatlite;

import pingpong.jatlite.pong.PongAgentLoad;
import Abstract.Address;

/**
 * Clase que principal que lanza tantos agentes pong como se
 * indique como parámetro. Estos agentes cargan al sistema.
 * 
 * @author jota
 * @version $Revision$
 */
public class ServidorLoad {

	/**
	 * Programa principal.
	 * 
	 * @param args Argumentos de entrada
	 */
	public static void main(String[] args) {
		int numAgents = new Integer(args[0]).intValue();
		//Enrutador,aliana.dc.fi.udc.es,4402,MessageRouter,(MessageRouter)
		Address routerAddress = new Address ("Enrutador", "aliana", 4402, "MessageRouter", "(MessageRouter)");
		//Registrador,aliana.dc.fi.udc.es,4401,MessageRouter,(MessageRouterRegistrar)
		Address regAddress = new Address ("Registrador", "aliana", 4401, "MessageRouter", "(MessageRouterRegistrar)");
		//Servidor,null,5556,MessageRouter,(agent-info  :password jhc)
		Contador.setLimit (numAgents);
		for (int i = 1; i <= numAgents; i++) {
			Address pongAddress = new Address ("pong"+i, null, 5500+i, "MessageRouter", "(agent-info :password jhc)");
			new PongAgentLoad(i, pongAddress, routerAddress, regAddress);
		}
		//Esperamos a que todos los agentes pong estén listos
		do {
			try {
				System.out.print(Contador.get()+"|");
				Thread.sleep(5000);
			} catch (InterruptedException e) {
				// No hacemos nada
			}
		} while (!Contador.isUpper());
		System.out.println("Todos los agentes iniciados");
	}
}
