Plant::usage = "Execute code on the server and embedd the result on a page (plant a seed)"
Grow::usage = "Execute code on a client immediantely"


Plants = <||>

Plant[expr_] := With[{id = CreateUUID[]},
    Plants[id] = Global`FrontEndVirtual[{Global`AttachDOM[id], expr}];
    LoadPage["t/seed.wsp", {Global`uid = id}]
]

Grow[expr_] := With[{id = CreateUUID[]},
    session["Turnips"][id] = ExportString[Hold[expr], "ExpressionJSON", "Compact"->0];
    ""
]

SetAttributes[Grow, HoldFirst]

Hydrate[id_String] := With[{cli = Global`client},
    WebSocketSend[cli, Plants[id]];
    Plants[id] = .;
]
