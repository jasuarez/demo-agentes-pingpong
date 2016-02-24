/*
 * Created on 21-sep-2004
 *
 * Agente que envia un "ping" a otro agente y espera la respuesta.
 * 
 * $Id$
 */
package pingpong.jackal.ping;

import pingpong.jackal.*;
import J3.*;


/**
 * Agente que lanza un ping, espera la respuesta y vuelve a repetir el proceso.
 * Cuando detecta que todos los agentes están creados (para ello se emplea un
 * contador global) toma la medida del tiempo de ida y vuelta de mensaje.
 * Posteriormente sigue enviando y recibiendo mensajes hasta que todos los
 * agentes hayan hecho sus medidas.
 * 
 * @author jota
 * @version $Revision$
 */
public class PingAgent extends Thread {
	/**
	 * Identificador (número) de agente.
	 */
	private int _id;
	/**
	 * El numero de envios a medir.
	 */
	private static final int _RETRIES = 10;
	/**
	 * El intercomunicador de Jackal.
	 */
	Intercom _intercom;
	/**
	 * El fichero de configuración.
	 */
	String _resource = "file:///home/jota/eclipse/pingpong-JACKAL/common.kqmlrc";
	
	/**
	 * Crea un agente.
	 * 
	 * @param id Identificador del agente
	 */
	public PingAgent (int id) {
		_id = id;
		setName ("ping"+id);
		start ();
	}
	
	/**
	 * @see java.lang.Runnable#run()
	 */
	public void run () {
		int intentosCarga = 2;
		
		_intercom = new Intercom ("ping" + _id, _resource);
		try {
			// Esperamos a que todos los agentes estén activos, mientras enviamos mensajes
			Contador.inc();
			do {
				enviar(intentosCarga);
			} while (!Contador.isUpper());
			// Mostramos el tiempo de envio
			System.out.println ("\n@PING"+_id+","+enviar());
			//Seguimos enviando hasta que no queden agentes
			Contador.dec();
			do {
				enviar(intentosCarga);
			} while (!Contador.isLower());
		} catch (Exception e) {
			System.out.println ("PING"+_id+"> ERROR!!");
			e.printStackTrace();
		}
	}
	
	/**
	 * Envía un mensaje varias veces.
	 * 
	 * @param intentos Número de veces a enviar
	 * @return Tiempo medio (ms.) de envio y recepción de un mensaje y su respuesta.
	 * @throws MessageX
	 * @throws FQANX
	 */
	private long enviar(int intentos) throws MessageX, FQANX {
		//Creamos el mensaje
		Message msg = new Message("(achieve :language jif :ontology none :content (ping))");
		msg.put("receiver", new FQAN("pong" + _id + ".ans"));
		
		//Enviamos los mensajes y esperamos la respuesta de los mismos
		long tiempo = System.currentTimeMillis();
		for (int i=0; i < intentos; i++) {
			//Message reply = (Message) _intercom.attend(msg, null, null, 5, false, true, 1, true, false).dequeue();
			_intercom.attend(msg);
			yield();
		}
		return (System.currentTimeMillis() - tiempo)/intentos;
	}
	
	/**
	 * Envia un paquete de mensajes.
	 * 
	 * @return El tiempo medio de envio y recepción de respuesta por mensaje
	 * @throws MessageX
	 * @throws FQANX
	 * @see _RETRIES
	 */
	private long enviar () throws MessageX, FQANX {
		System.out.println("PING"+_id+"> Inicio de la medida");
		long tm = enviar(_RETRIES);
		System.out.println("PING"+_id+"> Fin de la medida");
		return tm;
	}
}
