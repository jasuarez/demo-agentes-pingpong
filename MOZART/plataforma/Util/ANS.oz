% ANS - Agent Name Service
% AMPLIARLO A VARIAS PLATAFORMAS (FEDERACION)

functor

export
   ANS
   
define
   
   class ANS
      attr
	 platform              % Plataforma local
	 address               % Direccion de la plataforma local
	 port                  % Puerto por el que escucha la plataforma local
	 transportProtocolType % Protocolo de transporte local
	 messageConverterType  % Formato de lectura de los mensajes local
	 agentDic              % Diccionario cuyas claves son los nombres de los agentes registrados en la plataforma
	 platformDic           % Diccionario con todos los datos de todas las plataformas que se comunican con el sistema
	 
      meth init(LocalPlatform OtherPlatform)
	 platform <- {LocalPlatform getPlatform($)}
	 address <- {LocalPlatform getAddress($)}
	 port <- {LocalPlatform getPort($)}
	 messageConverterType <- {LocalPlatform getMessageConverterType($)}
	 transportProtocolType <- {LocalPlatform getTransportProtocolType($)}
	 agentDic <- {Dictionary.new $}
	 platformDic <- {Dictionary.new $}
	 {Dictionary.put @platformDic @platform LocalPlatform}
	 local
	    proc {InsertOtherPlatform Item}
	       {Dictionary.put @platformDic {Item getPlatform($)} Item}
	    end
	 in
	    {ForAll OtherPlatform InsertOtherPlatform}
	 end
      end

      % Si no existe el nombre dado se registra y se devuelve true, en otro caso se devuelve false
      meth register(Name ?Result)
	 if {Dictionary.member @agentDic {VirtualString.toAtom Name $}}==false then
	    {Dictionary.put @agentDic {VirtualString.toAtom Name $} nil}
	    Result=true
	 else
	    Result=false
	 end
      end

      % Borra al agente del diccionario
      meth unregister(Name ?Syn)	 
	 {Dictionary.remove @agentDic {VirtualString.toAtom Name $}}
	 Syn=true
      end

      % Comprueba si el agente esta o no registrado
      meth existsAgent(Agent ?Result)
	 Result={Dictionary.member @agentDic {VirtualString.toAtom Agent $} $}
      end

      % Comprueba si el sistema tiene datos de la plataforma indicada
      meth existsPlatform(Platform ?Result)
	 Result={Dictionary.member @platformDic {VirtualString.toAtom Platform $} $}
      end

      % Devuelve el nombre de la plataforma local
      meth getPlatform(?Platform)
	 Platform=@platform
      end

      % Devuelve el protocolo de transporte de la plataforma indicada
      meth getTransportProtocolPlatform(Platform ?TP)
	 if {Bool.'or' Platform==nil Platform==@platform} then
	    % Plataforma local
	    TP=@transportProtocolType
	 else
	    % AMP 1: Otra plataforma
	    local
	       TPAux
	    in
	       try
		  TPAux={{Dictionary.condGet @platformDic {VirtualString.toAtom Platform $} nil $} getTransportProtocolType($)}
	       catch _ then
		  TPAux=nil
	       end
	       TP=TPAux
	    end
	 end
      end

      % Devuelve el formato de los mensajes de la plataforma indicada
      meth getMessageConverterPlatform(Platform ?MC)
	 if {Bool.'or' Platform==nil Platform==@platform} then
	    % Plataforma local
	    MC=@messageConverterType
	 else
	    % AMP 1: Otra plataforma
	    local
	       MCAux
	    in
	       try
		  MCAux={{Dictionary.condGet @platformDic {VirtualString.toAtom Platform $} nil $} getMessageConverterType($)}
	       catch _ then
		  MCAux=nil
	       end
	       MC=MCAux
	    end
	 end
      end

      % Devuelve la direccion de la plataforma indicada
      meth getAddressPlatform(Platform ?Address)
	 if {Bool.'or' Platform==nil Platform==@platform} then
	    % Plataforma local
	    Address=@address
	 else
	    % AMP 1: Otra plataforma
	    local
	       AddressAux
	    in
	       try
		  AddressAux={{Dictionary.condGet @platformDic {VirtualString.toAtom Platform $} nil $} getAddress($)}
	       catch _ then
		  AddressAux=nil
	       end
	       Address=AddressAux
	    end
	 end
      end

      % Devuelve el puerto de la plataforma indicada
      meth getPortPlatform(Platform ?Port)
	 if {Bool.'or' Platform==nil Platform==@platform} then
	    % Plataforma local
	    Port=@port
	 else
	    % AMP 1: Otra plataforma
	    local
	       PortAux
	    in
	       try
		  PortAux={{Dictionary.condGet @platformDic {VirtualString.toAtom Platform $} nil $} getPort($)}
	       catch _ then
		  PortAux=nil
	       end
	       Port=PortAux
	    end
	 end
      end
   end
end
