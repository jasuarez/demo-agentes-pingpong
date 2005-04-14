% SubManager: SubGestor de Conversacion, mantiene todas las conversaciones del agente
% con un determinado agente destino

functor
   
import
   Conversation                   % Objeto Conversacion
   Connection
   Pickle
   System %%%%%%%%%
export
   SubManager
   
define
   class SubManager
      attr
	 conversationDic          % Diccionario que almacena los objetos Conversacion indexados por su identificador
	 replyWithDic             % Diccionario que almacena los objetos Conversacion indexados por el campo replyWith del ultimo mensaje
	 agentName                % Nombre que identifica al agente
	 agDestination            % Nombre que identifica al agente destino
	 policiesManagerTicket    % Ticket del gestor de politicas
	 serverTicket             % Ticket del servidor (ControlMaster)
	 agentTicket              % Ticket del agente
	 errorManagerAccess       % Acceso al gestor de errores
	 errorManagerTicket       % Ticket del gestor de errores
	 convMasterAccess         % Acceso al gestor de conversacion
	 countReplyWith           % Contador para construir campos replyWith diferentes
	 
      meth init(AgentName AgDestination PoliciesManagerTicket ServerTicket AgentTicket ConvMaster ErrorManagerTicket)
	 conversationDic <- {Dictionary.new $}
	 countReplyWith <- 0
	 replyWithDic <- {Dictionary.new $}
	 agentName <- AgentName
	 agDestination <- AgDestination
	 policiesManagerTicket <- PoliciesManagerTicket
	 serverTicket <- ServerTicket
	 agentTicket <- AgentTicket
	 errorManagerTicket <- ErrorManagerTicket
	 errorManagerAccess <- {Connection.take {Pickle.load @errorManagerTicket}}
	 convMasterAccess <- ConvMaster
      end

      % Cierra una conversacion, borrandola de los dos diccionarios
      meth close(ConvId Conv)
	 {Dictionary.remove @conversationDic ConvId}
	 local
	    LEntries
	    proc {RemoveConv Elem}
	       if Elem==_#Conv then
		  {Dictionary.remove @replyWithDic {List.nth Elem 1}}
	       end	       
	    end
	 in
	    {Dictionary.entries @replyWithDic LEntries}
	    {ForAll LEntries RemoveConv}
	 end
      end

      % Crea una conversacion dado su identificador y la almacena en el diccionario conversationDic
      meth createConv(ConvId ?Syn) Conv in
	 Conv={New Conversation.conversation init(@agentName @agDestination @policiesManagerTicket
						  @serverTicket @agentTicket ConvId self @errorManagerTicket)}
	 {Dictionary.put @conversationDic ConvId Conv}
	 Syn=true
      end

      % Busca la conversacion a la que asignar un cierto mensaje, usando el campo inReplyTo
      meth searchConversation(Message ?Conversation)
	 {Dictionary.condGet @replyWithDic {Message getInReplyTo($)} nil Conversation}
      end

      % Envia un mensaje dentro de una conversacion
      meth sendMessage(Message ConvId)
	 local
	    Conversation  % Objeto conversacion necesario para enviar el mensaje
	    ReplyWith     % El campo reply-with del mensaje KQML se rellena con una R seguida del id de la conversacion y un contador
	 in
	    {Dictionary.condGet @conversationDic ConvId nil Conversation}
	    if Conversation==nil then
	       {System.showInfo "SubManager sendMessageN"}   %%%%%%%%%N
	       {@errorManagerAccess error('SYSTEM' @agentTicket @agentName nil 7)}   %%%%%%%%%N
	    else
	       countReplyWith <- @countReplyWith+1
	       ReplyWith={VirtualString.toAtom {VirtualString.toString 'R'#ConvId#@countReplyWith $} $}
	       {Message setReplyWith(ReplyWith)}
	       {Dictionary.put @replyWithDic ReplyWith Conversation}
	       {Conversation sendMessage(Message)}
	    end
	 end
      end

      % Recepcion de un cierto mensaje
      meth messageReceived(Message)
	 local
	    Conv    % Conversacion a la que asignar el mensaje
	    ConvId  % Identificador de la conversacion
	    Aux     % Variable auxiliar para almacenar la conversacion
	 in
	    Aux={self searchConversation(Message $)}
	    % Si no existe una conversacion a la que asignar el mensaje se crea una nueva
	    if Aux==nil then
	       ConvId={@convMasterAccess getNewConvId($)}
	       {Wait ConvId}
	       Conv={New Conversation.conversation init(@agentName @agDestination @policiesManagerTicket @serverTicket
							@agentTicket  ConvId self @errorManagerTicket)}
	       {Dictionary.put @conversationDic ConvId Conv}
	    else
	       Conv=Aux
	    end
	    % Se le pasa el mensaje a la conversacion a la que se corresponda
	    {Wait Conv}
	    {Conv messageReceived(Message)}
	 end
      end
   end
end	 
