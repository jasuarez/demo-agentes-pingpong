/*
 * Created on 20-sep-2004
 *
 * Programa que instancia los agentes ping y pong que se indican en la linea
 * de comandos.
 * 
 * $Id$
 */
package pingpong.jackal;

import pingpong.jackal.ping.PingAgent;
import pingpong.jackal.pong.PongAgent;

/**
 * Clase que principal que lanza tantos agentes ping y pong como se
 * indique como parámetro.
 * 
 * @author jota
 * @version $Revision$
 */
public class ClienteyServidor {
	/**
	 * Crea parejas de agentes ping y pong.
	 * 
	 * @param n Número de parejas a crear
	 */
	public void initAgents (int n) {
		Contador.setLimit(n);
		// Primero creamos los agentes pong
		for (int i = n; i > 0; i--) {
			new PongAgent (i);
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
		Contador.reset();
		Contador.setLimit(n);
		// Ahora creamos los agentes ping
		for (int i = n; i > 0; i--) {
			new PingAgent (i);
		}
	}
	
	/**
	 * El programa principal.
	 * 
	 * @param args Argumentos de entrada.
	 */
	public static void main(String[] args) {
		//Obtenemos el número de parejas a crear
		int numAgents = new Integer(args[0]).intValue();
		ClienteyServidor p = new ClienteyServidor();
		// Creamos el agente ans y los agentes ping y pong
		//Ans ans = new Ans();
		p.initAgents(numAgents);
		// Esperamos a que todos los agentes hayan acabado de trabajar
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
