%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programa que instancia los agentes ping que se indican en la línea de
% comandos.
%
% $Id$
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor

import
   System
   Application
   PingAgent at '../bin/PingAgent.ozf'
   PongAgent at '../bin/PongAgent.ozf'
   Contador at '../bin/Contador.ozf'

define
   local
      Cnt2                       %%Un contador que cuenta cuantos agentes se van lanzando
      Args                       %%Argumentos del programa
      try
      	Args={Application.getCmdArgs record(numAgents(single char:&n type:int))}
      catch error(ap(usage S)...) then
      	{System.showError "Falta indicar el numero de agentes"}
	{System.showError S}
	{Application.exit 1}
      end
      NumAgents=Args.numAgents   %%Número de agentes a lanzar

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
		  Ag = {New PingAgent.pingAgent init(N C)}
		  {Ag makeFac('/home/jota/eclipse/pingpong-MOZART/serverTicketShoham' Ag)}
		  {Ag setPlatform('@platformQuinlan')}
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
      Cnt2 = {New Contador.contador init(NumAgents)}
      {LanzarClientes NumAgents Cnt2}
      {EsperarFin Cnt2}
      {Time.delay 1000}
   end
end
