%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programa que instancia los agentes pong que se indican en la línea de
% comandos. Estos agentes cargan la máquina durante un segundo.
%
% $Id$
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor

import
   System
   Application
   PongAgentLoad at '../bin/PongAgentLoad.ozf'
   Contador at '../bin/Contador.ozf'

define
   local
      Cnt                        %%Un contador que cuenta cuantos agentes se van lanzando
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
      proc {Lanzar N C}
	 case N of
	    0 then
	    %Seguimos esperando hasta que los pong esten listos
	    {Time.delay 5000}
	    if {C isUpper($)}==false then
	       {System.showInfo {C get($)}#"|"}
	       {Lanzar N C}
	    end
	 else
	    thread
	       local
		  Ag
	       in
		  Ag = {New PongAgentLoad.pongAgentLoad init(N C)}
		  {Ag makeFac('/home/jota/eclipse/pingpong-MOZART/serverTicketQuinlan' Ag)}
		  %{Ag setPlatform('@platformQuinlan')}
	       end
	    end
	    {Lanzar N-1 C}
	 end
      end
   in
      %Programa principal
      Cnt = {New Contador.contador init(NumAgents)}
      {Lanzar NumAgents Cnt}
      {System.showInfo "Todos los agentes lanzados"}
   end
end
