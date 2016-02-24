% Conversation: representa una conversacion concreta, entre un cierto agente emisor y otro receptor

functor
   
import
   Connection
   Pickle
   System %%%
export
   Conversation
   
define
   class Conversation
      attr
	 convId                     % Identificador de la conversacion
	 agentName                  % Nombre del agente
	 agDestination              % Nombre del agente destino de la conversacion
	 policiesManagerAccess      % Acceso al gestor de politicas 
	 state                      % Estado de la conversacion fijado por el gestor de politicas
	 serverAccess               % Acceso al servidor (ControlMaster)
	 agentTicket                % Ticket del agente
	 agentAccess                % Acceso al agente
	 errorManagerAccess         % Acceso al gestor de errores
	 subManager                 % Objeto SubManager

      meth init(AgentName AgDestination PoliciesManagerTicket ServerTicket AgentTicket ConvId SubManager ErrorManagerTicket)
	 convId <- ConvId
	 agentName <- AgentName
	 agDestination <- AgDestination
	 policiesManagerAccess <- {Connection.take {Pickle.load PoliciesManagerTicket}}
	 serverAccess <- {Connection.take {Pickle.load ServerTicket}}
	 agentTicket <- AgentTicket
	 agentAccess <- {Connection.take {Pickle.load AgentTicket}}
	 errorManagerAccess <- {Connection.take {Pickle.load ErrorManagerTicket}}
	 state <- {@policiesManagerAccess initConv($)}
	 subManager <- SubManager
      end

      % Envio de un mensaje
      meth sendMessage(Message) Aux in
	 {@policiesManagerAccess verifyMessage(Message @state Aux)}
	 {Wait Aux}
	 state <- Aux
	 if state=="ERROR" then
	    {System.showInfo "Conversation sendMessageN"} %%%%%%N
	    {@errorManagerAccess error('SYSTEM' @agentTicket @agentName nil 8)}   %%%%%%%%%%%N
	 else
	    {@serverAccess sendMessage(Message)}
	    if state=="CLOSE" then
	       {@subManager close(@convId self)}
	    end
	 end
      end

      % Recepcion de un mensaje
      meth messageReceived(Message) Aux in
	 {@policiesManagerAccess verifyMessage(Message @state Aux)}
	 {Wait Aux}
	 state <- Aux
	 if state=="ERROR" then
	    local
	       ErrorMsg
	    in
	       ErrorMsg={@errorManagerAccess doErrorMsg(@agDestination {Message getReplyWith($)} 1002)}
	       {@serverAccess sendMessage(ErrorMsg)}
	    end
	 else
	    %%JOTA
	    {System.showInfo "CONVERSATION> Mensaje de "#{Message getSender($)}#" a "#{Message getReceiver($)}}
	    {System.showInfo "CONVERSATION> La conversacion es "#@convId}
	    {System.showInfo "CONVERSATION> Mensaje2 de "#{Message getSender($)}#" a "#{Message getReceiver($)}}
	    %{@agentAccess imprime(Message)}
	    {Time.delay 5000}
	    %%JOTA
	    {@agentAccess recv(Message @convId)}
	    if state=="CLOSE" then
	       {System.showInfo "CONVERSATION> Cierro la conversacion"}
	       {@subManager close(@convId self)}
	    end
	 end
      end
   end
end
