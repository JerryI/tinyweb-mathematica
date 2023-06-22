Import["../../Tinyweb/Tinyweb.wl"]
Import["../../WSP/WSP.wl"]

Get["modules/Hydrator.wl"]
Get["modules/Events.wl"]

RandomWord[];

server = WEBServer["addr" -> "127.0.0.1:5699", "path" -> "public", "socket-close"->True]
server = server // WEBServerStart
StringTemplate["Open your browser at http://``"][server["addr"]]//Print

Get["modules/Polyfill.wl"]

Get /@ FileNames["server.wl", "public", Infinity];

While[True, Pause[1]];