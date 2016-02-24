/*
 * Created on 18-nov-2004
 *
 * Comportamiento que envia y recibe mensajes para medir el Round-Trip Time.
 * Durante los envíos se carga la máquina durante un segundo.
 * 
 * $Id$
 */
 package pingpong.jatlite.ping;

import pingpong.jatlite.FullLoad;
import KQMLLayer.KQMLmessage;
import RouterLayer.AgentClient.KQMLmail;

/**
 * Estado que envia y recibe mensajes para medir el Round-Trip Time
 * medio. Para ello hace el envio y recepción varias veces, mide el tiempo y
 * calcula el tiempo medio por envio. Durante los envíos se carga la máquina
 * durante un segundo.
 * 
 * @author jota
 * @version $Revision$
 */
public class PingMeasuringStateLoad extends PingStateLoad {
	/**
	 * El numero de envios a medir.
	 */
	protected int _RETRIES = 100;
	/**
	 * Cuenta el numero de envios que llevamos realizados.
	 */
	protected int _countRetries = _RETRIES;
	/**
	 * La clase que carga al sistema.
	 */
	FullLoad _fl;
	/**
	 * El valor calculado como consecuencia de la operación.
	 */
	int valPing = 0;
	/**
	 * El valor devuelto por el agente Pong.
	 */
	int valPong = 0;

	/**
	 * El constructor del estado.
	 * 
	 * @param context El agente propietario del estado
	 * @param idtfy El identificador del agente
	 */
	public PingMeasuringStateLoad(PingAgentLoad context, int idtfy) {
		_context = context;
		ID = idtfy;
		_fl = new FullLoad();
		System.out.println("PING" + ID + "> Inicio de la medida");
		TIEMPO = System.currentTimeMillis();
		enviar();
		valPing = _fl.load(ID);
	}

	/**
	 * @see pingpong.jatlite.ping.PingState#Act(java.lang.Object)
	 */
	public boolean Act(Object obj) {
		try {
			KQMLmail mail = new KQMLmail((String) obj, 0);
			KQMLmessage kqml = mail.getKQMLmessage();
			valPong = Integer.parseInt(kqml.getValue("content"));
			System.out.println("PING" + ID + "> El valor es "
					+ (valPing + valPong));
			_countRetries--;
			if (_countRetries > 0) {
				enviar();
				valPing = _fl.load(ID);
			} else {
				//Acabamos la medida, por lo que mostramos el tiempo y
				// cambiamos de estado
				System.out.println("PING" + ID + "> Fin de la medida");
				System.out.println("\n@PING" + ID + ","
						+ (System.currentTimeMillis() - TIEMPO) / _RETRIES);
				_context.setState(new PingEndingStateLoad(_context, ID));
			}
		} catch (Exception e) {
			System.out.println("PING" + ID + "> Error al recibir!!");
			e.printStackTrace();
		}
		return true;
	}

	/**
	 * Envía un mensaje.
	 * 
	 * @see pingpong.jatlite.ping.PingState#enviar()
	 */
	public void enviar() {
		String msg = "(achieve :sender ping" + ID + " :receiver pong" + ID
		+ " :language java :ontology none :content " + ID + ")";

		try {
			_context.sendMessage(msg);
		} catch (Exception e) {
			System.out.println("PING" + ID + "> Error al enviar mensaje!!");
			e.printStackTrace();
		}
	}
}
