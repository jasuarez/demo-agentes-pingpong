/*
 * Created on 24-nov-2004
 *
 * Wrapper que se encarga de lanzar agentes Ping y Pong que cargan el
 * sistema, todos ellos dentro de la misma máquina virtual Java.
 * 
 * $Id$
 */
package pingpong.jade;

import jade.core.Agent;
import jade.wrapper.ControllerException;
import jade.wrapper.PlatformController;

/**
 * Clase encargada de lanzar tantos agentes Ping y Pong como se indique como
 * parámetro de entrada
 * 
 * @author jota
 * @version $Revision$
 */
public class ClienteyServidorLoad extends Agent {
	protected void setup() {
		Object[] args = getArguments();
		int numAgents = new Integer(args[0].toString()).intValue();
		PlatformController container = getContainerController();
		Contador.setLimit(numAgents);
		for (int i=numAgents; i > 0; i--) {
			try {
				//Creamos los agentes pong
				container.createNewAgent("pong"+i, "pingpong.jade.pong.PongAgentLoad", null).start();
			} catch (ControllerException e) {
				System.out.println ("CLIENTE-SERVIDOR> Ha ocurrido un problema al crear los pongs");
				e.printStackTrace();
			}
		}
		// Esperamos a que los pongs esten creados
		do {
			try {
				System.out.println(Contador.get()+"|");
				Thread.sleep(5000);
			} catch (InterruptedException e) {
				// No hacemos nada
			}
		} while (!Contador.isUpper());
		Contador.reset();
		Contador.setLimit(numAgents);
		for (int i=numAgents; i > 0; i--) {
			try {
				//Creamos los agentes ping
				container.createNewAgent("ping"+i, "pingpong.jade.ping.PingAgentLoad", null).start();
			} catch (ControllerException e) {
				System.out.println ("CLIENTE-SERVIDOR> Ha ocurrido un problema al crear los pings");
				e.printStackTrace();
			}
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
