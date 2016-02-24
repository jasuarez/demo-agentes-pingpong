% AgentFacade: API para interactuar con el sistema

functor
   
import
   TicketMaker at '../Util/TicketMaker.ozf'      % Modulo encargado de crear un ticket a partir de un objeto o procedimiento y una url
   Connection
   Pickle
   System %%%%%%%%
export
   AgentFacade
   
define
   class AgentFacade
      attr
	 agentName         % Nombre que identifica al agente (sin la plataforma a la que pertenece)
	 agentTicket       % Ticket necesario para comunicarse con el agente
	 agentAccess       % Acceso al agente
	 serverAccess      % Acceso al servidor (ControlMaster)
	 convMasterAccess  % Acceso al gestor de conversacion propio del agente
	 
      feat agentGate       % Gate del agente
	 
      meth init(TicketProc TicketFile ServerTicket)
	 % Inicia la comunicacion con el agente por medio de un ticket
	 local
	    Syn
	 in
	    thread self.agentGate={TicketMaker.start TicketProc TicketFile Syn $} end
	    {Wait Syn}
	 end
	 % Inicializacion de atributos
	 agentTicket <- TicketFile
	 agentAccess <- {Connection.take {Pickle.load @agentTicket}}
	 serverAccess <- {Connection.take {Pickle.load ServerTicket}}
      end

      % Registra a un agente dado un nombre
      meth register(Name)
         % Si el agente ya esta registrado no se le permite volver a hacerlo
	 if {Value.isFree @convMasterAccess}==false andthen @convMasterAccess\=nil then
	    try
	       {System.showInfo "AgentFacade register"}	       %%%%%%%%%%%
	       {@agentAccess error("Error en el registro: Agente ya registrado")}   %%%%%%%%
	    catch _ then
	       skip
	    end
	 else  
	    local
	       CMasterTicketFile
	       NameRegistered
	    in
	       {@serverAccess register(Name @agentTicket CMasterTicketFile NameRegistered)}
	       if CMasterTicketFile\=nil then
		  convMasterAccess <- {Connection.take {Pickle.load CMasterTicketFile}}
		  agentName <- NameRegistered
	       end
	    end
	 end
      end
      
      % Cierra al agente
      meth close()
	 if {Value.isFree @convMasterAccess} then
	    skip   % Si aun no se ha registrado no necesita cerrarlo
	 else
	    local
	       Syn
	    in
	       {@serverAccess closeAgent(@agentName Syn)}
	       {Wait Syn}
	    end
	 end
	 {Delay 5000}    %%%%%% RETARDO
	 {self.agentGate close}
      end

      % Crea una conversacion con el agente destino pasado como parametro y devuelve el identificador de la conversacion
      meth createConv(AgDestination ?ConvId)
         % Si el agente no esta registrado no se le permite crear una conversacion
	 if {Value.isFree @convMasterAccess} orelse @convMasterAccess==nil then
	    try
	       {System.showInfo "AgentFacade createConv"}    %%%%%%%%%
	       {@agentAccess error("Error operacion no permitida: El agente aun no se ha registrado")}   %%%%%%%%
	    catch _ then
	       skip
	    end
	 else
	    {@convMasterAccess createConversation(AgDestination ConvId)}
	 end
      end

      % Envia el mensaje dado dentro de la conversacion indicada
      meth sendMessage(Message ConvId)
	 % Si el agente no esta registrado no se le permite crear una conversacion
	 if {Value.isFree @convMasterAccess} orelse @convMasterAccess==nil then
	    try {@agentAccess error("Error operacion no permitida: El agente aun no se ha registrado")} catch _ then skip end
	 else
	    {@convMasterAccess sendMessage(Message ConvId)}
	 end
      end
   end
end


