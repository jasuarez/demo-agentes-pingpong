%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Agente que envia un "ping" a otro agente y espera la respuesta. Entre el
% envío y la recepción carga la máquina durante un segundo.
%
% $Id$
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor

import
   System
   Property
   AgentFacade at '../plataforma/API/AgentFacade.ozf'   % Fachada del sistema (registro, creacion de conversacion, envio, etc.)
   Message at '../plataforma/Util/Message.ozf'
   FullLoad at 'FullLoad.ozf'


export
   PingAgentLoad

define
   %%
   % Agente que lanza un ping, espera la respuesta y vuelve a repetir el proceso.
   % Cuando detecta que todos los agentes están creados (para ello se emplea un
   % contador global) toma la medida del tiempo de ida y vuelta de mensaje.
   % Posteriormente sigue enviando y recibiendo mensajes hasta que todos los
   % agentes hayan hecho sus medidas. Entre el mensaje de envio y la respuesta
   % se carga la máquina durante un segundo.
   %
   % AUTOR..: $Author$
   % VERSION: $Revision$
   %%
   class PingAgentLoad
      attr
	 id          %Identificador (número) del agente
	 fachada     %Fachada del sistema (registro, creacion de conversacion, envio, etc.)
	 platform:'' %Plataforma de destino del agente pong
	 retries:100 %El número de envios a medir
	 syncList    %Variable para sincronizar los envios y las recepciones
	 counter     %Contador compartido para saber cuantos agentes están listos
	 valPing:0   %El valor calculado como consecuencia de la operación
	 valPong:0   %El valor devuelto por el agente Pong

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
	    valPong:={String.toInt {Msg getContent($)} $}
	    {System.showInfo "PING"#@id#"> El valor es "#(@valPing+@valPong)}
	    X|Xr = @syncList
	    X=unit
	    syncList:=Xr
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
	 in
	    case N of
	       0 then skip
	    else
	       {@fachada sendMessage(M C)}
	       valPing:={FullLoad.fLoad 1000 @id $}
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
	    {Msg setContent({Int.toString @id $})}
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
    	    {Msg setContent({Int.toString @id $})}
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
