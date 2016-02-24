/*
 * Created on 16-nov-2004
 * Programa que instancia los agentes ping y pong que se indican en la linea
 * de comandos.
 * 
 * $Id$
 */
package pingpong.jatlite;

import pingpong.jatlite.ping.PingAgent;
import pingpong.jatlite.pong.PongAgent;
import Abstract.Address;

/**
 * Clase que principal que lanza tantos agentes ping y pong como se
 * indique como parámetro.
 * 
 * @author jota
 * @version $Revision$
 */
public class ClienteyServidor {

	/**
	 * El programa principal.
	 * 
	 * @param args Argumentos de entrada.
	 */
	public static void main(String[] args) {
		int numAgents = new Integer(args[0]).intValue();
		//Enrutador,aliana.dc.fi.udc.es,4402,MessageRouter,(MessageRouter)
		Address routerAddress = new Address ("Enrutador", "aliana", 4402, "MessageRouter", "(MessageRouter)");
		//Registrador,aliana.dc.fi.udc.es,4401,MessageRouter,(MessageRouterRegistrar)
		Address regAddress = new Address ("Registrador", "aliana", 4401, "MessageRouter", "(MessageRouterRegistrar)");
		//Servidor,null,5556,MessageRouter,(agent-info  :password jhc)
		Contador.setLimit(numAgents);
		for (int i = 1; i <= numAgents; i++) {
			Address pongAddress = new Address ("pong"+i, null, 5500+i, "MessageRouter", "(agent-info :password jhc)");
			new PongAgent(i, pongAddress, routerAddress, regAddress);
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
		Contador.reset();
		Contador.setLimit(numAgents);
		for (int i = 1; i <= numAgents; i++) {
			Address pingAddress = new Address ("ping"+i, null, 5600+i, "MessageRouter", "(agent-info :password jhc)");
			new PingAgent(i, pingAddress, routerAddress, regAddress);
		}
		System.out.println("Todos los agentes iniciados");
		do {
			try {
				System.out.print(Contador.get()+"-");
				Thread.sleep(5000);
			} catch 	(InterruptedException e) {
				// No hacemos nada
			}
		} while (!Contador.isLower());
		System.out.println(Contador.get());
		System.out.println("Fin de las pruebas");
		//Terminamos bruscamente el sistema
		System.exit(0);
	}
}
