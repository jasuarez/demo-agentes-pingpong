/*
 * Created on 24-nov-2004
 *
 * Wrapper que se encarga de lanzar agentes Pong que no cargan el sistema.
 * 
 * $Id$
 */
package pingpong.jade;

import jade.core.Agent;
import jade.wrapper.ControllerException;
import jade.wrapper.PlatformController;

/**
 * Clase encargada de lanzar tantos agentes Pong como se indique como
 * parámetro de entrada
 * 
 * @author jota
 * @version $Revision$
 */

public class Servidor extends Agent {
	protected void setup() {
		//Obtenemos el numero de agentes a crear
		Object[] args = getArguments();
		int numAgents = new Integer(args[0].toString()).intValue();
		PlatformController container = getContainerController();
		Contador.setLimit (numAgents);
		for (int i=numAgents; i > 0; i--) {
			try {
				//Creamos los agentes
				container.createNewAgent("pong"+i, "pingpong.jade.pong.PongAgent", null).start();
			} catch (ControllerException e) {
				System.out.println ("SERVIDOR> Ha ocurrido un problema al crear los pongs");
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
		System.out.println("Todos los agentes iniciados");
	}
}
