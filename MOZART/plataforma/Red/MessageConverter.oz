% MessageConverter: Objeto abstracto que define la estructura de los objetos traductores de mensajes

functor

import
   MessageConverterString
   
export
   MessageConverter

define
   class MessageConverter
      attr
	 messageConverterObject

      % Crea un traductor del tipo que se le indica y devuelve Error=0, si no encuentra el traductor indicado devuelve 1
      meth init(Type ?Error)
	 case Type of
	    'String' then messageConverterObject <- {New MessageConverterString.messageConverterString init} Error=0
	 else
	    Error=1
	 end
      end

      meth translateIO(MessageI ?MessageO)
	 {@messageConverterObject translateIO(MessageI MessageO)}
      end

      meth translateOI(MessageO ?MessageI ?Errors)
	 {@messageConverterObject translateOI(MessageO MessageI Errors)}
	 {Wait Errors}
	 if Errors==nil then {Wait MessageI} end
      end
   end
end


      