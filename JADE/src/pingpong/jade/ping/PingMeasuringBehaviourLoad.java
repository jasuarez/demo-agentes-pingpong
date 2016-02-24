/*
 * Created on 24-nov-2004
 *
 * Comportamiento que envia y recibe mensajes para medir el Round-Trip Time.
 * Entre el envio y la recepción se carga la máquina durante un segundo.
 */
package pingpong.jade.ping;

import jade.core.AID;
import jade.core.Agent;
import jade.core.behaviours.SequentialBehaviour;
import jade.core.behaviours.SimpleBehaviour;
import jade.lang.acl.ACLMessage;
import pingpong.jade.Contador;
import pingpong.jade.FullLoad;

/**
* Comportamiento que envia y recibe mensajes para medir el Round-Trip Time
* medio. Para ello hace el envio y recepción varias veces, mide el tiempo y
* calcula el tiempo medio por envio. Entre el envio y la recepción se carga
* la máquina durante un segundo.
* 
* @author jota
* @version $Revision$
*/
public class PingMeasuringBehaviourLoad extends SimpleBehaviour {
	/**
	 * El valor calculado como consecuencia de la operación.
	 */
	private int valPing=0;
	/**
	 * El valor devuelto por el agente Pong.
	 */
	private int valPong=0;
	/**
	 * El numero de envios a medir.
	 */
	private int _RETRIES=100;
	/**
	 * Cuenta el numero de envios que llevamos realizados.
	 */
	private int _count=0;
	/**
	 * El identificador del agente.
	 */
	private int _id;
	/**
	 * La hora de comienzo de envio (<code>currentTimeMillis</code>).
	 */
	private long _timeInit;
	/**
	 * El agente propietario de este comportamiento.
	 */
	private Agent _agent;
	/**
	 * La clase que carga al sistema.
	 */
	private FullLoad _fl;
	
	/**
	 * Constructor del comportamiento.
	 * 
	 * @param ag El agente propietario
	 * @param id El identificador del agente
	 * @param retries El numero de envios a medir
	 */
	public PingMeasuringBehaviourLoad(Agent ag, int id, int retries) {
		super(ag);
		_RETRIES=retries;
		_id=id;
		_agent=ag;
		_fl = new FullLoad();
		System.out.println ("PING"+_id+"> Iniciando la medida");
		_timeInit=System.currentTimeMillis();
		enviar();
		valPing=_fl.load(_id);
	}

	/**
	 * @see jade.core.behaviours.Behaviour#action()
	 */
	public void action() {
		ACLMessage reply = _agent.blockingReceive();
		if (reply!=null) {
			valPong=Integer.parseInt(reply.getContent());
			System.out.println("PING"+_id+"> El valor es "+(valPing+valPong));
		}
		_count++;
		if (_count<_RETRIES) {
			enviar();
			valPing=_fl.load(_id);
		}
	}

	/**
	 * @see jade.core.behaviours.Behaviour#done()
	 */
	public boolean done() {
		if (_count < _RETRIES) {
			return false;			//No hemos acabado de enviar el paquete de mensajes
		} else {
			System.out.println ("PING"+_id+"> Fin de la medida");
			System.out.println ("\n@PING"+_id+","+(System.currentTimeMillis()-_timeInit)/_RETRIES);
			Contador.dec();
			((SequentialBehaviour) getParent()).addSubBehaviour(new PingEndingBehaviourLoad(_agent,_id,2));
			return true;
		}
	}

	/**
	 * Envia un mensaje al agente Pong correspondiente.
	 */
	private void enviar() {
		ACLMessage msg = new ACLMessage(ACLMessage.QUERY_REF);
		msg.setContent(String.valueOf(_id));
		//Si el agente pong esta en la misma máquina plataforma hay que descomentar
		//la siguiente linea y comentar la de más abajo.

		msg.addReceiver(new AID("pong"+_id, AID.ISLOCALNAME));
		//msg.addReceiver(new AID("pong"+_id+"@quinlan", AID.ISGUID));
		_agent.send(msg);
	}
}
