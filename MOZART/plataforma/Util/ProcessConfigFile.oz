% ProcessConfigFile carga los datos de un fichero de configuracion en un
% diccionario y permite leerlos comodamente

functor
   
import
   Open
   
export
   ProcessConfigFile
   
define
   class ProcessConfigFile
      attr configData
      meth init()
	 configData <- {Dictionary.new $}
      end
      meth read(File)
	 local
	    Lines
	    class TextFile from Open.text Open.file end
	    proc {ReadLines FileName ?Lines}
	       F={New TextFile init(name:FileName)}
	       fun {Read}
		  case {F getS($)} of false then nil
		  [] Line then Line|{Read} end
	       end
	    in
	       Lines={Read}
	       {F close}
	    end
	    proc {AddToDictionary Line}
	       local
		  Key Value
	       in
		  {String.token Line &= Key Value}
		  {Dictionary.put @configData {String.toAtom Key} {String.toAtom Value}}
	       end
	    end
	 in
	    Lines={ReadLines File}
	    {ForAll Lines AddToDictionary}
	 end
      end
      meth get(Key Value)
	 {Dictionary.get @configData Key Value}
      end
   end
end
