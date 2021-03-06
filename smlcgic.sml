structure TemplateComp =
struct
    fun makeHeader fname =
        "(* Generated by smlcgic *)\n" ^
        "structure Template =\n" ^
        "struct\n" ^
        "    open CGI\n" ^
        "    val PROGRAM_NAME = \"" ^ fname ^ "\"\n\n" ^
        "    fun render (title,content) =\n" ^
        "    let\n" 

    datatype frag = Code of string
                  | Verbatim of string

    fun parse tmpl =
    let
        fun openTag c [] = (c,[])
          | openTag c ((#"<")::(#"%")::t) = (c,t)
          | openTag c (h::t) = openTag (c @ [h]) t

        fun closeTag c [] = (c,[])
          | closeTag c ((#"%")::(#">")::t) = (c,t)
          | closeTag c (h::t) = closeTag (c @ [h]) t

        fun loop [] = []
          | loop l = 
        let
            val (c,t) = openTag [] l
            val (c',t') = closeTag [] t
        in
            Verbatim (String.implode c) ::
                Code (String.implode c') ::
                    loop t'
        end
    in
        loop (String.explode tmpl)
    end

    fun fragToStr (Verbatim s) =
        "        val _ = print \"" ^ String.toString s ^ "\""
      | fragToStr (Code s) =
        if String.isPrefix "%" s then
            "        val _ = print (" ^ String.extract(s,1,NONE) ^ ")"
        else s

    fun main () =
    let
        val fname =
            hd (CommandLine.arguments ()) handle _ => 
                raise Fail "Usage: smlcgic <filename>"

        val fi = TextIO.openIn fname

        val oname = OS.Path.base fname ^ ".cgi.sml"

        val parts = parse (TextIO.inputAll fi)
        
        val out = String.concatWith "\n" (map fragToStr parts)

        val _ = TextIO.closeIn fi

        val fo = TextIO.openOut oname
        val _ = TextIO.output (fo, makeHeader fname)
        val _ = TextIO.output (fo, out ^ "\n    in () end\nend\n")
        val _ = TextIO.closeOut fo

        val mlbname = OS.Path.base fname ^ ".cgi.mlb"
        val fo' = TextIO.openOut mlbname

        val _ = TextIO.output (fo',
            "$(SML_LIB)/basis/basis.mlb\n" ^
            "$(SMACKAGE)/smlcgi/v0/cgi.mlb\n" ^ 
            oname ^ "\n")

        val _ = TextIO.closeOut fo'
    in
        OS.Process.success
    end
end


val _ = TemplateComp.main ()
