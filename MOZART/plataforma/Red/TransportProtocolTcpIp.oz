% TransportProtocolTcpIp: Objeto que representa el protocolo TcpIp de transporte a usar para mandar y recibir mensajes

functor

import
   Connection
   Pickle
   Open
   
export
   TransportProtocolTcpIp

define
   
   class TransportProtocolTcpIp
      attr
	 socket
	 threadRead
	 threadConnection
	 messageDistributor
	 port
	 
      meth init(Port MessageDistributor AddressSend PortSend)
	 socket <- {New Open.socket init}
	 if MessageDistributor\=nil then
	    port <- {String.toInt {VirtualString.toString Port $} $}
	    {Wait @port}
	    {@socket bind(takePort:@port)}
	    {@socket listen}
	    messageDistributor <- {Connection.take {Pickle.load MessageDistributor}}
	 else
	    {@socket connect(host:AddressSend port:{String.toInt {VirtualString.toString PortSend $} $})}
	 end
      end

      meth activate
	 local
	    A
	    MyMessageD=@messageDistributor
	    class Accepted from Open.socket 
	       meth report MessageRecv LenI in
		  {self read(list:MessageRecv len:LenI)}
		  if LenI\=0 then
		     {MyMessageD messageReceived(MessageRecv)}
		     {self report}
		  end
	       end
	    end
	 in
	    thread
	       threadConnection <- {Thread.this $}
	       {@socket accept(acceptClass:Accepted accepted:?A)}
	       thread
		  threadRead <- {Thread.this $}
		  {A report}
	       end
	       {self activate}
	    end
	 end
      end

      meth sendMessage(Message)
	 {@socket write(vs:Message)}
      end

      meth close(?Fin)
	 if {Value.isFree @threadRead $}==false andthen {Thread.state @threadRead $}\=terminated then
	    {Thread.terminate @threadRead}
	 end
	 if {Value.isFree @threadConnection $}==false andthen {Thread.state @threadConnection $}\=terminated then
	    {Thread.terminate @threadConnection}
	 end
	 {@socket flush}
	 {@socket close}
	 Fin=true
      end
   end
end


      