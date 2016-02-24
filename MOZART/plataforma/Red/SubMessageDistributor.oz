% SubMessageDistributor: Modulo encargado del envio de mensajes a una cierta plataforma

functor

import
   Connection
   Pickle
   MessageConverter
   TransportProtocol
   TicketMaker at '../Util/TicketMaker.ozf'
  
export
   SubMessageDistributor

define
   class SubMessageDistributor
      attr
	 platform
	 messageConverterAccess
	 messageConverterGate
	 transportProtocolAccess
	 transportProtocolGate
	 serverAccess
	 errorManagerAccess

      % Inicializa el protocolo de transporte, el traductor, el puerto y direccion destino de los mensajes a usar en el envio
      % Si no hay ningun problema Err=0, si no se dispone del traductor indicado Err=1, y si no se dispone del protocolo Err=2
      meth init(Platform TP TPTicket MC MCTicket Port Address ServerTicket ErrorManagerTicket ?Err)
	 local
	    ErrorMC
	    ErrorTP
	    SynMessageConverter
	    MessageConverterObject
	    SynTransportProtocol
	    TransportProtocolObject
	 in
	    errorManagerAccess <- {Connection.take {Pickle.load ErrorManagerTicket}}
	    platform <- Platform
	    serverAccess <- {Connection.take {Pickle.load ServerTicket}}
	    MessageConverterObject={New MessageConverter.messageConverter init(MC ErrorMC)}
	    if ErrorMC==1 then
	       Err=1
	    else
	       thread messageConverterGate <- {TicketMaker.start MessageConverterObject MCTicket#@platform SynMessageConverter $} end
	       {Wait SynMessageConverter}
	       messageConverterAccess <- {Connection.take {Pickle.load MCTicket#@platform}}
	       TransportProtocolObject={New TransportProtocol.transportProtocol init(TP nil nil Address Port ErrorTP)}
	       if ErrorTP==1 then
		  Err=2
	       else
		  thread transportProtocolGate<-{TicketMaker.start TransportProtocolObject TPTicket#@platform SynTransportProtocol $} end
		  {Wait SynTransportProtocol}
		  transportProtocolAccess <- {Connection.take {Pickle.load TPTicket#@platform}}
		  Err=0
	       end
	    end
	 end
      end
      
      % Envia un mensaje
      meth sendMessage(Message)
	 local
	    MessageO
	 in
	    {@messageConverterAccess translateIO(Message ?MessageO)}
	    {Wait MessageO}
%	    MessageO={VirtualString.toByteString '(PerformativePrueba)' $}
	    {@transportProtocolAccess sendMessage(MessageO)}
	 end
      end

      meth close
	 local
	    Fin
	 in
	    {@transportProtocolAccess close(Fin)}
	    {Wait Fin}
	    {@transportProtocolGate close}
	    {@messageConverterGate close}
	 end
      end
   end
end