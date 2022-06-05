#!/usr/bin/env wolframscript
(* ::Package:: *)

(* ::Input:: *)

Import["https://raw.githubusercontent.com/JerryI/tinyweb-mathematica/master/Tinyweb/Tinyweb.wl"];
Import["https://raw.githubusercontent.com/JerryI/tinyweb-mathematica/master/WSP/WSP.wl"];

server = WEBServer["addr" -> "137.250.85.38:80", "path" -> "public", "socket-close" -> True];
server // WEBServerStart;

UpdateInput[
   string_] := (WebSocketBroadcast[server, SetInput[string], client]);
ping = SessionSubmit[
  ScheduledTask[WebSocketBroadcast[server, Pong[]], 
   Quantity[5, "Seconds"]]];

clocks = SessionSubmit[ScheduledTask[WebSocketBroadcast[server, 
    
    With[{
      hr = Now[[1, 4]] 180/12 // N,
      mn = Now[[1, 5]] 180/60 // N,
      sc = Now[[1, 6]] 180/60 // N
      },
     SetClock[hr, mn, sc]
     ]
    
    ], Quantity[1, "Seconds"]]];

While[True,
    Pause[1];
];