/*
 * Created on 20-sep-2004
 *
 * Programa que instancia los agentes ping que se indican en la linea
 * de comandos.
 * 
 * $Id$
 */
package pingpong.jackal;

import pingpong.jackal.ping.PingAgentLoad;

/**
 * Clase que principal que lanza tantos agentes ping como se
 * indique como parámetro. Estos agentes cargan al sistema
 * 
 * @author jota
 * @version $Revision$
 */
public class ClienteLoad {
	/**
	 * Programa principal.
	 * 
	 * @param args Argumentos de entrada
	 */
	public static void main(String[] args) {
		//Obtenemos el número de agentes a crear
		int numAgents = new Integer(args[0]).intValue();
		ClienteLoad p = new ClienteLoad();
		// Creamos los agentes ping
		Contador.setLimit(numAgents);
		for (int i = numAgents; i > 0 ; i--) {
			new PingAgentLoad(i);
		}
		System.out.println("Todos los agentes iniciados");
		// Esperamos a que todos los agentes hayan acabado de trabajar
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
