% Gestor de politicas
% AMPLIARLO
functor

   
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
	 NewState="prueba"
      end
   end
end
