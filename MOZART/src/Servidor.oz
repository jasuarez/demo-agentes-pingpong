%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programa que instancia los agentes pong que se indican en la línea de
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
      Cnt1                       %%Un contador que cuenta cuantos agentes se van lanzando
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
	    {System.showInfo "Todos los agentes lanzados"}
	 else
	    thread
	       local
		  Ag
	       in
		  Ag = {New PongAgent.pongAgent init(N C)}
		  {Ag makeFac('/home/jota/eclipse/pingpong-MOZART/serverTicketQuinlan' Ag)}
		  %{Ag setPlatform('@platformQuinlan')}
		  {Ag start}
	       end
	    end
	    {LanzarServidores N-1 C}
	 end
      end
   in
      %Programa principal
      Cnt1 = {New Contador.contador init(NumAgents)}
      {LanzarServidores NumAgents Cnt1}
      {Time.delay 300000}
      {System.showInfo "Fin de las pruebas"}
   end
end
