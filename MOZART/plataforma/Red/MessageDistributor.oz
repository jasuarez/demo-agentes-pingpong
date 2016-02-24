% MessageDistributor: Modulo encargado de la recepcion y el envio de mensajes a otras plataformas

functor

import
   Connection
   Pickle
   MessageConverter
   TransportProtocol
   SubMessageDistributor
   TicketMaker at '../Util/TicketMaker.ozf'
  
export
   MessageDistributor

define
   class MessageDistributor
      attr
	 serverTicket
	 serverAccess
	 ansAccess
	 subMessageDistributorDic
	 messageConverterAccess
	 messageConverterTicket
	 messageConverterGate
	 transportProtocolTicket
	 transportProtocolAccess
	 transportProtocolGate
	 myTicket
	 errorManagerTicket
	 errorManagerAccess

      meth init(ServerTicket AnsTicket ErrorManagerTicket)
	 serverTicket <- ServerTicket
	 ansAccess <- {Connection.take {Pickle.load AnsTicket}}
	 subMessageDistributorDic <- {Dictionary.new $}
	 errorManagerTicket <- ErrorManagerTicket
	 errorManagerAccess <- {Connection.take {Pickle.load ErrorManagerTicket}}
      end

      % Crea un vinculo con el servidor para poder comunicarle la llegada de mensajes,
      % Crea un objeto traductor de mensajes -- Si produce un error devuelve 1
      % Crea un objeto y un vinculo con el protocolo de transporte -- Si produce un error devuelve 2
      % Si no hay ningun error devuelve 0
      meth activate(MyTicket MCTicket TPTicket ?Fin)
	 serverAccess <- {Connection.take {Pickle.load @serverTicket}}
	 myTicket <- MyTicket
	 local
	    Platform
	    MCPlatform
	    TPPlatform
	    ErrorMC
	    ErrorTP
	    SynMessageConverter
	    MessageConverterObject
	    SynTransportProtocol
	    TransportProtocolObject
	 in
	    Platform={@ansAccess getPlatform($)}
	    {Wait Platform}
	    MCPlatform={@ansAccess getMessageConverterPlatform(Platform $)}
	    {Wait MCPlatform}
	    MessageConverterObject={New MessageConverter.messageConverter init(MCPlatform ErrorMC)}  %%%%%%%%%%
	    if ErrorMC==1 then
	       Fin=1
	    else
	       thread messageConverterGate <- {TicketMaker.start MessageConverterObject MCTicket#'Server' SynMessageConverter $} end
	       {Wait SynMessageConverter}
	       messageConverterAccess <- {Connection.take {Pickle.load MCTicket#'Server'}}
	       messageConverterTicket <- MCTicket
	       TPPlatform={@ansAccess getTransportProtocolPlatform(Platform $)}
	       {Wait TPPlatform}
	       TransportProtocolObject={New TransportProtocol.transportProtocol
					init(TPPlatform @myTicket {@ansAccess getPortPlatform(Platform $)} nil nil ErrorTP)}  %%%%%%%%%
	       if ErrorTP==1 then
		  Fin=2
	       else
		  thread
		     transportProtocolGate <- {TicketMaker.start TransportProtocolObject TPTicket#'Server' SynTransportProtocol $}
		  end
		  {Wait SynTransportProtocol}
		  transportProtocolTicket <- TPTicket
		  transportProtocolAccess <- {Connection.take {Pickle.load TPTicket#'Server'}}
		  {@transportProtocolAccess activate}
		  Fin=0
	       end
	    end
	 end
      end

      % Envia un mensaje
      meth sendMessage(Message RecvPlatform)
	 local
	    SubMD
	    AuxSubMD
	    TP
	    MC
	    Port
	    Address
	    Err
	    MsgErr
	 in
	    AuxSubMD={self searchSubMessageDistributor(RecvPlatform $)}
	    if AuxSubMD==nil then
	       TP={@ansAccess getTransportProtocolPlatform(RecvPlatform $)}
	       {Wait TP}
	       MC={@ansAccess getMessageConverterPlatform(RecvPlatform $)}
	       {Wait MC}
	       Port={@ansAccess getPortPlatform(RecvPlatform $)}
	       {Wait Port}
	       Address={@ansAccess getAddressPlatform(RecvPlatform $)}
	       {Wait Address}
	       SubMD={New SubMessageDistributor.subMessageDistributor init(RecvPlatform TP @transportProtocolTicket MC
									   @messageConverterTicket Port Address @serverTicket
									   @errorManagerTicket Err)}
	       if Err==1 orelse Err==2 then
		  {@errorManagerAccess doErrorMsg({Message getSender($)} {Message getReplyWiht($)} 2000+Err MsgErr)}
	       else
		  if Err\=0 then
		     {@errorManagerAccess doErrorMsg({Message getSender($)} {Message getReplyWiht($)} 3000 MsgErr)}
		  end
	       end
	       if Err\=0 then
		  {@serverAccess sendMessage(MsgErr)}
	       end
	    else
	       SubMD=AuxSubMD
	    end
	    {SubMD sendMessage(Message)}
	 end
      end

      % Busca si existe un subMessageDistributor que se ocupe de los mensajes de la plataforma del agente destino
      meth searchSubMessageDistributor(Platform ?SubMD)
	 {Dictionary.condGet @subMessageDistributorDic {VirtualString.toAtom Platform $} nil SubMD}
      end

      % Recive un mensaje
      meth messageReceived(Message)
	 local
	    MessageI
	    Sender
	    Errors
	    MsgErr
	    proc {SendError Item}
	       {MsgErr setComment({MsgErr getComment($)}#'Argumento no reconocido.'#Item.1#' '#Item.2)}
	    end
	 in
	    {@messageConverterAccess translateOI(Message MessageI Errors)}	    
	    if Errors==nil then
	       {Wait MessageI}
	       {@serverAccess messageReceived(MessageI)}
	    else
	       {Wait Errors}
	       if {String.is Errors $}==false then
		  Sender={MessageI getSender($)}
		  if Sender\=nil then
		     {@errorManagerAccess doErrorMsg(Sender {MessageI getReplyWith($)} 4000 MsgErr)}
		     {ForAll Errors SendError}
		     {@serverAccess sendMessage(MsgErr)}
		  end
	       end 
	    end
	 end
      end

      % Cierra
      meth close(?Syn)
	 local
	    Fin
	    Items
	    CloseItems
	 in
	    {@transportProtocolAccess close(Fin)}
	    {Wait Fin}
%%%%%   {@transportProtocolGate close}
	    {Dictionary.items @subMessageDistributorDic Items}
	    proc {CloseItems X}
	       {X close}
	    end
	    {ForAll Items CloseItems}
%%%%%   {@messageConverterGate close}
	 end
	 Syn=true
      end
   end
end