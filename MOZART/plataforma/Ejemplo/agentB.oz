% AGENTE DE PRUEBA
%
% 1 - Se registra como agenteB
% 2 - Crea una conversacion con el agente
% 3 - Envia un mensaje por la conversacion creada
% 4 - Espera a que le llegue un mensaje de contestacion
% 5 - Muestra los parametros del mensaje recibido por pantalla

functor
   
import
   Application
   System
   AgentFacade at '../API/AgentFacade.ozf'   % Fachada del sistema (registro, creacion de conversacion, envio, etc.)
   Message at '../Util/Message.ozf'          % Objeto Mensaje
   
define
   
   % CAPTURA DE PARAMETROS
   AppName="agente"
   Spec=record(url(single char:&u type:string optional:false)
	       serverTicket(single char:&s type:string optional:false))
   Args
   try
      Args={Application.getCmdArgs Spec}
   catch error(ap(usage S)...) then
      {System.showError AppName#": "#S}
      {Application.exit 1}
   end
   
   % CREACION DEL OBJETO Proc QUE SE ENCARGA DE RECIBIR LOS MENSAJES Y MOSTRARLOS POR PANTALLA
   local
      ConvIdP2 ConvIdA    % Variable que almacena el identificador de una conversacion
      Loop                % Permite que la ejecucion nunca pare
      MsgP2 MsgA          % Objeto Mensaje a enviar
      
      class ProcClass
	 meth init skip end
	 meth recv(MsgRecv ConversationId)
	    {System.showInfo "\nMENSAJE RECIBIDO:\n"}
	    case MsgRecv of error(Comment) then
	       {System.show Comment}
	    else
	       if {MsgRecv getSender($)}=='SYSTEM' then
		  {System.showInfo {MsgRecv getComment($)}}
	       else
		  {System.show {MsgRecv getPerformative($)}}
		  {System.show {MsgRecv getSender($)}}
		  {System.show {MsgRecv getReceiver($)}}
		  {System.show {MsgRecv getContent($)}}
		  {System.show {MsgRecv getLanguage($)}}
		  {System.show {MsgRecv getOntology($)}}
		  {System.show {MsgRecv getReplyWith($)}}
		  {System.show ConversationId}
		  if {Value.isFree Loop $} then
		     Loop=1
		  end
	       end
	    end
	 end
      end
      Proc={New ProcClass init}
   in
      % CREACION DE UNA FACHADA PARA ACCEDER AL SISTEMA
      Facade={New AgentFacade.agentFacade init(Proc Args.url Args.serverTicket)}
      
      % EL AGENTE SE REGISTRA COMO agenteB
      {Facade register('agenteB')}
      
      % EL AGENTE CREA UNA CONVERSACION CON EL agenteA
      {Facade createConv('agenteA' ConvIdA)}
      {Facade createConv('agente@platformB' ConvIdP2)}
      
      % ENVIA UN MENSAJE A agenteA
      if ConvIdA==nil orelse ConvIdP2==nil then
	 {Facade close}
      else
	 MsgP2={New Message.message init}
	 {MsgP2 setPerformative('perfPrueba')}
	 {MsgP2 setSender('agenteB')}
	 {MsgP2 setReceiver('agente@platformB')}
	 {MsgP2 setContent('contentPrueba')}
	 {MsgP2 setLanguage('languagePrueba')}
	 {MsgP2 setOntology('ontologyPrueba')}
	 {Facade sendMessage(MsgP2 ConvIdP2)}

	 MsgA={New Message.message init}
	 {MsgA setPerformative('perfPrueba')}
	 {MsgA setSender('agenteB')}
	 {MsgA setReceiver('agenteA')}
	 {MsgA setContent('contentPrueba')}
	 {MsgA setLanguage('languagePrueba')}
	 {MsgA setOntology('ontologyPrueba')}
	 {Facade sendMessage(MsgA  ConvIdA)}

         % ESPERA A QUE LE LLEGUE EL MENSAJE DE CONTESTACION
	 if Loop==nil then skip end
	 {Wait Loop}

         % CIERRE
	 {Facade close}
      end
   end
   {Application.exit 0}
end
