% Gestor de politicas
% AMPLIARLO
functor

   %%JOTA
import
   System
   %%JOTA
   
export
   PoliciesManager
   
define
   class PoliciesManager
      meth init
	 skip
      end

      % Devuelve el estado inicial de una conversacion
      meth initConv(?State)
	 State="prueba"
      end

      % Verifica un mensaje dentro de una conversacion y devuelve un nuevo estado
      meth verifyMessage(Message OldState ?NewState)
	 %%JOTA
	 {System.showInfo "POLICIESMANAGER> El mensaje "#{Message getPerformative($)}#" pasa la prueba"}
	 %%JOTA
	 NewState="prueba"
      end
   end
end
