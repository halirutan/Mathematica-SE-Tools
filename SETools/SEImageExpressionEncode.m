(* Mathematica Package         *)
(* Created by IntelliJ IDEA    *)

(* :Title: SEImageExpressionEncode     *)
(* :Context: SEImageExpressionEncode`  *)
(* :Author: patrick            *)
(* :Date: 22.03.15              *)

(* :Package Version: 1.0       *)
(* :Mathematica Version:       *)
(* :Copyright: (c) 2015 patrick *)
(* :Keywords:                  *)
(* :Discussion:                *)

BeginPackage["SEImageExpressionEncode`"];

SEEncodeExpression::usage = "SEEncodeExpression[] returns a button that can be used to encode the selected cell into an image. SEEncodeExpression[expr] can be used to directly encode expressions. Note, that arguments are evaluated! Therefore SEEncodeExpression[1+1] will encode 2.";

Begin["`Private`"];

SEEncodeExpression[] := Button["Encode selected cell",
  With[{expr = NotebookRead[SelectedNotebook[]]},
    If[expr =!= {},
      Print@SEEncodeExpression[expr]
    ]
  ]
];
SEEncodeExpression[expr_] := encodeExpression[expr];

With[{alpha = Image[Uncompress["1:eJzt2D0OwjAMBeAicREWZnoMJCaOwIDExNDeX3RFqOI5fk7yWi9WW+XHX6KkTU+P9/15HoZhOi7h9prm77vrYbm4bDumuH1GGxSPOxXjbvIIdS22jk2K24tH2IGXVBP/apAyKe5dvLZGkSc6YnxGkVopVhXjtXTEVpOm2Pr2RcZJX7xWMsVK4rIRUhN7st63WGev9meqI+ZmSnY3FuMnJZqbLC7Lq+wUqSyu2j5NHG2l9SUpdvVIFltXJ0tsaJkgtv6xwmPITAeK8bnhxlriiFohbpfY/+UcsZr/ZNVAXH9XZ4g7PQmmmCL255viyvEDfpsYpg=="], "Bit"]},
  SetAttributes[encodeExpression, {HoldFirst}];
  encodeExpression[expr_] :=
    Module[{pixel = ToCharacterCode[Compress[Unevaluated[expr]]], hash,
      l, nx, ny},
      hash = Prepend[ToCharacterCode[Compress[Hash[pixel]]], 0];
      pixel = Join[pixel, hash];
      l = Length[pixel];
      nx = Max[64, Ceiling[Sqrt[l]]];
      ny = Max[64, Ceiling[l / nx]];
      SetAlphaChannel[
        Image[ArrayPad[pixel, {0, nx * ny - l}] ~ Partition ~ nx, "Byte"],
        ImageResize[alpha, {nx, ny}, Resampling -> "Nearest"]
      ]
    ]
];

End[]; (* End Private Context *)

EndPackage[];

SEEncodeExpression[]