%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Permite cargar el sistema durante el tiempo indicado.
%
% $Id$
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
   
import
   %System
   Property
   
export
   FLoad
   
define
   %%
   % Carga la máquina durante un tiempo determinado. Para ello ejecuta una
   % operación durante ese tiempo.
   %
   % Time    => La duracion de la carga en milisegundos
   % VInit   => Una semilla empleada para la operación
   % ?Result => El resultado de la operación
   %%
   proc {FLoad Time VInit ?Result}
      local
	 fun {LoadTemp TimeLong TimeInit ValAcum}
	    if ({Property.get time}.total - TimeInit) < TimeLong then
	       %calcular
	       local
		  ValCos
		  ValInt
	       in
		  ValCos = {Float.cos {IntToFloat {Property.get time}.total mod 1000 $} $}
		  ValInt = {Float.toInt ValCos*100.0 $}
		  {LoadTemp TimeLong TimeInit ValAcum+ValInt}
	       end
	    else
	       ValAcum
	    end
	 end
      in
	 Result = {LoadTemp Time {Property.get time}.total VInit}
      end
   end
end
