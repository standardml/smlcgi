signature CGI =
sig
    val SERVER_SOFTWARE : string
    val SERVER_NAME : string
    val GATEWAY_INTERFACE : string
    val SERVER_PROTOCOL : string
    val SERVER_PORT : string
    val REQUEST_METHOD : string
    val PATH_INFO : string
    val PATH_TRANSLATED : string
    val SCRIPT_NAME : string
    val QUERY_STRING : string
    val REMOTE_HOST : string
    val REMOTE_ADDR : string
    val AUTH_TYPE : string
    val REMOTE_USER : string
    val REMOTE_IDENT : string
    val CONTENT_TYPE : string
    val CONTENT_LENGTH : string
    val HTTP_ACCEPT : string
    val HTTP_ACCEPT_LANGUAGE : string
    val HTTP_USER_AGENT : string
    val HTTP_COOKIE : string

    val uriEncode : string -> string
    val uriDecode : string -> string

    val getParam  : string -> string
    val getParam' : string -> string option

    val startResponse : string -> unit
end

structure CGI :> CGI =
struct
    fun maybeEnv s =
        case OS.Process.getEnv s of
            NONE => ""
          | SOME s => s

    val SERVER_SOFTWARE = maybeEnv "SERVER_SOFTWARE"
    val SERVER_NAME = maybeEnv "SERVER_NAME"
    val GATEWAY_INTERFACE = maybeEnv "GATEWAY_INTERFACE"
    val SERVER_PROTOCOL = maybeEnv "SERVER_PROTOCOL"
    val SERVER_PORT = maybeEnv "SERVER_PORT"
    val REQUEST_METHOD = maybeEnv "REQUEST_METHOD"
    val PATH_INFO = maybeEnv "PATH_INFO"
    val PATH_TRANSLATED = maybeEnv "PATH_TRANSLATED" 
    val SCRIPT_NAME = maybeEnv "SCRIPT_NAME"
    val QUERY_STRING = maybeEnv "QUERY_STRING"
    val REMOTE_HOST = maybeEnv "REMOTE_HOST"
    val REMOTE_ADDR = maybeEnv "REMOTE_ADDR"
    val AUTH_TYPE = maybeEnv "AUTH_TYPE"
    val REMOTE_USER = maybeEnv "REMOTE_USER"
    val REMOTE_IDENT = maybeEnv "REMOTE_IDENT"
    val CONTENT_TYPE = maybeEnv "CONTENT_TYPE"
    val CONTENT_LENGTH = maybeEnv "CONTENT_LENGTH"
    val HTTP_ACCEPT = maybeEnv "HTTP_ACCEPT"
    val HTTP_ACCEPT_LANGUAGE = maybeEnv "HTTP_ACCEPT_LANGUAGE"
    val HTTP_USER_AGENT = maybeEnv "HTTP_USER_AGENT"
    val HTTP_COOKIE = maybeEnv "HTTP_COOKIE"

    fun uriEncode' #"$" = "%24"
      | uriEncode' #"&" = "%26"
      | uriEncode' #"+" = "%2B"
      | uriEncode' #"," = "%2C"
      | uriEncode' #"/" = "%2F"
      | uriEncode' #":" = "%3A"
      | uriEncode' #";" = "%3B"
      | uriEncode' #"=" = "%3D"
      | uriEncode' #"?" = "%3F"
      | uriEncode' #"@" = "%40"
      | uriEncode' #" " = "%20"
      | uriEncode' #"\"" = "%22"
      | uriEncode' #"<" = "%3C"
      | uriEncode' #">" = "%3E"
      | uriEncode' #"#" = "%23"
      | uriEncode' #"%" = "%25"
      | uriEncode' #"{" = "%7B"
      | uriEncode' #"}" = "%7D"
      | uriEncode' #"|" = "%7C"
      | uriEncode' #"\\" = "%5C"
      | uriEncode' #"^" = "%5E"
      | uriEncode' #"~" = "%7E"
      | uriEncode' #"[" = "%5B"
      | uriEncode' #"]" = "%5D"
      | uriEncode' #"`" = "%60"
      | uriEncode' c = String.str c

    fun uriEncode s =
        String.concat (map uriEncode' (String.explode s))

    fun uriDecode' (#"%"::c1::c2::t) =
    let
        fun frmhex c =
            if #"0" <= c andalso c <= #"9" then
                Char.ord c - Char.ord #"0" else
            if #"a" <= c andalso c <= #"f" then
                Char.ord c - Char.ord #"a" + 10 else
            if #"A" <= c andalso c <= #"F" then
                Char.ord c - Char.ord #"A" + 10
            else Char.ord #"?"
    in
        Char.chr ((frmhex c1) * 16 + frmhex c2) :: uriDecode' t
    end
      | uriDecode' (#"+"::t) = #" " :: uriDecode' t
      | uriDecode' (h::t) = h :: uriDecode' t
      | uriDecode' [] = []
        
    fun uriDecode s = String.implode (uriDecode' (String.explode s))

    val paramDict =
    let
        val f = String.fields (fn #"&" => true | _ => false) QUERY_STRING
        val p = map (String.fields (fn #"=" => true | _ => false)) f
    in
        List.foldr
            (fn ([k,v],d) => 
                StringListDict.insert d (uriDecode k) (uriDecode v)
              | (_,d) => d) StringListDict.empty p
    end

    (* Get a parameter, returning the empty string if absent *)
    fun getParam k = 
        case StringListDict.find paramDict k of
            NONE => ""
          | SOME s => s

     (* Get a parameter as an option, so one can test for presence of keys. *)
     val getParam' = StringListDict.find paramDict

    fun startResponse contentType =
        print ("Content-Type: " ^ contentType ^ "\n\n")

end
