% MessageConverterString: Objeto concreto que traduce los mensajes del formato interno usado por el sistema a formato String

functor

import
   StringFormatScanner
   StringFormatParser
   Message at '../Util/Message.ozf'
     
export
   MessageConverterString

define
   class MessageConverterString
      meth init
	 skip
      end

      meth translateIO(MessageI ?MessageO)
	 local
	    MessageBString
	    Arguments
	    proc {AddArgument Item} RealName Value in
	       {List.nth Item 1 RealName}
	       {List.nth Item 2 Value}
	       {Assign MessageBString {ByteString.append {Access MessageBString $} {ByteString.append {ByteString.make ' :' $}
										    {ByteString.append {ByteString.make RealName $}
										     {ByteString.append {ByteString.make ' ' $}
										      {ByteString.make Value $} $} $} $} $}}
	    end
	 in
	    {NewCell {ByteString.append {ByteString.make '(' $} {ByteString.make {MessageI getPerformative($)} $} $} MessageBString}
	    {MessageI getArguments(Arguments)}
	    {ForAll Arguments AddArgument}
	    {Assign MessageBString {ByteString.append {Access MessageBString $} {ByteString.make ')' $} $}}
	    MessageO={Access MessageBString $}
	 end
      end

      meth translateOI(MessageO ?MessageI ?Errors)
	 local
	    MyScanner = {New StringFormatScanner.stringFormatScanner init()}
	    MyParser = {New StringFormatParser.stringFormatParser init(MyScanner)}
	    Output Status
	    ErrCell = {NewCell nil $}
	    AuxVS1={NewCell nil $}
	    AuxVS2={NewCell nil $}
	    proc {AddArg ArgTuple}
	       {Wait ArgTuple}
	       {ForAll ArgTuple.1 proc {$ X}
				     if {Access AuxVS1 $}==nil then
					{Assign AuxVS1 [{List.nth X 1 $}]}
				     else
					{Assign AuxVS1 {List.append {Access AuxVS1 $} [{List.nth X 1 $}]}}
				     end
				  end}
	       {ForAll ArgTuple.2 proc {$ X}
				     if {Access AuxVS2 $}==nil then
					{Assign AuxVS2 [{List.nth X 1 $}]}
				     else
					{Assign AuxVS2 {List.append {Access AuxVS2 $} [{List.nth X 1 $}]}}
				     end
				  end}
	       case {Access AuxVS1 $} of
		  "sender" then {MessageI setSender({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "receiver" then {MessageI setReceiver({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "content" then {MessageI setContent({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "language" then {MessageI setLanguage({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "ontology" then {MessageI setOntology({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "in-reply-to" then {MessageI setInReplyTo({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "reply-with" then {MessageI setReplyWith({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "aspect" then {MessageI setAspect({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "order" then {MessageI setOrder({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "comment" then {MessageI setComment({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "code" then {MessageI setCode({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "force" then {MessageI setForce({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "agent" then {MessageI setAgent({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "name" then {MessageI setName({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "to" then {MessageI setKqmlTo({VirtualString.toAtom {Access AuxVS2 $} $})}
	       [] "from" then {MessageI setKqmlFrom({VirtualString.toAtom {Access AuxVS2 $} $})}
	       else
		  if {Access ErrCell $}==nil then		     
		     {Assign ErrCell [ArgTuple]}
		  else
		     {Assign ErrCell {List.append {Access ErrCell $} [ArgTuple]}}
		  end
	       end
	       {Assign AuxVS1 nil}
	       {Assign AuxVS2 nil}
	    end
	    PerfCell={NewCell nil $}
	 in
	    {MyScanner scanVirtualString(MessageO)}
	    {MyParser parse(program(?Output) ?Status)}
	    {MyScanner close()}
	    if Status then
	       MessageI={New Message.message init}
	       {Wait MessageI}
	       {ForAll Output.1 proc {$ X}
				     if {Access PerfCell $}==nil then
					{Assign PerfCell [{List.nth X 1 $}]}
				     else
					{Assign PerfCell {List.append {Access PerfCell $} [{List.nth X 1 $}]}}
				     end
				  end}
	       {MessageI setPerformative({VirtualString.toAtom {Access PerfCell $} $})}
	       if Output.2\=nil then
		  {ForAll Output.2 AddArg}
	       end
	    else
	       {Assign ErrCell "PARSER ERROR"}
	    end
	    Errors={Access ErrCell $}
	 end
      end
   end
end


      