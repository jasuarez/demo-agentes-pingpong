% ErrorManager: Se encarga de enviar errores provocados por el sistema al agente implicado

functor
   
import
   Connection
   Pickle
   Message
   
export
   ErrorManager
   
define
   class ErrorManager
      attr
	 codes   % Diccionario que almacena los textos de error indexados por sus codigos

      % Si se le pasa un ticket se conecta con el para mandarle directamente los mensajes de error
      meth init()
	 % Inicializa el diccionario de codigos y textos de error
	 codes <- {Dictionary.new $}
	 {Dictionary.put @codes 1 '"Error en el registro: Agente ya registrado."'}
	 {Dictionary.put @codes 2 '"Error en el registro: Nombre de Agente repetido."'}
	 {Dictionary.put @codes 10 '"Error en el registro: Plataforma erronea."'}
	 {Dictionary.put @codes 3 '"Error operacion no permitida: El agente aun no se ha registrado."'}
	 {Dictionary.put @codes 4 '"Error en la creacion de la conversacion: El agente destino no existe."'}
	 {Dictionary.put @codes 5 '"Error interno en la creacion de la conversacion: Vuelva a intentarlo."'}
	 {Dictionary.put @codes 6 '"Error en el envio: No existe ninguna conversacion creada con el agente destino."'}
	 {Dictionary.put @codes 7 '"Error en el envio: No existe la conversacion a la que se hace referencia."'}
	 {Dictionary.put @codes 8 '"Error en el envio: El mensaje no tiene sentido dentro de la conversacion."'}
	 {Dictionary.put @codes 9 '"Error en la creacion de la conversacion: El sistema no tiene datos de la plataforma destino."'}
	 % LOS SIGUIENTES CODIGOS DEBERIAN SER ESTANDAR
	 {Dictionary.put @codes 1001 '"No se ha podido encontrar al agente destino para entregarle el mensaje."'}
	 {Dictionary.put @codes 1002 '"El mensaje no tiene sentido dentro de la conversacion."'}
	 {Dictionary.put @codes 2001 '"No existe el traductor con el que trabaja la plataforma del agente destino."'}
	 {Dictionary.put @codes 2002 '"No existe el protocolo de transporte con el que trabaja la plataforma del agente destino."'}
	 {Dictionary.put @codes 3000 '"Error interno."'}
	 {Dictionary.put @codes 4000 '"Error al traducir el mensaje en la plataforma receptora."'}
      end

      % Manda un mensaje de error directamente al agente
      meth error(Sender ReceiverTicket Receiver InReplyTo Code)
	 local
	    Msg
	    ReceiverAccess
	 in
	    try
	       ReceiverAccess={Connection.take {Pickle.load ReceiverTicket}}
	       Msg={New Message.message init}
	       {Msg setPerformative("error")}
	       {Msg setSender(Sender)}
	       {Msg setReceiver(Receiver)}
	       {Msg setCode(Code)}
	       {Msg setComment({Dictionary.get @codes Code $})}
	       {Msg setInReplyTo(InReplyTo)}
	       {ReceiverAccess recv(Msg nil)}
	    catch _ then
	       skip
	    end
	 end
      end

      % Devuelve el mensaje de error a enviar, pero no lo envia
      meth doErrorMsg(Receiver InReplyTo Code ?Msg)
	 Msg={New Message.message init}
	 {Msg setPerformative("error")}
	 {Msg setSender('SYSTEM')}
	 {Msg setReceiver(Receiver)}
	 {Msg setCode(Code)}
	 {Msg setComment({Dictionary.get @codes Code $})}
	 {Msg setInReplyTo(InReplyTo)}
      end
   end
end
