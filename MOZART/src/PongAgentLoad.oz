%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Agente que realiza un pong. Entre la recepción y el envío carga la máquina
% durante un segundo.
%
% $Id$
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
   
import
   %System
   AgentFacade at '../plataforma/API/AgentFacade.ozf'   % Fachada del sistema (registro, creacion de conversacion, envio, etc.)
   Message at '../plataforma/Util/Message.ozf'
   %Contador at 'Contador.ozf'
   FullLoad at 'FullLoad.ozf'

export
   PongAgentLoad
   
define
   %%
   % Agente que contesta con un pong al agente que le envia un ping.
   % Antes del envio carga la máquina durante un segundo.
   %
   % AUTOR..: $Author$
   % VERSION: $Revision$
   %%
   class PongAgentLoad
      attr
	 id          %Identificador (número) del agente
	 fachada     %Fachada del sistema (registro, creacion de conversacion, envio, etc.)
	 counter     %Contador compartido para saber cuantos agentes están listos
	 
      %%
      % Inicializa el agente.
      %
      % Id  => Identificador del agente
      % Cnt => Contador compartido por todos los agentes
      %%
      meth init(Id Cnt) 
	 id:=Id
	 counter:=Cnt
      end

      %%
      % Registra al agente en el sistema.
      %
      % ServerTicket => Etiqueta del servidor
      % Proc         => Proceso con el que se comunicará el servidor
      %%
      meth makeFac(ServerTicket Proc)
	 fachada:={New AgentFacade.agentFacade init(Proc '/home/jota/eclipse/pingpong-MOZART/pong'#@id#'Ticket' ServerTicket)}
	 {@fachada register('pong'#@id)}
	 {@counter inc}
      end
      
      %%
      % Método que invoca la plataforma cuando se recibe un mensaje.
      %
      % Msg  => Mensaje recibido
      % Conv => Conversación a la que pertenece el mensaje recibido
      %%
      meth recv(Msg ConvId)
	 local
	    Reply
	    Contenido
	 in
	    if {Msg getPerformative($)}=='achieve' then
	       Reply = {New Message.message init}
	       {Reply setPerformative('reply')}
	       {Reply setSender('pong'#@id)}
	       {Reply setReceiver({Msg getSender($)})}
	       Contenido = {String.toInt {Msg getContent($)} $}
	       {Reply setContent({Int.toString {FullLoad.fLoad 1000 Contenido $} $})}
	       {Reply setOntology('none')}
	       {Reply setLanguage('mozart')}
	       {Reply setInReplyTo({Msg getReplyWith($)})}
	       {@fachada sendMessage(Reply ConvId)}
	    end
	 end
      end
   end
end
