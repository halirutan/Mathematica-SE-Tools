(* Mathematica Package *)
(* :Context: SEUploader` *)
(* :Author: Szabolcs Horvat, changed by Patrick Scheibe *)
(* :Date: 6/27/13 *)

BeginPackage["SEUploader`"];

SEUploaderPalette::usage = "SEUploaderPalette[] shows the uploader palette.";

Begin[ "`Private`" ]; (* Begin Private Context *)

(* ::Package:: *)

SEUploaderPalette[] := CreateWindow[palette];


With[{
  lversion = Get["SETools`Version`"],
  logo = Import[ "http://cdn.sstatic.net/mathematica/img/logo.png" ]
},

  palette = PaletteNotebook[DynamicModule[{},
    Dynamic@Row[{
      Hyperlink[Rotate[logo, Pi / 2], "http://mathematica.stackexchange.com/" ],
      Column[{
        Tooltip[
          Button[ "Upload Image" , uploadButton[], Appearance -> "Palette"],
          "Upload the selected expression as an image to StackExchange" ,
          TooltipDelay -> Automatic
        ],

        If[$OperatingSystem === "Windows" || ($OperatingSystem === "MacOSX" && $VersionNumber >= 9),

          Tooltip[
            Button[ "Upload Image (pp)" ,
              uploadPPButton[],
              Appearance -> "Palette"],
            "Upload the selected expression as an image to StackExchange\n(pixel-perfect rasterization)" , TooltipDelay -> Automatic],

          Unevaluated@Sequence[]
        ],

        Tooltip[
          Button[ "Upload Expression" , uploadButton[], Appearance -> "Palette"],
          "Upload the selected expression as an image to StackExchange" ,
          TooltipDelay -> Automatic
        ],

        Tooltip[
          Button[ "History..." , historyButton[], Appearance -> "Palette"],
          "See previously uploaded images and copy their URLs" , TooltipDelay -> Automatic]
      (**)
      (*,*)

      (*Tooltip[*)
      (*Button["Update...", updateButton[],*)
      (*Appearance -> "Palette",*)
      (*Background -> Dynamic@If[CurrentValue[$FrontEnd, {TaggingRules, "SEUploaderVersion"}, version]  =!= version,*)
      (*LightMagenta,*)
      (*Automatic]*)
      (*],*)
      (*"Check for newer versions of the uploader palette", TooltipDelay -> Automatic]*)
      }]
    }],
  (* init start *)
    Initialization :>
      (
        Block[{$ContextPath}, Needs[ "JLink`" ]];
        JLink`InstallJava[];

        (* always refers to the palette notebook *)
        pnb = EvaluationNotebook[];

        (* HELPER FUNCTIONS *)

        closeButton[] :=
          DefaultButton[ "Close" , DialogReturn[], ImageSize -> CurrentValue[ "DefaultButtonSize" ], ImageMargins -> {{2, 2}, {10, 10}}];

        (* VERSION CHECK CODE *)

        (* the palette version number, stored as a string *)
        version = lversion;

        (* Update URLs *)
        versionURL = "https://raw.githubusercontent.com/halirutan/SEUploaderApplication/master/Version";
        paletteURL = "https://raw.github.com/szhorvat/SEUploader/master/SEUploaderLatest.nb";

        (* check the latest version on GitHub *)
        checkOnlineVersion[] :=
          Module[{onlineVersion},
            Quiet@Check[
              onlineVersion = Import[versionURL, "Text" ],
              Return[$Failed]
            ];
            CurrentValue[$FrontEnd, {TaggingRules, "SEUploaderLastUpdateCheck" }] = AbsoluteTime[];
            CurrentValue[$FrontEnd, {TaggingRules, "SEUploaderVersion" }] = onlineVersion
          ];

        (* Check for updates on initialization if last check was > 3 days ago.
        The check will time out after 6 seconds. *)
        If[AbsoluteTime[] > 3 * 3600 * 24 + CurrentValue[$FrontEnd, {TaggingRules, "SEUploaderLastUpdateCheck" }, 0],
          TimeConstrained[checkOnlineVersion[], 6]
        ];

        onlineUpdate[] :=
          Module[{paletteSource, paletteExpression, paletteFileName, paletteDirectory},
            paletteSource = Import[paletteURL, "String" ];
            If[paletteSource === $Failed, Beep[]; Return[]];

            (* Validate notebook. If GitHub is down, we shouldn't replace a working palette
                  with the contents of an error page. *)
            Quiet@Check[paletteExpression = ImportString[paletteSource, { "Package" , "HeldExpressions" }], Beep[]; Return[]];
            If[Extract[paletteExpression, {1, 1, 0}] =!= Notebook, Beep[]; Return[]];

            paletteFileName = NotebookFileName[pnb];
            paletteDirectory = NotebookDirectory[pnb];
            NotebookClose[pnb];
            Export[paletteFileName, paletteSource, "String" ];
            FrontEndExecute[FrontEnd`ResetMenusPacket[{Automatic, Automatic}]];

            (* Note: FileNameTake is necessary to preserve the "PalettesMenuSettings",
                   which are tied to the file name as a string.  If using the full path,
                   the Front End will think we're opening a different palette and
                   will not apply the "PalettesMenuSettings" *)
            FrontEndTokenExecute[ "OpenFromPalettesMenu" , FileNameTake[paletteFileName]];
          ];

        updateButton[] :=
          Module[{res},
            res = checkOnlineVersion[];
            CreateDialog[
              Column[{
                StringForm[ "`1`\nInstalled version: `2`\n\n`3`" ,
                  If[res =!= $Failed,
                    "Online version: " <> ToString@CurrentValue[$FrontEnd, {TaggingRules, "SEUploaderVersion" }],
                    "Update check failed.  Please check your internet connection."
                  ],
                  version,
                  Row[{
                    Hyperlink[ "Open home page" , "http://meta.mathematica.stackexchange.com/a/32/12" ],
                    " | " ,
                    Hyperlink[ "History of changes" , "https://github.com/szhorvat/SEUploader/commits/master" ]
                  }]
                ],

                Pane[
                  If[res =!= $Failed
                    && CurrentValue[$FrontEnd, {TaggingRules, "SEUploaderVersion" }, version] =!= version
                    && FileNameSplit@NotebookDirectory[pnb] === Join[FileNameSplit[$UserBaseDirectory], { "SystemFiles" , "FrontEnd" , "Palettes" }],

                    ChoiceButtons[{ "Update to new version" }, {onlineUpdate[]; DialogReturn[]}],

                    closeButton[]
                  ],
                  ImageSize -> 340,
                  Alignment -> Right]
              }],

              WindowTitle -> "Version information"]
          ];



        (* IMAGE UPLOAD CODE *)

        (* stackImage uploads an image to SE and returns the image URL *)

        stackImage::httperr = "Server returned respose code: `1`";
        stackImage::err = "Server returner error: `1`";
        stackImage::parseErr = "Could not parse the answer of the server.";

        stackImage[g_] :=
          Module[
            {url, client, method, data, partSource, part, entity,
              code, response, error, result, parseXMLOutput},

            parseXMLOutput[str_String] := Block[{xml = ImportString[str, { "HTML" , "XMLObject" }], result},
              result =
                Cases[xml, XMLElement[ "script" , _, res_] :> StringTrim[res],
                  Infinity] /. {{s_String}} :> s;
              If[result =!= {} && StringMatchQ[result, "window.parent" ~~ __],
                Flatten@
                  StringCases[result,
                    "window.parent." ~~ func__ ~~ "(" ~~ arg__ ~~ ");" :> {StringMatchQ[func, "closeDialog"], StringTrim[arg, "\""]}],
                $Failed
              ]
            ];
            parseXMLOutput[___] := $Failed;

            data = ExportString[g, "PNG" ];

            JLink`JavaBlock[
              JLink`LoadJavaClass[ "de.halirutan.uploader.SEUploader" , StaticsVisible -> True];
              response = Check[SEUploader`sendImage[ToCharacterCode[data]],
                Return[$Failed]]
            ];

            If[response === $Failed, Return[$Failed]];
            result = parseXMLOutput[response];
            If[result =!= $Failed,
              If[TrueQ@First[result],
                Last[result],
                Message[stackImage::err, Last[result]];
                $Failed
              ],
              Message[stackImage::parseErr];
              $Failed
            ]
          ];

        (* PALETTE BUTTON ACTIONS AND HELPER FUNCTIONS *)

        (* Copy text to the clipboard.  Works on v7. *)
        copyToClipboard[text_] :=
          Module[{nb},
            nb = NotebookCreate[Visible -> False];
            NotebookWrite[nb, Cell[text, "Text" ]];
            SelectionMove[nb, All, Notebook];
            FrontEndTokenExecute[nb, "Copy" ];
            NotebookClose[nb];
          ];

        historyButton[] :=
          CreateDialog[
            Column[{
              Style[ "Click a thumbnail to copy its URL." , Bold],
              Dynamic@Grid@Partition[PadRight[
                Tooltip[
                  Button[#1, copyToClipboard[#2]; DialogReturn[], Appearance -> "Palette"],
                  #2, TooltipDelay -> Automatic] & @@@
                  CurrentValue[pnb, {TaggingRules, "ImageUploadHistory" }, {}],
                9, "" ], 3],
              Item[Row[{
                Spacer[200],
                Button[ "Clear all" , CurrentValue[pnb, {TaggingRules, "ImageUploadHistory" }] = {}, ImageSize -> CurrentValue[ "DefaultButtonSize" ]],
                Spacer[10],
                closeButton[]}
              ], Alignment -> Right]
            }],
            WindowTitle -> "History"];

        uploadButton[] :=
          With[{img = rasterizeSelection1[]},
            If[img === $Failed, Beep[], uploadWithPreview[img]]];

        uploadPPButton[] :=
          With[{img = rasterizeSelection2[]},
            If[img === $Failed, Beep[], uploadWithPreview[img]]];


        (* button from the upload dialog *)
        uploadButtonAction[img_] := uploadButtonAction[img, "![Mathematica graphics](" , ")" ];
        uploadButtonAction[img_, wrapStart_String, wrapEnd_String] :=
          Module[
            {url, markdown},
            Check[
              url = stackImage[img],
              Return[]
            ];
            markdown = wrapStart <> url <> wrapEnd;
            copyToClipboard[markdown];
            PrependTo[CurrentValue[pnb, {TaggingRules, "ImageUploadHistory" }],
              {Thumbnail@Image[img], url}];
            If[Length[CurrentValue[pnb, {TaggingRules, "ImageUploadHistory" }]] > 9,
              CurrentValue[pnb, {TaggingRules, "ImageUploadHistory" }] =
                Most@CurrentValue[pnb, {TaggingRules, "ImageUploadHistory" }]];
          ];

        (* returns available vertical screen space,
        taking into account screen elements like the taskbar and menu *)
        screenHeight[] := - Subtract @@
          Part[ScreenRectangle /. Options[$FrontEnd, ScreenRectangle], 2];

        uploadWithPreview[img_Image] :=
          CreateDialog[
            Column[{
              Style[ "Upload image to StackExchange network?\nThe URL/MarkDown will be copied to the clipboard." , Bold],
              Pane[
                Image[img, Magnification -> 1], {Automatic,
                Min[screenHeight[] - 140, 1 + ImageDimensions[img][[2]]]},
                Scrollbars -> Automatic, AppearanceElements -> {},
                ImageMargins -> 0
              ],
            (*
                    Two buttons, one which copies an url for the site Q&A and one for the
                    chat. The Chat and Site button only differ in the wrapper of the url.
                    For an answer/question (Site) you usually want it in the style
                    ![Mathematica graphics](http://i.stack.imgur.com/iYQnh.png) while
                    the Chat needs the pure url.
                  *)
              Item[
                ChoiceButtons[{ "Upload for site" , "Upload for chat" , "Close" },
                  {uploadButtonAction[img]; DialogReturn[],
                    uploadButtonAction[img, "" , "" ]; DialogReturn[],
                    DialogReturn[]
                  }],
                Alignment -> Right
              ]
            }],
            WindowTitle -> "Upload image to StackExchange?"
          ];

        (* Multi-platform, fixed-width version.
            The default max width is 650 to fit StackExchange *)
        rasterizeSelection1[maxWidth_ : 650] :=
          Module[{target, selection, image},
            selection = NotebookRead[SelectedNotebook[]];
            If[MemberQ[Hold[{}, $Failed, NotebookRead[$Failed]], selection],

              $Failed, (* there was nothing selected *)

              target = CreateDocument[{}, WindowSelected -> False, Visible -> False, WindowSize -> maxWidth];
              NotebookWrite[target, selection];
              image = Rasterize[target, "Image" ];
              NotebookClose[target];
              image
            ]
          ];

        (* Windows-only pixel perfect version *)
        rasterizeSelection2[] :=
          If[
            MemberQ[Hold[{}, $Failed, NotebookRead[$Failed]], NotebookRead[SelectedNotebook[]]],

            $Failed, (* there was nothing selected *)

            Module[{tag},
              FrontEndExecute[FrontEndToken[FrontEnd`SelectedNotebook[], "CopySpecial" , If[$OperatingSystem === "Windows", "MGF" , "TIFF" ]]];
              Catch[
                NotebookGet@ClipboardNotebook[] /.
                  r_RasterBox :>
                    Block[{},
                      Throw[Image[First[r], "Byte" , ColorSpace -> "RGB"], tag] /;
                        True];
                $Failed,
                tag
              ]
            ]
          ];

        (* Encode Selected Expression as Image *)
        (* To not mess with the uploader preview, we will make the image a square by padding with zeroes. *)
        (* Due to the PNG compression it should not matter much *)
        SetAttributes[encodeExpressionAsImage, {HoldFirst}];
        encodeExpressionAsImage[expr_] := Module[{dim, pixel = ToCharacterCode[Compress[Unevaluated[expr]]]},
          dim = Ceiling[Sqrt[Length[pixel]]];
          Image[ArrayPad[pixel, {0, dim^2 - Length[pixel]}] ~ Partition ~ dim, "Byte"]
        ];

      )
  (* init end *)
  ],

    TaggingRules -> {"ImageUploadHistory" -> {}},
    WindowTitle -> "SE Uploader"
  ]

];

End[]; (* End Private Context *)

EndPackage[];

(* TestImage *)
(*Image[Partition[Append[Tuples[{0, 255}, 3], {0, 0, 0}], 3]] *)
