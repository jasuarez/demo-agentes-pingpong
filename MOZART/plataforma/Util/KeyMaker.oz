% KeyMaker: Generador de claves
% Dado un valor anterior genera uno nuevo

functor
   
export
   GetNewKey
   
define
   proc {GetNewKey OldKey ?NewKey}
      NewKey=OldKey+1
   end
end
