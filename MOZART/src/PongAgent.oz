%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Agente que realiza un pong.
%
% $Id$
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
   
import
   System
   AgentFacade at '../plataforma/API/AgentFacade.ozf'   % Fachada del sistema (registro, creacion de conversacion, envio, etc.)
   Message at '../plataforma/Util/Message.ozf'
   Contador at '../bin/Contador.ozf'

export
   PongAgent
   
define
   %%
   % Agente que contesta con un pong al agente que le envia un ping.
   % AUTOR.: $Author$
   % VERSION: $Revision$
   %%
   class PongAgent
      attr
	 id          %Identificador (número) del agente
	 fachada     %Fachada del sistema (registro, creacion de conversacion, envio, etc.)
	 counter     %Contador compartido para saber cuantos agentes están listos
	 syncList    %Variable para sincronizar los envios y las recepciones
	 
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
	    X
	    Xr
	 in
            %{System.showInfo "PONG"#@id#"> Mensaje recibido: "#{Msg getPerformative($)}#", because "#{Msg getContent($)}}
	    %{System.showInfo "PONG"#@id#"> Mensaje de "#{Msg getSender($)}}
	    {System.showInfo "hola"}
	    {System.showInfo {Msg getPerformative($)}}
	    {System.showInfo "adios"}
	    if {Msg getPerformative($)}=='achieve' then
	       Reply = {New Message.message init}
	       {Reply setPerformative('reply')}
	       {Reply setSender('pong'#@id)}
	       {Reply setReceiver({Msg getSender($)})}
	       {Reply setContent('(pong)')}
	       {Reply setOntology('none')}
	       {Reply setLanguage('mozart')}
	       {Reply setInReplyTo({Msg getReplyWith($)})}
	       {@fachada sendMessage(Reply ConvId)}
	       X|Xr = @syncList
	       X=unit
	       syncList:=Xr
	    end
	 end
      end

      %%
      % Ejecuta la tarea del agente (esperar y contestar).
      %%
      meth start
	 local
	    proc {StartLocal NumMensajes}
	       local
		  X
		  Xr
	       in
		  X|Xr = @syncList
		  {System.showInfo "PONG"#@id#"> Espero por un mensaje"}
		  {Wait X}
		  {System.showInfo "PONG"#@id#"> Mensaje recibido"}
		  {StartLocal NumMensajes+1}
	       end
	    end
	 in
	    {StartLocal 1}
	 end
      end
   end
end
