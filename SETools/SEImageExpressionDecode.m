(* Created by IntelliJ IDEA    *)

(* :Title: ImageExpressionDecode     *)
(* :Context: ImageExpressionDecode`  *)
(* :Author: patrick            *)
(* :Date: 21.03.15              *)

(* :Package Version: 1.0       *)
(* :Mathematica Version: >= 9  *)
(* :Copyright: (c) 2015 patrick *)
(* :Keywords:                  *)
(* :Discussion:                *)

BeginPackage["SETools`SEImageExpressionDecode`"];

SEDecodeImageAndPrint::usage = "SEDecodeImageAndPrint[url] decodes the image in url without evaluating it. If the expression is a Cell or a list of cells, then it is printed. Otherwise the held form is returned.";
SEDecodeImage::usage = "SEDecodeImage[url] imports the expression encoded in the the image. Optionally, url can be a Mathematica image.";

Begin["`Private`"];

SEDecodeImageAndPrint[url_String] := SEDecodeImageAndPrint[SEDecodeImage[url]];
SEDecodeImageAndPrint[img_Image] := SEDecodeImageAndPrint[SEDecodeImage[img]];
SEDecodeImageAndPrint[expr : HoldComplete[_Cell | {_Cell..}]] := CellPrint @@ expr;
SEDecodeImageAndPrint[expr : HoldComplete[_Notebook]] := NotebookPut @@ expr;
SEDecodeImageAndPrint[expr : HoldComplete[__]] := expr;

SEDecodeImage::imp = "Import of `` as png image failed.";
SEDecodeImage::hash = "The consistency hash could not be verified. This indicates usually that either the expression " <>
    "was encoded with a different version of Mathematica or that the data is corrupted. You can wrap " <>
    "AbortProtect[..] around your call to ignore the warning and to proceed at your own risk.";
SEDecodeImage[url_String] := Module[{img},
  Check[
    img = Import[url, "PNG"],
    Message[SEDecodeImage::imp, url];
    Abort[]
  ];
  decodeExpression[img]
];
SEDecodeImage[img_Image] := decodeExpression[img];

decodeExpression[img_Image] := Module[
  {
    data = Flatten[ImageData[RemoveAlphaChannel[img], "Byte"]],
    hash
  },

  {data, hash} = data /. {d__, 0, h__, 0 ..} :> {{d}, {h}};
  If[
    hash =!= IntegerDigits[Hash[FromCharacterCode[data], "MD5"]],
    Message[SEDecodeImage::hash];
    Abort[]
  ];
  Uncompress[FromCharacterCode[data], HoldComplete]
];

End[];
EndPackage[];

SEDecodeImageAndPrint