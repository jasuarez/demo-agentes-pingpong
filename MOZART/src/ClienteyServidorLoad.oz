%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programa que instancia los agentes ping y pong que se indican en la línea de
% comandos. Estos agentes cargan la máquina durante un segundo.
%
% $Id$
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor

import
   System
   Application
   PingAgentLoad at 'PingAgentLoad.ozf'
   PongAgentLoad at 'PongAgentLoad.ozf'
   Contador at 'Contador.ozf'

define
   local
      Cnt1                       %%Un contador que cuenta cuantos agentes pong se van lanzando
      Cnt2                       %%Un contador que cuenta cuantos agentes ping se van lanzando
      Args
      try
      	Args={Application.getCmdArgs record(numAgents(single char:&n type:int))}
      catch error(ap(usage S)...) then
      	{System.showError "Falta indicar el numero de agentes"}
	{System.showError S}
	{Application.exit 1}
      end
      NumAgents=Args.numAgents   %%Número de agentes a lanzar

      %%
      % Ejecuta los agentes pong.
      %
      % N => Número de agentes a ejecutar
      % C => Contador que comparten los agentes
      %%
      proc {LanzarServidores N C}
	 case N of
	    0 then
	    %Seguimos esperando hasta que los pong esten listos
	    {Time.delay 5000}
	    if {C isUpper($)}==false then
	    	{System.showInfo {C get($)}#"|"}
	    	{LanzarServidores N C}
	    end
	 else
	    thread
	       local
		  Ag
	       in
		  Ag = {New PongAgentLoad.pongAgentLoad init(N C)}
		  {Ag makeFac('/home/jota/eclipse/pingpong-MOZART/serverTicketShoham' Ag)}
		  %{Ag setPlatform('@platformQuinlan')}
	       end
	    end
	    {LanzarServidores N-1 C}
	 end
      end

      %%
      % Ejecuta los agentes ping.
      %
      % N => Número de agentes a ejecutar
      % C => Contador que comparten los agentes
      %%
      proc {LanzarClientes N C}
	 case N of
	    0 then
	    {Time.delay 5000}
	    {System.showInfo "Todos los agentes lanzados"}
	 else
	    thread
	       local
		  Ag
	       in
		  Ag = {New PingAgentLoad.pingAgentLoad init(N C)}
		  {Ag makeFac('/home/jota/eclipse/pingpong-MOZART/serverTicketShoham' Ag)}
		  %{Ag setPlatform('@platformQuinlan')}
		  {Ag start}
	       end
	    end
	    {LanzarClientes N-1 C}
	 end
      end

      %%
      % Espera que todos los agentes hayan acabado su tarea.
      %
      % Cnt => Contador para saber cuando los agentes han finalizado
      %%
      proc {EsperarFin Cnt}
	 {System.showInfo {Cnt get($)}#"-"}
	 {Time.delay 5000}
	 if {Cnt isLower($)}==false then
	    {EsperarFin Cnt}
	 else
	    {Application.exit 0}
	 end
      end
   in
      %Programa principal
      Cnt1 = {New Contador.contador init(NumAgents)}
      Cnt2 = {New Contador.contador init(NumAgents)}
      {LanzarServidores NumAgents Cnt1}
      {LanzarClientes NumAgents Cnt2}
      {EsperarFin Cnt2}
      {Time.delay 1000}
   end
end
