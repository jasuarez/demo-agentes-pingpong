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
 * agentes hayan hecho sus medidas. Entre el mensaje de envio y la respuesta
 * se carga la máquina durante un segundo.
 * 
 * @author jota
 * @version $Revision$
 */


public class PingAgentLoad extends Thread {
	/**
	 * Identificador (número) de agente.
	 */
	private int _id;
	/**
	 * El numero de envios a medir.
	 */
	private static final int _RETRIES = 10;

	/**
	 * La clase que carga al sistema.
	 */
	FullLoad _fl;

	/**
	 * El intercomunicador de Jackal.
	 */
	Intercom _intercom;
	/**
	 * El inbox de los mensajes de Jackal.
	 */
	FIFO _queue;
	/**
	 * El fichero de configuración.
	 */
	String _resource = "file:///home/jota/eclipse/pingpong-JACKAL/common.kqmlrc";
	
	/**
	 * Crea un agente.
	 * 
	 * @param id Identificador del agente
	 */
	public PingAgentLoad (int id) {
		_id = id;
		_fl = new FullLoad();
		setName ("ping"+id);
		start ();
	}
	
	/**
	 * @see java.lang.Runnable#run()
	 */
	public void run () {
		int intentosCarga = 2;
		
		_intercom = new Intercom ("ping" + _id, _resource);
		_queue = _intercom.attend(null,"(reply)", null, 8, true, true, 1, true, false);
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
		FIFO queue;
		int valPing=0;
		int valPong=0;
		Message reply;
		
		//Creamos el mensaje
		Message msg = new Message("(achieve :language jif :ontology none)");
		msg.put("receiver", new FQAN("pong" + _id + ".ans"));
		msg.put("content", String.valueOf(_id));
		
		//Enviamos los mensajes y esperamos la respuesta de los mismos
		long tiempo = System.currentTimeMillis();
		for (int i=0; i < intentos; i++) {
			_intercom.send_message(msg);
			valPing = _fl.load(_id);
			reply = (Message) _queue.dequeue();
			valPong = Integer.parseInt((String) (reply.get("content")));
			System.out.println("PING"+_id+"> El valor es "+(valPing+valPong));
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
