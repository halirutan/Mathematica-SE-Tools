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

BeginPackage["SEImageExpressionDecode`"];

SEDecodeImage::usage = "SEDecodeImage[url] imports the expression encoded in the the image. Optionally, url can be a Mathematica image.";

Begin["`Private`"]; (* Begin Private Context *)

SEDecodeImage::imp = "Import of `` as png image failed.";
SEDecodeImage::hash = "The security hash indicates that the data is corrupted.";
SEDecodeImage[url_String] := Module[{img},
  Check[
    img = Import[url, "PNG"],
    Message[SEDecodeImage::imp, url];
    Abort[]
  ];

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
    hash =!= Compress[Hash[data]],
    Message[SEDecodeImage::hash];
    Abort[]
  ];
  Uncompress[FromCharacterCode[data], HoldComplete]
];

End[];
EndPackage[];

SEDecodeImage