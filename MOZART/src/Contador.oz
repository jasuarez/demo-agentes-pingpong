%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mostramos un grafico de como funciona la histeresis
% 
%     contador
%        ^
%        |
% limite +           ************
%        |           *          *
%        |           *          *
%      0 +************          **********
%        ---+-----------+-----------+--------> tiempo
%        !isUpper()   isUpper()   isUpper()
%        !isLower()   !islower()  isLower()
% 
% $Id$
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor

import
   System

export
   Contador

define
   %%
   % Contador con histeresis.
   %
   % AUTOR..: $Author$
   % VERSION: $Revision$
   %%
   class Contador
      attr
	 counter:0     %El valor del contador
	 limit         %El limite a partir del cual conmuta
	 upper:false   %Verdadero si ha alcanzado alguna vez el limite
	 lower:false   %Verdadero si ha llegado a cero después de alcanzar el límite

      prop locking

      %%
      % Inicializa el contador.
      %
      % Lim => Límite en el que se produce el cambio
      %%
      meth init(Lim)
	 lock
	    limit:=Lim
	    counter:=0
	    upper:=false
	    lower:=false
	 end
      end
      
      %%
      % Incrementa en una unidad el contador.
      %%
      meth inc
	 lock
	    counter:=@counter+1
	    upper:=@upper orelse @counter==@limit
	 end
      end

      %%
      % Decrementa en una unidad el contador.
      %%
      meth dec
	 lock
	    counter:=@counter-1
	    lower:=@upper andthen @counter==0
	 end
      end

      %%
      % Indica si hemos llegado hasta abajo en el contador.
      %
      % RETURNS => Verdadero si el contador llega a cero después del cambio de histéresis
      %%
      meth isLower($)
	 @lower
      end

      %%
      % Indica si se ha realizado un cambio de histéresis.
      %
      % RETURNS => Verdadero si se ha producido dicho cambio (el contador llegó al límite)
      %%
      meth isUpper($)
	 @upper
      end

      %%
      % Devuelve el valor del contador.
      %
      % RETURNS => El valor del contador
      %%
      meth get($)
	 @counter
      end
   end
end
