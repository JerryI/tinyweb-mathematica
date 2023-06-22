#!/usr/bin/env wolframscript
(* ::Package:: *)

(* ::Input:: *)

Import["../../Tinyweb/Tinyweb.wl"];
Import["../../WSP/WSP.wl"];

server = WEBServer["addr" -> "127.0.0.1:8080", "path" -> "public"];
server // WEBServerStart;

StringTemplate["Open your browser at http://``"][server["addr"]]//Print;

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