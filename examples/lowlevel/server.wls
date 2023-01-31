Import["../../Tinyweb/Tinyweb.wl"]
Import["../../WSP/WSP.wl"]

server = WEBServer["addr" -> "127.0.0.1:5699", "path" -> "public"]
server // WEBServerStart
StringTemplate["Open your browser at http://``"][server["addr"]]//Print

While[True, Pause[1]];
