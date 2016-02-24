% TicketMaker se encarga de crear un ticket a partir de
% un objeto o procedimiento y de una url

functor
   
import
   Connection
   Pickle
 
export
   Start
   
define
   proc {Start Proc File ?Syn ?Gate}
      Requests P={NewPort Requests} Ticket
      proc {Proxy Msg}
%	 if {Port.send P request(Msg $)} then skip
%	 else
%	    raise remoteError end
%	 end
	 {Port.send P Msg}
      end
   in
      {New Connection.gate init(Proxy Ticket) Gate}
      {Pickle.save Ticket File}
      Syn=true
%      local
%	 Counter
%      in
      {ForAll Requests
       proc {$ R}
%	  case R of request(Msg OK) then
%	     try {Proc Msg} OK=true catch _ then
%		try OK=false catch _ then skip end
%	     end
%	  else
%	     skip
%	  end
% 	     if {Value.isFree Counter $} then
% 		{NewCell 0 Counter}
% 	     end
% 	     if {Access Counter $}<2 then
% 		{Assign Counter {Access Counter $}+1}
% 	     else
% 		if {Access Counter $}==2 then
% 		   {Delay 10000}
% 		   {Assign Counter 3}
% 		end
% 	     end
	  {Proc R}
       end}
%   end
   end
end
