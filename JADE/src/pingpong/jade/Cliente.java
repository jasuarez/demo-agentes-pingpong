/*
 * Created on 24-nov-2004
 *
 * Wrapper que se encarga de lanzar agentes Ping que no cargan el sistema.
 * 
 * $Id$
 */
package pingpong.jade;

import jade.core.Agent;
import jade.wrapper.ControllerException;
import jade.wrapper.PlatformController;

/**
 * Clase encargada de lanzar tantos agentes Ping como se indique como
 * parámetro de entrada
 * 
 * @author jota
 * @version $Revision$
 */
public class Cliente extends Agent {
	/**
	 * @see jade.core.Agent#setup()
	 */
	protected void setup() {
		//Obtenemos el numero de agentes a crear
		Object[] args = getArguments();
		int numAgents = new Integer(args[0].toString()).intValue();
		PlatformController container = getContainerController();
		Contador.setLimit(numAgents);
		for (int i = numAgents; i > 0; i--) {
			try {
				//Creamos los agentes
				container.createNewAgent("ping" + i,
						"pingpong.jade.ping.PingAgent", null).start();
			} catch (ControllerException e) {
				System.out
						.println("CLIENTE> Ha ocurrido un problema al crear los pings");
				e.printStackTrace();
			}
		}
		System.out.println("Todos los agentes iniciados");
		do {
			try {
				System.out.print(Contador.get() + "-");
				Thread.sleep(5000);
			} catch (InterruptedException e) {
				// No hacemos nada
			}
		} while (!Contador.isLower());
		System.out.println(Contador.get());
		System.out.println("Fin de las pruebas");
		//Terminamos bruscamente el sistema
		System.exit(0);
	}
}