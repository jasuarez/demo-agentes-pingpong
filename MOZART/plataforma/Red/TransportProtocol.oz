% TransportProtocol: Objeto abstracto que define la estructura de los objetos que representan el protocolo de transporte a usar para
% mandar y recibir mensajes

functor

import
   TransportProtocolTcpIp

export
   TransportProtocol

define
   class TransportProtocol
      attr
	 transportProtocolObject

      % Crea un protocolo del tipo que se le indica y devuelve Error=0, si no encuentra el protocolo indicado devuelve 1
      meth init(Type MessageDistributor Port AddressSend PortSend ?Error)
	 case Type of
	    'TcpIp' then
	    transportProtocolObject <- {New TransportProtocolTcpIp.transportProtocolTcpIp init(Port MessageDistributor
											       AddressSend PortSend)}
	    Error=0
	 else
	    Error=1
	 end
      end

      meth activate
	 {@transportProtocolObject activate}
      end

      meth sendMessage(Message)
	 {@transportProtocolObject sendMessage(Message)}
      end

      meth close(?Fin)
	 {@transportProtocolObject close(Fin)}
      end
   end
end


      