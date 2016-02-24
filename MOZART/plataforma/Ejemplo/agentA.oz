% AGENTE DE PRUEBA
%
% 1 - Se registra como agenteA
% 2 - Espera a que le llegue un mensaje
% 3 - Muestra los parametros del mensaje recibido por pantalla
% 4 - Devuelve un mensaje al emisor

functor
   
import
   Application
   System
   AgentFacade at '../API/AgentFacade.ozf'   % Fachada del sistema (registro, creacion de conversacion, envio, etc.)
   Message at '../Util/Message.ozf'
   
define
   % CAPTURA DE PARAMETROS
   AppName="agenteA"
   Spec=record(url(single char:&u type:string optional:false)
	       serverTicket(single char:&s type:string optional:false))
   Args
   try
      Args={Application.getCmdArgs Spec}
   catch error(ap(usage S)...) then
      {System.showError AppName#": "#S}
      {Application.exit 1}
   end
   
   % CREACION DEL OBJETO Proc QUE SE ENCARGA DE RECIBIR LOS MENSAJES, MOSTRARLOS, Y EN ESTE CASO ENVIAR UNA CONTESTACION
   local
      Facade               % Objeto Fachada necesario para interactuar con el sistema
      SynchClose           % Variable de sincronizacion, para terminar la ejecucion una vez recibido y contestado el mensaje
      ConvId               % Celda que almacena Identificador de conversacion
      NewConvId            % Identificador de una nueva conversacion
      MsgRecv              % Celda que almacena Objeto mensaje
      Msg1 Msg2 Msg3       % Objetos Mensaje a enviar

      {NewCell nil ConvId}
      {NewCell nil MsgRecv}
      
      class ProcClass
	 meth init skip end
	 % Recepcion del mensaje
	 meth recv(Msg ConversationID)
	    {System.showInfo "\nMENSAJE RECIBIDO:\n"}
	    case Msg of error(Comment) then
	       {System.show Comment}
	    else
	       if {Msg getSender($)}=='SYSTEM' orelse {Msg getPerformative($)}==nil then
	          % Muestra el comentario del mensaje de error
		  {System.show {Msg getComment($)}}
	       else
		  {Assign ConvId ConversationID}
	          % Muestra los parametros del mensaje
		  {System.show {Msg getPerformative($)}}
		  {System.show {Msg getSender($)}}
		  {System.show {Msg getReceiver($)}}
		  {System.show {Msg getContent($)}}
		  {System.show {Msg getLanguage($)}}
		  {System.show {Msg getOntology($)}}
		  {System.show {Msg getReplyWith($)}}
		  {System.show ConversationID}
		  {Assign MsgRecv Msg}
	          % Termina la ejecucion
		  if {Value.isFree SynchClose $} then
		     SynchClose=nil
		  end
	       end
	    end
	 end
      end
      Proc={New ProcClass init}
   in
      % CREACION DE UNA FACHADA PARA ACCEDER AL SISTEMA
      Facade={New AgentFacade.agentFacade init(Proc Args.url Args.serverTicket)}
      
      % EL AGENTE SE REGISTRA COMO agenteA
      {Facade register('agenteA')}
      
      % ESPERA A QUE LE LLEGUE UN MENSAJE PARA MANDARLE UNA CONTESTACION
      {Wait SynchClose}
      Msg1={New Message.message init}
      {Msg1 setPerformative('PerfCA')}
      {Msg1 setSender('agenteA')}
      {Msg1 setReceiver('agenteB')}
      {Msg1 setContent('ContentCA')}
      {Msg1 setLanguage('LanguageCA')}
      {Msg1 setOntology('OntologyCA')}
      {Msg1 setInReplyTo({{Access MsgRecv $} getReplyWith($)})}
      {Facade sendMessage(Msg1 {Access ConvId $})}

      Msg2={New Message.message init}
      {Msg2 setPerformative('PerfCA2')}
      {Msg2 setSender('agenteA')}
      {Msg2 setReceiver('agenteB')}
      {Msg2 setContent('ContentCA2')}
      {Msg2 setLanguage('LanguageCA2')}
      {Msg2 setOntology('OntologyCA2')}
      {Msg2 setInReplyTo({{Access MsgRecv $} getReplyWith($)})}
      {Facade sendMessage(Msg2 {Access ConvId $})}


      {Facade createConv('agenteB' NewConvId)}
      Msg3={New Message.message init}
      {Msg3 setPerformative('PerfCA3')}
      {Msg3 setSender('agenteA')}
      {Msg3 setReceiver('agenteB')}
      {Msg3 setContent('ContentCA3')}
      {Msg3 setLanguage('LanguageCA3')}
      {Msg3 setOntology('OntologyCA3')}
      {Facade sendMessage(Msg3 NewConvId)}
     
      % CIERRE
      {Facade close}
   end
   {Application.exit 0}
end
