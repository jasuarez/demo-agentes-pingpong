%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programa que instancia los agentes ping que se indican en la línea de
% comandos. Estos agentes cargan la máquina durante un segundo.
%
% $Id$
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor

import
   System
   Application
   PingAgentLoad at 'PingAgentLoad.ozf'
   Contador at 'Contador.ozf'

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
      % Ejecuta los agentes ping.
      %
      % N => Número de agentes a ejecutar
      % C => Contador que comparten los agentes
      %%
      proc {Lanzar N C}
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
		  {Ag makeFac('/home/jota/eclipse/pingpong-MOZART/serverTicketAliana' Ag)}
		  {Ag setPlatform('@platformQuinlan')}
		  {Ag start}
	       end
	    end
	    {Lanzar N-1 C}
	 end
      end

      %%
      % Espera que todos los agentes hayan acabado su tarea.
      %
      % Cnt => Contador para saber cuando los agentes han finalizado
      %%
      proc {EsperarFin Cnt}
	 {System.showInfo "-"}
	 {Time.delay 5000}
	 if {Cnt isLower($)}==false then
	    {EsperarFin Cnt}
	 else
	    {Application.exit 0}
	 end
      end
   in
      %Programa principal
      Cnt = {New Contador.counter init(NumAgents)}
      {Lanzar NumAgents Cnt}
      {EsperarFin Cnt}
   end
end
