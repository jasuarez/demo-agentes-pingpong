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
   % Carga la m�quina durante un tiempo determinado. Para ello ejecuta una
   % operaci�n durante ese tiempo.
   %
   % Time    => La duracion de la carga en milisegundos
   % VInit   => Una semilla empleada para la operaci�n
   % ?Result => El resultado de la operaci�n
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
