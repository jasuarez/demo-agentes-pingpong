% ControlMaster, nucleo del sistema, por el pasan todos los mensajes

functor
   
import
   ProcessConfigFile at '../Util/ProcessConfigFile.ozf'  % Modulo que lee un fichero de configuracion
   TicketMaker at '../Util/TicketMaker.ozf'              % Modulo que crea un ticket a partir de un objeto o procedimiento y una url
   Application
   Connection
   Pickle
   ErrorManager at '../Util/ErrorManager.ozf'            % Modulo encargado de crear y enviar mensajes de error
   ANS at '../Util/ANS.ozf'                              % Modulo ANS (Agent Name Service)
   ConvMaster at '../Conv/ConvMaster.ozf'                % Gestor de conversaciones de los agentes
   PoliciesManager at '../Util/PoliciesManager.ozf'      % Gestor de politicas de conversacion
   MessageDistributor at '../Red/MessageDistributor.ozf' % Encargado de la recepcion y el envio de mensajes a otras plataformas
   System
   Open
   
define
   class ControlMaster
      attr
	 serverTicket              % Ticket propio
	 ansTicket                 % Ticket del ANS
	 ansAccess                 % Acceso al ANS
	 policiesManagerTicket     % Ticket del PoliciesManager
	 convMasterDic             % Diccionario con los tickets de los gestores de conversacion indexados por el nombre del agente
	 messageDistributorTicket  % Ticket del MessageDistributor (Ampliacion 1)
	 messageDistributorAccess  % Acceso al MessageDistributor (Ampliacion 1)
	 errorManagerTicket        % Ticket del modulo encargado de los errores
	 errorManagerAccess        % Acceso al modulo encargado de los errores
	 
      meth init(TicketFile AnsTicketFile PoliciesManagerTicketFile ErrorManagerTicketFile MessageDistributorTicketFile)
	 serverTicket <- TicketFile
	 ansTicket <- AnsTicketFile
	 ansAccess <- {Connection.take {Pickle.load @ansTicket}}
	 convMasterDic <- {Dictionary.new $}
	 policiesManagerTicket <- PoliciesManagerTicketFile
	 errorManagerTicket <- ErrorManagerTicketFile
	 errorManagerAccess <- {Connection.take {Pickle.load @errorManagerTicket}}
	 messageDistributorAccess <- {Connection.take {Pickle.load MessageDistributorTicketFile}}
	 messageDistributorTicket <- MessageDistributorTicketFile
      end

      % Arranca el MessageDistributor y el protocolo de transporte encargados de recibir mensajes de otras plataformas
      % Si no se puede abrir el MessageDistributor indicado en la configuracion Fin=1
      % Si no se puede abrir el protocolo de transporte indicado en la configuracion Fin=2
      % Si todo va bien Fin=0
      meth activateMessageDistributor(MCTicket TPTicket) Fin in
	 {@messageDistributorAccess activate(@messageDistributorTicket MCTicket TPTicket ?Fin)}
	 case Fin of
	    1 then
	    {System.showInfo "ERROR: El MessageDistributor indicado en el fichero de configuracion del servidor no existe"}
	    {Application.exit 1}
	 [] 2 then
	    {System.showInfo "ERROR: El TransportProtocol indicado en el fichero de configuracion del servidor no existe"}
	    {Application.exit 1}
	 [] 0 then
	    skip
	 else
	    {System.showInfo "ERROR INTERNO"}
	    {Application.exit 1}
	 end
      end

      % Registra a un agente con un nombre y crea un gestor de conversacion para el
      meth register(Name TicketFile ?ConversationMaster ?NameRegistered)
	 local
	    Result         % Variable booleana que inidica si se ha podido registrar al agente o no (nombre repetido o no)
	    Conv           % Objeto gestor de conversacion
	    SynConv        % Variable de sincronizacion necesaria para crear un ticket
	    ConvMasterGate % Gate del ConvMaster
	    RecvName       % Nombre del agente a registrar eliminandole la plataforma a la que pertenece (AMP1)
	    RecvPlatform   % Plataforma indicada en el nombre a registrar (AMP1)
	    Err            % 3 si la plataforma indicada no es la local; 2 si el nombre de agente indicado ya esta registrado
	 in
	    % Si Name incluye la plataforma mira si esta es la correcta y si es asi la elimina antes de introducirla en el ANS
	    {String.token {VirtualString.toString Name $} &@ RecvName RecvPlatform}
	    if {VirtualString.toString Name $}\=RecvName then
	       if RecvPlatform\={@ansAccess getPlatform($)} then
		  Result=false
		  Err=3
	       else
		  {@ansAccess register(RecvName ?Result)}
	       end
	    else
	       {@ansAccess register(Name ?Result)}
	       Err=2
	    end
	    if Result then
	       % Arranque del ConvMaster
	       Conv={New ConvMaster.convMaster init(RecvName @ansTicket @serverTicket TicketFile
						    @policiesManagerTicket @errorManagerTicket)}
	       thread {TicketMaker.start Conv TicketFile#'Conv' SynConv ConvMasterGate} end
	       {Wait SynConv}
	       {Dictionary.put @convMasterDic {VirtualString.toAtom RecvName $} [TicketFile#'Conv' ConvMasterGate]}
	       ConversationMaster=TicketFile#'Conv'
	       NameRegistered=RecvName
	    else
	       NameRegistered=nil
	       {System.showInfo "ControlMaster register"}	       %%%%%%%%%%%
	       {@errorManagerAccess error('SYSTEM' TicketFile Name nil Err)}  %%%%%%%%%
	       ConversationMaster=nil
	    end
	 end
      end

      % Cierra a un agente y borra su gestor de conversacion del diccionario
      meth closeAgent(Name ?Syn)
	 % Cierra el Gate del ConvMaster
	 local
	    ResultList
	    SynANS
	 in
	    {Dictionary.condGet @convMasterDic {VirtualString.toAtom Name $} nil ResultList}
	    {{List.nth ResultList 2 $} close}
	    % Borra al agente del ans
	    {@ansAccess unregister(Name SynANS)}
	    {Wait SynANS}
	    % Elimina al agente del diccionario de gestores de conversacion
	    {Dictionary.remove @convMasterDic {VirtualString.toAtom Name $}}
	    Syn=true
	 end
      end

      % Envia un mensaje
      meth sendMessage(Message)
	 local
	    Receiver      % Receptor del mensaje
	    RecvName      % Identificador del receptor sin la plataforma a la que pertenece
	    RecvPlatform  % Plataforma del receptor
	    Platform      % Plataforma del sistema
	    SenderName    % Nombre del emisor del mensaje sin su plataforma
	 in
	    Receiver={Message getReceiver($)}
	    {String.token {VirtualString.toString Receiver $} &@ RecvName RecvPlatform}
	    Platform={VirtualString.toString {@ansAccess getPlatform($)} $}
	    {Wait Platform}
	    % Se le quita al receptor la plataforma a la que pertenece
	    {Message setReceiver(RecvName)}
	    % Si el agente es de la plataforma del sistema se recibe el mensaje directamente (sino - Ampliacion 1)
	    if {VirtualString.toString Receiver $}==RecvName orelse RecvPlatform==Platform then
	       {self messageReceived(Message)}
	    else
	       % Ampliacion 1:Interoperabilidad con otras implementaciones de KQML
	       {String.token {VirtualString.toString {Message getSender($)} $} &@ SenderName _}
	       {Message setSender({List.append SenderName {List.append "@" Platform $} $})}
	       {@messageDistributorAccess sendMessage(Message RecvPlatform)}
	    end
	 end
      end

      % Recepcion de un mensaje
      meth messageReceived(Msg)
	 local
	    ConversationMaster   % Gestor de conversacion del agente destino del mensaje
	    Receiver             % Receptor del mensaje
	 in
	    {Wait Msg}
	    Receiver={Msg getReceiver($)}
	    ConversationMaster={Dictionary.condGet @convMasterDic {VirtualString.toAtom Receiver $} nil $}
	    if ConversationMaster==nil then
	       if {String.token {VirtualString.toString {Msg getSender($)} $} &@ $ _}\="SYSTEM" then
		  local
		     ErrorMsg
		  in
		     ErrorMsg={@errorManagerAccess doErrorMsg({Msg getSender($)} {Msg getReplyWith($)} 1001 $)}
		     {Wait ErrorMsg}
		     {self sendMessage(ErrorMsg)}
		  end
	       end
	    else
	       local
		  ConvMasterAccess
	       in
		  ConvMasterAccess={Connection.take {Pickle.load {List.nth ConversationMaster 1 $}}}
		  {ConvMasterAccess messageReceived(Msg)}
	       end
	    end
	 end
      end

      meth close
	 local
	    Fin
	 in
	    {@messageDistributorAccess close(Fin)}
	    {Wait Fin}
	 end
      end
   end
   

   % Captura de parametros: configFile - Fichero de configuracion del servidor   
   Args={Application.getCmdArgs
	 record(configFile(single char:&f type:string optional:false))}
   
   % Lectura del fichero de configuracion
   PFile = {New ProcessConfigFile.processConfigFile init}
   {PFile read(Args.configFile)}

   % Lectura del destino de los tickets
   TicketFile
   {PFile get(ticket TicketFile)}
   
   AnsTicketFile
   {PFile get(ansTicket AnsTicketFile)}

   PoliciesManagerTicketFile
   {PFile get(policiesManagerTicket PoliciesManagerTicketFile)}
   
   ErrorManagerTicketFile
   {PFile get(errorManagerTicket ErrorManagerTicketFile)}

   MessageDistributorTicketFile
   {PFile get(messageDistributorTicket MessageDistributorTicketFile)}

   MessageConverterTicketFile
   {PFile get(messageConverterTicket MessageConverterTicketFile)}

   TransportProtocolTicketFile
   {PFile get(transportProtocolTicket TransportProtocolTicketFile)}

   % Clase necesaria para pasarle al ANS los datos de cada una de las plataformas
   class PlatformData
      attr
	 platform
	 address
	 port
	 transportProtocolType
	 messageConverterType

      meth init(Platform Address Port TransportProtocolType MessageConverterType)
	 platform <- Platform
	 address <- Address
	 port <- Port
	 messageConverterType <- MessageConverterType
	 transportProtocolType <- TransportProtocolType
      end

      meth getPlatform(?Platform)
	 Platform=@platform
      end

      meth getAddress(?Address)
	 Address=@address
      end

      meth getPort(?Port)
	 Port=@port
      end

      meth getTransportProtocolType(?TPType)
	 TPType=@transportProtocolType
      end

      meth getMessageConverterType(?MCType)
	 MCType=@messageConverterType
      end
   end

   % Lectura de los datos de la plataforma local
   Platform
   {PFile get(platform Platform)}
   
   Address
   {PFile get(address Address)}
   
   Port
   {PFile get(port Port)}
   
   MessageConverterType
   {PFile get(messageConverter MessageConverterType)}

   TransportProtocolType
   {PFile get(transportProtocol TransportProtocolType)}

   PlatformLocal={New PlatformData init(Platform Address Port TransportProtocolType MessageConverterType)}

   % Lectura de los datos del resto de las plataformas
   MorePlatform
   {PFile get(morePlatform MorePlatform)}
   MorePlatformList={List.make {String.toInt {VirtualString.toString MorePlatform $} $} $}
   proc {GetDataPlatform Iter}
      {List.nth MorePlatformList Iter $}={New PlatformData init(
							      {PFile get({String.toAtom {VirtualString.toString 'platform'#Iter $} $} $)}
							      {PFile get({String.toAtom {VirtualString.toString 'address'#Iter $} $} $)}
							      {PFile get({String.toAtom {VirtualString.toString 'port'#Iter $} $} $)}
							      {PFile get({String.toAtom
									  {VirtualString.toString 'transportProtocol'#Iter $} $} $)}
							      {PFile get({String.toAtom
									  {VirtualString.toString 'messageConverter'#Iter $} $} $)})}
   end
   {For 1 {String.toInt {VirtualString.toString MorePlatform $} $} 1 GetDataPlatform}
   
   % Arranque del ANS
   AnsObject={New ANS.aNS init(PlatformLocal MorePlatformList)}
   SynANS
   GateANS
   thread {TicketMaker.start AnsObject AnsTicketFile SynANS GateANS} end
   {Wait SynANS}
   
   % Arranque del PoliciesManager
   PoliciesManagerObject={New PoliciesManager.policiesManager init}
   SynPoliciesManager
   GatePoliciesManager
   thread {TicketMaker.start PoliciesManagerObject PoliciesManagerTicketFile SynPoliciesManager GatePoliciesManager} end
   {Wait SynPoliciesManager}

   % Arranque del ErrorManager
   ErrorManagerObject={New ErrorManager.errorManager init()}
   SynErrorManager
   GateErrorManager
   thread {TicketMaker.start ErrorManagerObject ErrorManagerTicketFile SynErrorManager GateErrorManager} end
   {Wait SynErrorManager}

   % Arranque del MessageDistributor
   MessageDistributorObject={New MessageDistributor.messageDistributor init(TicketFile AnsTicketFile ErrorManagerTicketFile)}
   SynMessageDistributor
   GateMessageDistributor
   thread {TicketMaker.start MessageDistributorObject MessageDistributorTicketFile SynMessageDistributor GateMessageDistributor} end
   {Wait SynMessageDistributor}

   % Arranque del servidor
   Control={New ControlMaster init(TicketFile AnsTicketFile PoliciesManagerTicketFile
				   ErrorManagerTicketFile MessageDistributorTicketFile)}
   SynControl
   GateControl
   thread {TicketMaker.start Control TicketFile SynControl GateControl} end
   {Wait SynControl}
   {Control activateMessageDistributor(MessageConverterTicketFile TransportProtocolTicketFile)}

   
   F={New Open.file init(name:'stdin' flags:[read write])}
   {System.showInfo "\nTeclee close para cerrar el servidor:\n"}
   {F write(vs:"KQMLServer$ ")}


   % Lee el comando introducido por el usuario
   Fin
   Command={NewCell nil $}
   proc {Cierre}
      local
	 Aux
      in
	 {F read(list:Aux size:1)}
	 if Aux\="\n" then
	    if {Access Command $}==nil then
	       {Assign Command Aux}
	    else
	       {Assign Command {List.append {Access Command $} Aux $}}
	    end
	    {Cierre}
	 else
	    % Ejecuta el comando correspondiente
	    if {Access Command $}=="close" then
	       Fin=true
	    elseif {Access Command $}=="help" then
	       {System.showInfo "\nTeclee help command para mas informacion sobre el comando"}
	       {System.showInfo "\nComandos disponibles:\n \t\t\thelp\n \t\t\tclose\n"}
	       {Assign Command nil}
	       {F write(vs:"KQMLServer$ ")}
	       {Cierre}
	    elseif {Access Command $}=="help help" then
	       {System.showInfo "help [command] \n\thelp muestra la lista de comandos disponibles"}
	       {System.showInfo "\thelp command muestra informacion sobre el comando introducido"}
	       {Assign Command nil}
	       {F write(vs:"KQMLServer$ ")}
	       {Cierre}
	    elseif {Access Command $}=="help close" then
	       {System.showInfo "close \n\tclose cierra el servidor"}
	       {Assign Command nil}
	       {F write(vs:"KQMLServer$ ")}
	       {Cierre}
	    else
	       {Assign Command nil}
	       {F write(vs:"KQMLServer$ ")}
	       {Cierre}
	    end
	 end
      end
   end

   {Cierre}
      
   {Wait Fin}
   {GateANS close}
   {GatePoliciesManager close}
   {GateErrorManager close}

%%%%%%%%%%%%%%%%%%%%%%%
   {Control close}
   {GateMessageDistributor close}
   {GateControl close}
   {Application.exit 0}
end
