/*
 * Created on 20-sep-2004
 *
 * Programa que instancia los agentes pong que se indican en la linea de comandos.
 * 
 * $Id$
 */
package pingpong.jackal;

import pingpong.jackal.pong.PongAgentLoad;

/**
 * Clase que principal que lanza tantos agentes pong como se
 * indique como parámetro. Estos agentes cargan al sistema.
 * 
 *  @author jota
 * @version $Revision$
 */

public class ServidorLoad {
	/**
	 * Programa principal.
	 * 
	 * @param args Argumentos de entrada
	 */
	public static void main(String[] args) {
		//Obtenemos el número de agentes a crear
		int numAgents = new Integer(args[0]).intValue();
		ServidorLoad p = new ServidorLoad();
		// Creamos los agentes pong
		Contador.setLimit(numAgents);
		for (int i = numAgents; i > 0; i--) {
			new PongAgentLoad(i, "file:///home/jota/eclipse/pingpong-JACKAL/server.quinlan.kqmlrc");
		}
		//Esperamos hasta que todos los agentes pong esten creados
		do {
			try {
				System.out.print(Contador.get()+"|");
				Thread.sleep(5000);
			} catch (InterruptedException e) {
				//No hacemos nada
			}
		} while (!Contador.isUpper());
		System.out.println("Todos los agentes iniciados");
	}
}
