%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Agente que envia un "ping" a otro agente y espera la respuesta.
%
% $Id$
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor

import
   System
   Property
   AgentFacade at '../plataforma/API/AgentFacade.ozf'   % Fachada del sistema (registro, creacion de conversacion, envio, etc.)
   Message at '../plataforma/Util/Message.ozf'


export
   PingAgent

define
   %%
   % Agente que lanza un ping, espera la respuesta y vuelve a repetir el proceso.
   % Cuando detecta que todos los agentes están creados (para ello se emplea un
   % contador global) toma la medida del tiempo de ida y vuelta de mensaje.
   % Posteriormente sigue enviando y recibiendo mensajes hasta que todos los
   % agentes hayan hecho sus medidas.
   %
   % AUTOR..: $Author$
   % VERSION: $Revision$
   %%
   class PingAgent
      attr
	 id          %Identificador (número) del agente
	 fachada     %Fachada del sistema (registro, creacion de conversacion, envio, etc.)
	 platform:'' %Plataforma de destino del agente pong
	 retries:100 %El número de envios a medir
	 syncList    %Variable para sincronizar los envios y las recepciones
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
	 fachada:={New AgentFacade.agentFacade init(Proc '/home/jota/eclipse/pingpong-MOZART/ping'#@id#'Ticket' ServerTicket)}
	 {@fachada register('ping'#@id)}
	 %{System.showInfo "PING"#@id#"> Ya estoy registrado"}
      end

      %%
      % Establece la plataforma en la que se encuentra el agente destino.
      %
      % Platform => Plataforma de destino
      %%
      meth setPlatform(Platform)
	 platform:=Platform
      end

      %%
      % Método que invoca la plataforma cuando se recibe un mensaje.
      %
      % Msg  => Mensaje recibido
      % Conv => Conversación a la que pertenece el mensaje recibido
      %%
      meth recv(Msg Conv)
	 local
	    X
	    Xr
	 in
	    %%Suponemos que el mensaje es de respuesta
	    %{System.showInfo "PING"#@id#"> Mensaje recibido: "#{Msg getPerformative($)}#", because "#{Msg getContent($)}}
	    {System.showInfo "PING"#@id#"> Mensaje "#{Msg getPerformative($)}#" de "#{Msg getSender($)}#" ["#{Msg getContent($)}#"]"}
	    X|Xr = @syncList
	    X=unit
	    syncList:=Xr
	    %{System.showInfo "Fin de recepcion"}
	    end
      end

      %%
      % Envia un mensaje varias veces.
      %
      % N => Número de veces a enviar el mensaje
      % M => Mensaje a enviar
      % C => Conversación en la que se envía el mensaje
      %%
      meth Enviar(N M C)
	 local
	    X
	    Xr
	    Mensaje
	 in
	    case N of
	       0 then skip
	    else
	       %Por alguna razon elimina la plataforma del destinatario. Por eso volvemos a indicar en el mensaje
	       %el destinatario del mensaje
	       Mensaje={New Message.message init}
	       {Mensaje setPerformative('achieve')}
	       {Mensaje setSender('ping'#@id)}
	       {Mensaje setReceiver('pong'#@id#@platform)}
	       {Mensaje setContent('(ping)')}
	       {Mensaje setLanguage('mozart')}
	       {Mensaje setOntology('none')}
	       
	       {M setReceiver('pong'#@id#@platform)}
	       {System.showInfo "PING"#@id#"> Envio un mensaje a "#{M getReceiver($)}}
	       {@fachada sendMessage(Mensaje C)}
	       X|Xr = @syncList
	       {Wait X}
	       {self Enviar(N-1 M C)}
	    end
	 end
      end
      
      %%
      % Crea y envia un mensaje varias veces, midiendo el tiempo medio
      % de envío.
      %%
      meth enviarCronometrar
	 local
	    Conv
	    Msg
	    TimeInit
	 in
	    {@fachada createConv('pong'#@id#@platform Conv)}
	    Msg={New Message.message init}
	    {Msg setPerformative('achieve')}
	    {Msg setSender('ping'#@id)}
	    {Msg setReceiver('pong'#@id#@platform)}
	    {Msg setContent('(ping)')}
	    {Msg setLanguage('mozart')}
	    {Msg setOntology('none')}
	    TimeInit = {Property.get 'time.total'}
	    {self Enviar(@retries Msg Conv)}
	    {System.showInfo "@PING"#@id#","#{IntToFloat ({Property.get 'time.total'} - TimeInit) $}/{IntToFloat @retries $}}
	 end
      end

      %%
      % Crea y envia un mensaje varias veces.
      %%
      meth enviarSinCronometrar
	 local
	    Conv
	    Msg
	 in
	    {@fachada createConv('pong'#@id#@platform Conv)}
	    Msg={New Message.message init}
	    {Msg setPerformative('achieve')}
	    {Msg setSender('ping'#@id)}
	    {Msg setReceiver('pong'#@id#@platform)}
	    {Msg setContent('(ping)')}
	    {Msg setLanguage('mozart')}
	    {Msg setOntology('none')}
	    {self Enviar(2 Msg Conv)}
	 end
      end

      %%
      % Ejecuta la tarea del agente (esperar, medir, esperar y finalizar).
      %%
      meth start
	 local
	    proc {Cargar}
	       {self enviarSinCronometrar}
	       if {@counter isUpper($)}==false then
		  {Cargar}
	       end
	    end
	    proc {Esperar}
	       {self enviarSinCronometrar}
	       if {@counter isLower($)}==false then
		  {Esperar}
	       end
	    end
	 in
	    {self enviarSinCronometrar}
	    {@counter inc}
	    {Cargar}
	    {System.showInfo "PING"#@id#"> Inicio de la medida"}
	    {self enviarCronometrar}
	    {System.showInfo "PING"#@id#"> Fin de la medida"}
	    {@counter dec}
	    {Esperar}
	    {@fachada close}
	 end
      end
   end
end
