% Objeto Mensaje acorde con la definicion de mensaje KQML

functor

export
   Message

define
   class Message
      attr
	 performative:nil
	 sender:nil
	 receiver:nil
	 content:nil
	 language:nil
	 ontology:nil
	 inReplyTo:nil
	 replyWith:nil
	 aspect:nil
	 order:nil
	 comment:nil
	 code:nil
	 force:nil
	 agent:nil
	 name:nil
	 kqmlTo:nil
	 kqmlFrom:nil
	 
      meth init
	 skip
      end

      % Metodos get y set
      meth getPerformative(?Performative)
	 Performative=@performative
      end
      
      meth setPerformative(Performative)
	 performative <- Performative
      end
      meth getSender(?Sender)
	 Sender=@sender
      end
      meth setSender(Sender)
	 sender <- Sender
      end
      meth getReceiver(?Receiver)
	 Receiver=@receiver
      end
      meth setReceiver(Receiver)
	 receiver <- Receiver
      end
      meth getContent(?Content)
	 Content=@content
      end
      meth setContent(Content)
	 content <- Content
      end
      meth getLanguage(?Language)
	 Language=@language
      end
      meth setLanguage(Language)
	 language <- Language
      end
      meth getOntology(?Ontology)
	 Ontology=@ontology
      end
      meth setOntology(Ontology)
	 ontology <- Ontology
      end
      meth getInReplyTo(?InReplyTo)
	 InReplyTo=@inReplyTo
      end
      meth setInReplyTo(InReplyTo)
	 inReplyTo <- InReplyTo
      end
      meth getReplyWith(?ReplyWith)
	 ReplyWith=@replyWith
      end
      meth setReplyWith(ReplyWith)
	 replyWith <- ReplyWith
      end
      meth getAspect(?Aspect)
	 Aspect=@aspect
      end
      meth setAspect(Aspect)
	 aspect <- Aspect
      end
      meth getOrder(?Order)
	 Order=@order
      end
      meth setOrder(Order)
	 order <- Order
      end
      meth getComment(?Comment)
	 Comment=@comment
      end
      meth setComment(Comment)
	 comment <- Comment
      end
      meth getCode(?Code)
	 Code=@code
      end
      meth setCode(Code)
	 code <- Code
      end
      meth getForce(?Force)
	 Force=@force
      end
      meth setForce(Force)
	 force <- Force
      end
      meth getAgent(?Agent)
	 Agent=@agent
      end
      meth setAgent(Agent)
	 agent <- Agent
      end
      meth getName(?Name)
	 Name=@name
      end
      meth setName(Name)
	 name <- Name
      end
      meth getKqmlTo(?KqmlTo)
	 KqmlTo=@kqmlTo
      end
      meth setKqmlTo(KqmlTo)
	 kqmlTo <- KqmlTo
      end
      meth getKqmlFrom(?KqmlFrom)
	 KqmlFrom=@kqmlFrom
      end
      meth setKqmlFrom(KqmlFrom)
	 kqmlFrom <- KqmlFrom
      end
%%%
      meth getArguments(?Arguments) ArgCell in
	 {NewCell nil ArgCell}
	 if @sender\=nil then
	    {Assign ArgCell [['sender' @sender]]}
	 end
	 if @receiver\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['receiver' @receiver]] $}}
	 end
	 if @content\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['content' @content]] $}}
	 end
	 if @language\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['language' @language]] $}}
	 end
	 if @ontology\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['ontology' @ontology]] $}}
	 end
	 if @inReplyTo\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['in-reply-to' @inReplyTo]] $}}
	 end
	 if @replyWith\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['reply-with' @replyWith]] $}}
	 end
	 if @aspect\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['aspect' @aspect]] $}}
	 end
	 if @order\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['order' @order]] $}}
	 end
	 if @comment\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['comment' @comment]] $}}
	 end
	 if @code\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['code' @code]] $}}
	 end
	 if @force\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['force' @force]] $}}
	 end
	 if @agent\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['agent' @agent]] $}}
	 end
	 if @name\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['name' @name]] $}}
	 end
	 if @kqmlTo\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['to' @kqmlTo]] $}}
	 end
	 if @kqmlFrom\=nil then
	    {Assign ArgCell {List.append {Access ArgCell $} [['from' @kqmlFrom]] $}}
	 end
	 Arguments={Access ArgCell $}
      end
   end
end



