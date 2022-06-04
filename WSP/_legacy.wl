BeginPackage["WSP`"]


(* ::Section:: *)
(*Clear names*)


ClearAll["`*"]

LoadPage::usage = 
"LoadPage[filepath]"

AST::usage = 
"LoadPage[filepath]"

Process::usage = 
"LoadPage[filepath]"



LoadPage[p_, vars_:{}]:=
    Block[vars,
        With[{$filepath = If[StringQ[$publicpath], FileNameJoin[{$publicpath,  If[$OperatingSystem == "Windows", StringReplace[p,"/"->"\\"], p]}], If[$OperatingSystem == "Windows", StringReplace[p,"/"->"\\"], p]]}, 
            With[{stream = OpenRead[$filepath]},
                With[{result = Process@AST[stream, {}, "Simple"]},

                    Close[stream];
                    result
                ]
            ]
        ]
    ];

SetAttributes[LoadPage, HoldRest];

StringFix[str_]:=StringReplace[str,Uncompress["1:eJxTTMoPSmNiYGAoZgESQaU5qcGMQIYSmFQHAFYsBK0="]];
StringUnfix[str_]:=StringReplace[str,Uncompress["1:eJxTTMoPSmNiYGAoZgESQaU5qcGMQIY6mFQCAFZKBK0="]];

Begin["`Private`"]

(*replacement for web objects*)
webrules = {
                Graphics :> (ExportString[#, "SVG"] &@*Graphics),
                Graphics3D :> (ExportString[#, "SVG"] &@*Graphics3D)
           };

(*WARNING! CODE STYLE CAN CAUSE INSTANT DEATH*)



AST[s_, init_ : {}, "Simple"] := Module[
{code = init, text = "", c = "", exp = "", bra = 0, depth = 0, substream},
(*extract everything before {{*)
c = {Read[s, "Character"]};

If[TrueQ[Last@Flatten@c == EndOfFile], Return[Flatten@code, Module]];

text = "";
(*like in C style, probably it will be slower*)
While[True,
    c = {c, Read[s, "Character"]};

    If[TrueQ[Last@Flatten@c == EndOfFile], text = StringJoin@Drop[Flatten@c,-1]; Break[]];

    With[{str = StringJoin@Flatten@c},
        With[{position = StringPosition[str, "<?wsp"]},
            If[Length[position] > 0,
                text = StringTake[str, First@Flatten@position - 1];
                Break[];
            ];
        ];
    ];

    
];


text = StringTrim[text];
(*pure HTML text*)
If[text != "",
    code = {code, "HTML" -> text};
];

(*extract the WF expression*)
c = {""};
exp = "";

c = {c, Read[s, "Character"]};
While[True,
    c = {c, Read[s, "Character"]};

    If[TrueQ[Last@Flatten@c == EndOfFile], exp = ""; Break[]];



    With[{str = StringJoin@Flatten@c},
        With[{position = StringPosition[StringTake[str,-2], "?>"]},
            If[Length[position] > 0,
            
                If[bra == 0,
                    exp = StringTake[str, (First@Flatten@position + StringLength[str] - 2) - 1];
                    Break[];
                ,
                    depth ++;
                ];
            ];
        ];
    ];

    If[Last@Flatten@c == "[", bra++];
    If[Last@Flatten@c == "]", bra--];      
];

exp = StringTrim[exp];


If[depth > 0,
    substream = exp // StringToStream;
    code = {code, "MODULE" -> AST[substream, {}, "Module"]};
    Close[substream];
,
    If[exp != "",
        code = {code, "WF" -> exp};
    ];
];



(*for the rest of the code lines*)
If[TrueQ[Last@Flatten@c == EndOfFile],
    Flatten@code
    ,  AST[s, code, "Simple"]]

];


AST[s_, init_ : {}, "Module"] := Module[
{code = <||>, text = "", c = "", exp = "", bra = 0, depth = 0, substream, subsubstream, tail="", head=""},

c = "";
While[True,
    c = {c, Read[s, "Character"]};
 

    With[{str = StringJoin@Flatten@c},
        With[{position = StringPosition[str, "?>"]},
            If[Length[position] > 0,
                head = StringTake[str, First@Flatten@position - 1];
                Break[];
            ];
        ];
    ];   
];

code["HEAD"] = head;

substream = ReadString[s]//StringReverse//StringToStream;
c = "";

While[True,
    c = {c, Read[substream, "Character"]};


    With[{str = StringJoin@Flatten@c},
        With[{position = StringPosition[str, "psw?<"]},
            If[Length[position] > 0,
                tail = StringTake[str, First@Flatten@position - 1];
                Break[];
            ];
        ];
    ];   
];

code["TAIL"] = tail//StringReverse;

subsubstream = ReadString[substream]//StringReverse//StringToStream;
Close[substream];

code["BODY"] = AST[subsubstream, {}, "Simple"];

Close[subsubstream];

code

]

Parse[x_] := 
  x["HEAD"] <> 
   "{" <> (Switch[#[[1]], "HTML", "\"" <> #[[2]] <> "\"", 
        "WF", #[[2]], "MODULE", Parse@#[[2]]] <> "," & /@ 
     Drop[x["BODY"], -1]) <> (Switch[#[[1]], "HTML", 
       "\"" <> #[[2]] <> "\"", "WF", #[[2]], "MODULE", 
       Parse@#[[2]]] &@Last[x["BODY"]]) <> "}" <> x["TAIL"]

Process[x_] := 
  StringJoin@(ToString/@(
   Flatten@(Switch[#[[1]], "HTML", #[[2]], "WF", ReplaceAll[ToExpression@#[[2]], webrules], 
        "MODULE", ReplaceAll[ToExpression@Parse@#[[2]], webrules]] & /@ x)))

End[] (*`Private`*)


(* ::Section:: *)
(*End package*)


EndPackage[] (*JTP`*)