% ConvMaster: Gestor de conversacion

functor
   
import
   Connection
   Pickle
   SubManager                           % Subgestor de conversaciones, trata los mensajes intercambiados con un cierto agente destino
   KeyMaker at '../Util/KeyMaker.ozf'   % Modulo encargado de generar nuevas claves consecutivamente a partir de la anterior
   System %%%%%%
export
   ConvMaster
   
define
   class ConvMaster
      attr
	 subManagerDic              % Diccionario que almacena objetos SubManager indexados por el agente destino que representan
	 ansAccess                  % Acceso al ANS (Agent Name Service)
	 agentName                  % Nombre que identifica al agente para el que gestiona las conversaciones
	 lastConvId                 % Clave de la ultima conversacion creada
	 policiesManagerTicket      % Ticket del gestor de politicas
	 serverTicket               % Ticket del servidor (ControlMaster)
	 agentTicket                % Ticket del agente
	 errorManagerTicket         % Ticket del gestor de errores
	 errorManagerAccess         % Acceso al gestor de errores
	 
      meth init(AgentName AnsTicket ServerTicket AgentTicket PoliciesManagerTicket ErrorManagerTicket)
	 lastConvId <- 0
	 subManagerDic <- {Dictionary.new $}
	 ansAccess <- {Connection.take {Pickle.load AnsTicket}}
	 agentName <- AgentName
	 policiesManagerTicket <- PoliciesManagerTicket
	 serverTicket <- ServerTicket
	 agentTicket <- AgentTicket
	 errorManagerTicket <- ErrorManagerTicket
	 errorManagerAccess <- {Connection.take {Pickle.load ErrorManagerTicket}}
      end

      % Busca un objeto SubManager a partir del agente destino
      meth searchSubManager(Agent ?SubMgr)
	 {Dictionary.condGet @subManagerDic {VirtualString.toAtom Agent $} nil SubMgr}
      end

      % Devuelve una clave nueva para crear una conversacion y se actualiza lastConvId
      meth getNewConvId(?ConvId)
	 lastConvId <- {KeyMaker.getNewKey @lastConvId}
	 ConvId=@lastConvId
      end

      % Crea una conversacion con el agente destino dado y devuelve su clave
      meth createConversation(AgDest ?ConversationId)
	 local
	    SubMgr          % SubManager encargado de tratar los mensajes intercambiados con AgDest
	    ErrorCreated    % Si es true indica que ha habido un error en la creacion de la conversacion
	    AuxConvId       % Contiene el identificador de la conversacion temporalmente
	    Syn             % Variable de sincronizacion, que espera a que se cree la conversacion sin errores
	    RecvName        % Nombre de AgDest sin incluir la plataforma a la que pertenece
	    RecvPlatform    % Plataforma a la que pertenece AgDest (si no esta indicada es la local)
	    Platform        % Plataforma local
	 in
	    {NewCell {self searchSubManager(AgDest $)} SubMgr}
	    % Si no existe SubManager para el agente destino se crea
	    if {Access SubMgr $}==nil then
	       {String.token {VirtualString.toString AgDest $} &@ RecvName RecvPlatform}
	       Platform={@ansAccess getPlatform($)}
	       {Wait Platform}
	       % Si el agente destino pertenece a la plataforma local se verifica si esta conectado al sistema
	       if {VirtualString.toString AgDest $}==RecvName orelse RecvPlatform=={VirtualString.toString Platform $} then
		  if {@ansAccess existsAgent(AgDest $)} then
		     % Crea el SubManager
		     {Assign SubMgr {New SubManager.subManager init(@agentName RecvName @policiesManagerTicket
								    @serverTicket @agentTicket self @errorManagerTicket)}}
		     {Dictionary.put @subManagerDic {VirtualString.toAtom RecvName $} {Access SubMgr $}}
		  else
		     {System.showInfo "ConvMaster createConversation"}   %%%%%%%%%%%
		     {@errorManagerAccess error('SYSTEM' @agentTicket @agentName nil 4)}   %%%%%%%%%%
		     ErrorCreated=true
		  end
	       else % En este caso solo se verifica si el sistema tiene los datos de la plataforma del agente destino
		  if {@ansAccess existsPlatform(RecvPlatform $)} then
		     % Crea el SubManager
		     {Assign SubMgr {New SubManager.subManager init(@agentName AgDest @policiesManagerTicket
								    @serverTicket @agentTicket self @errorManagerTicket)}}
		     {Dictionary.put @subManagerDic {VirtualString.toAtom AgDest $} {Access SubMgr $}}
		  else
		     {System.showInfo "ConvMaster createConversation"}   %%%%%%%%%%%
		     {@errorManagerAccess error('SYSTEM' @agentTicket @agentName nil 9)}   %%%%%%%%%%
		     ErrorCreated=true
		  end
	       end
	    end
	    if {Value.isFree ErrorCreated $} orelse ErrorCreated\=true then
	       % Se genera la clave de la conversacion
	       {self getNewConvId(AuxConvId)}
	       % Se crea la conversacion
	       {{Access SubMgr $} createConv(AuxConvId Syn)}
	       {Wait Syn}
	       ConversationId=AuxConvId
	    else
	       ConversationId=nil
	    end
	 end
      end

      % Envio de un mensaje dentro de una conversacion
      meth sendMessage(Message ConvId)
	 local
	    SubMgr         % SubManager encargado de intercambiar mensajes con el agente receptor del mensaje
	    Receiver       % Celda que almacena el nombre del agente receptor (sin la platforma si es que es local)
	    RecvName       % Nombre sin la plataforma a la que pertenece del agente receptor del mensaje
	    RecvPlatform   % Plataforma del agente receptor del mensaje
	 in
	    % Se elimina la plataforma del Receptor si es la local
	    Receiver={NewCell {Message getReceiver($)} $}
	    {String.token {VirtualString.toString {Access Receiver $} $} &@ RecvName RecvPlatform}
	    if {VirtualString.toString {Access Receiver $} $}\=RecvName andthen
	       RecvPlatform=={VirtualString.toString {@ansAccess getPlatform($)} $} then
	       {Assign Receiver RecvName}
	    end
	    SubMgr={self searchSubManager({Access Receiver $} $)}
	    if SubMgr==nil then
	       {@errorManagerAccess error('SYSTEM' @agentTicket @agentName nil 6)} %%%%%%%%%%N
	    else
	       {SubMgr sendMessage(Message ConvId)}
	    end
	 end
      end
      
      % Recepcion de un mensaje
      meth messageReceived(Message)
	 local
	    AuxSubMgr        % Variable auxiliar para almacenar el subManager
	    SubMgr           % SubManager encargado de tratar los mensajes con el agente emisor de Message
	    Sender           % Agente emisor del mensaje
	    SenderName       % Nombre del agente emisor sin la plataforma a la que pertenece
	    SenderPlatform   % Plataforma del agente emisor (si no esta indicada es la local)
	 in
	    Sender={NewCell {Message getSender($)} $}
	    {String.token {VirtualString.toString {Access Sender $} $} &@ SenderName SenderPlatform}
	    if {VirtualString.toString {Access Sender $} $}\=SenderName andthen
	       SenderPlatform=={VirtualString.toString {@ansAccess getPlatform($)} $} then
	       {Assign Sender SenderName}
	    end
	    {self searchSubManager({Access Sender $} AuxSubMgr)}
	    % Si no hay un SubManager para el agente que envio el mensaje se crea
	    if AuxSubMgr==nil then
	       SubMgr={New SubManager.subManager init(@agentName {Access Sender $} @policiesManagerTicket
						      @serverTicket @agentTicket self @errorManagerTicket)}
	       {Dictionary.put @subManagerDic {VirtualString.toAtom {Access Sender $} $} SubMgr}
	    else
	       SubMgr=AuxSubMgr
	    end
            % Le pasa el mensaje al SubManager encargado del agente emisor
	    {Wait SubMgr}
	    {SubMgr messageReceived(Message)}
	 end
      end
   end
end
