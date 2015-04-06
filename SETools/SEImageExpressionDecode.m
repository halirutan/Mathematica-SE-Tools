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
SEDecodeImageAndPrint[expr : HoldComplete[_Cell | {_Cell..}]] := CellPrint @@ expr;
SEDecodeImageAndPrint[expr: HoldComplete[_Notebook]] := NotebookPut@@expr;
SEDecodeImageAndPrint[expr: HoldComplete[__]] := expr;

SEDecodeImage::imp = "Import of `` as png image failed.";
SEDecodeImage::hash = "The security hash indicates that the data is corrupted. Use AbortProtect[SEDecodeImage[...]] to ignore the warning and to proceed at your own risk.";
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
  hash = FromCharacterCode[hash];
  If[
    hash =!= Compress[Hash[data, "MD5"]],
    Message[SEDecodeImage::hash];
    Abort[]
  ];
  Uncompress[FromCharacterCode[data], HoldComplete]
];

End[];
EndPackage[];

SEDecodeImageAndPrint