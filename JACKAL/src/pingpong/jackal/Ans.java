/*
 * Created on 20-sep-2004
 *
 * Programa que lanza el Agent Name Service.
 * 
 * $Id$
 */
package pingpong.jackal;

import J3.*;

/**
 * Agent Name Server. This agent has no other functions.
 * 
 * @author jota
 * @version $Revision$
 */
class Ans extends Thread {
	/**
	 * El intercomunicador de Jackal.
	 */
	Intercom _intercom;
	/**
	 * El fichero de configuración del ANS de Jackal.
	 */
	String _resource = "file:///home/jota/eclipse/pingpong-JACKAL/ans.kqmlrc";
	/**
	 * El nombre del hijo en el que se ejecuta el ANS.
	 */
	String _name="ans";
	
	/**
	 * Función principal del progama.
	 * 
	 * @param args Argumentos de entrada
	 */
	public static void main(String[] args) {
		new Ans();
		// Esperamos a que todos los agentes hayan acabado de trabajar
		try {
			Thread.sleep(5000);
		} catch (InterruptedException e) {
			// No hacemos nada
		}
		System.out.println("ANS iniciado y listo");
	}
	
	/**
	 * Constructor del ANS
	 */
	public Ans() {
		setName(_name);
		start();
	}
	
	/**
	 * @see java.lang.Runnable#run()
	 */
	public void run() {
		_intercom = new Intercom(_name, _resource);
	}
}
