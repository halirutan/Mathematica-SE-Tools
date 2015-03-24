(* Mathematica Package *)
(* :Context: SEUploader` *)
(* :Author: Szabolcs Horvat, changed by Patrick Scheibe *)
(* :Date: 6/27/13 *)
(* :Notes: The palette buttons are *wrapped* with Tooltip because in V8 a Button did not have the option Tooltip! *)

BeginPackage["SETools`SEUploader`"];

SEUploaderPalette::usage = "SEUploaderPalette[] shows the uploader palette.";

Begin[ "`Private`" ]; (* Begin Private Context *)

(* ::Package:: *)

SEUploaderPalette[] := CreateWindow[palette];


With[
  {
    version = Get["SETools`Version`"],
    logo = Import["SETools/Resources/banner.png"],
    mathematicaSE = "http://mathematica.stackexchange.com/",
    versionURL = "https://raw.githubusercontent.com/halirutan/Mathematica-SE-Tools/master/SETools/Version.m",

    tagLastCheck = "SEUploaderLastUpdateCheck",
    tagHistory = "ImageUploadHistory",

    buttonOpts = Sequence[ImageSize -> {140, Automatic}],

    $aboutDialog = Function[st, Column[
      {
        Import["SETools/Resources/banner.png"],
        st["This palette was developed to ease the uploading of Mathematica content to its dedicated stackexchange site. You can upload images of graphics, expressions and cells. To share code, it is possible to encode cells or whole notebooks into an image."],
        st["For more information, you can visit the following places:"],
        Hyperlink[st["\[FilledCircle] The official post at stackexchange"], "http://meta.mathematica.stackexchange.com/q/5/187"],
        Hyperlink[st["\[FilledCircle] The GitHub repository of this project"], "https://github.com/halirutan/Mathematica-SE-Tools"],
        st["\[Copyright] 2012\[Dash]2015 The StackExchange Community"]
      }, Dividers -> {False, {False, True}}, Spacings -> 1]][(Style[#, "Label", LineIndent -> 0, TextJustification -> 1.])&]

  },

  palette = PaletteNotebook[DynamicModule[{progress = False},
    Dynamic@Column[{
      logo,
      OpenerView[{Style["Uploading", "Text"],

        Column[{

          Tooltip[
            Button["Image", uploadButton[], buttonOpts],
            "Upload the selected expression as an image to StackExchange",
            TooltipDelay -> Automatic],


          Tooltip[Button["Image (pp)", uploadPPButton[], buttonOpts, Enabled -> ($OperatingSystem === "Windows" || ($OperatingSystem === "MacOSX" && $VersionNumber >= 9))],
            "Upload the selected expression as an image to StackExchange (pixel-perfect rasterization)", TooltipDelay -> Automatic],


          Tooltip[
            Button["Selected Cell", progress = True;uploadExpression[encodeSelection[]];progress = False;, buttonOpts, Method -> "Queued"],
            "Encode the selected cell(s) into an image to share code",
            TooltipDelay -> Automatic],

          Tooltip[
            Button["Selected Notebook", progress = True;uploadExpression[encodeCurrentNotebook[]];progress = False, buttonOpts, Method -> "Queued"],
            "Encode the selected notebook into an image to share code",
            TooltipDelay -> Automatic],

          Dynamic@If[progress,
            ProgressIndicator[ Appearance -> "Percolate"],
            Invisible[ProgressIndicator[ Appearance -> "Percolate"]]
          ]
        }, Center]
      }, True],

      OpenerView[{Style["Miscellaneous", "Text"],
        Column[{

          Tooltip[
            Button["History", historyButton[], buttonOpts], "See previously uploaded images and copy their URLs",
            TooltipDelay -> Automatic],


          Tooltip[
            Button[Dynamic@Style["Update", If[CurrentValue[$FrontEnd, {TaggingRules, "SEUploaderVersion"}, version] =!= version, RGBColor[0.8588235294117647, 0.00784313725490196, 0.00784313725490196] , Black]], updateButton[], buttonOpts],
            "Check for newer versions of the uploader palette",
            TooltipDelay -> Automatic],

          Tooltip[
            Button["About", MessageDialog[$aboutDialog], buttonOpts],
            "Check for newer versions of the uploader palette",
            TooltipDelay -> Automatic]

        }, Center]
      }, True]



    }, Dividers -> {None, {False, True}}, Spacings -> {Automatic, {0, 2, 0, 0}}],
  (* init start *)
    Initialization :>
      (
        Block[{$ContextPath}, Needs /@ {"JLink`", "SETools`SEImageExpressionEncode`"}];
        JLink`InstallJava[];

        (* always refers to the palette notebook *)
        pnb = EvaluationNotebook[];

        (* HELPER FUNCTIONS *)

        closeButton[] :=
          DefaultButton[ "Close" , DialogReturn[], ImageSize -> CurrentValue[ "DefaultButtonSize" ], ImageMargins -> {{2, 2}, {10, 10}}];

        (* VERSION CHECK CODE *)

        (* Update URLs *)


        (* check the latest version on GitHub *)
        checkOnlineVersion[] :=
          Module[{onlineVersion},
            Quiet@Check[
              onlineVersion = Import[versionURL],
              Return[$Failed]
            ];
            CurrentValue[$FrontEnd, {TaggingRules, tagLastCheck }] = AbsoluteTime[];
            CurrentValue[$FrontEnd, {TaggingRules, "SEUploaderVersion" }] = onlineVersion
          ];

        (* Check for updates on initialization if last check was > 3 days ago.
        The check will time out after 6 seconds. *)
        If[AbsoluteTime[] > 3 * 3600 * 24 + CurrentValue[$FrontEnd, {TaggingRules, tagLastCheck }, 0],
          TimeConstrained[checkOnlineVersion[], 6]
        ];

        updateButton[] :=
          Module[
            {
              res, newVersionQ, newVersionInformation,
              st = (Style[##, "Label", LineIndent -> 0, TextJustification -> 1.]) &
            },
            res = checkOnlineVersion[];
            newVersionInformation = CurrentValue[$FrontEnd, {TaggingRules, "SEUploaderVersion" }, version];
            newVersionQ = res =!= $Failed && newVersionInformation =!= version;

            CreateDialog[
              Pane[Column[{
                st["Update information", 14],
                st@StringTemplate["Installed version: ``"]["Version" /. version],

                If[res =!= $Failed,
                  st@StringTemplate["Online version: ``"]["Version" /. newVersionInformation],
                  st@"Update check failed.  Please check your internet connection."
                ],

                If[newVersionQ,
                  Column[
                    Join[{st["Changes in the new version:", Bold]}, st["\[FilledCircle] " <> #] & /@ ("Changes" /. newVersionInformation)]
                  ],
                  Unevaluated@Sequence[]
                ],

                Row[{
                  Hyperlink[st@"Open home page", "https://github.com/halirutan/Mathematica-SE-Tools"],
                  " | ",
                  Hyperlink[st@"History of changes", "https://github.com/halirutan/Mathematica-SE-Tools/commits/master"]
                }],

                Pane[If[newVersionQ,
                  ChoiceButtons[
                    {"Go to update page"},
                    { SystemOpen["https://github.com/halirutan/Mathematica-SE-Tools"]; DialogReturn[]}
                  ],
                  closeButton[]],
                  ImageSize -> 400,
                  Alignment -> Right
                ]},
                Dividers -> {None, {False, True, False}},
                Spacings -> {0, {Automatic, 2, Automatic, 1}
                }], ImageSize -> 400],

              WindowTitle -> "Update information"]
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
              JLink`LoadJavaClass[ "de.halirutan.se.tools.SEUploader" , StaticsVisible -> True];
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
            NotebookWrite[nb, Cell[text, "Input" ]];
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
                  CurrentValue[pnb, {TaggingRules, tagHistory }, {}],
                9, "" ], 3],
              Item[Row[{
                Spacer[200],
                Button[ "Clear all" , CurrentValue[pnb, {TaggingRules, tagHistory }] = {}, ImageSize -> CurrentValue[ "DefaultButtonSize" ]],
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

        uploadExpression[img_] := If[Head[img] =!= Image,
          MessageDialog["Invalid selection."],
          If[ByteCount[img] / 2.0^20 > 1.0,
            MessageDialog["Expressions bigger then 1 MB are not allowed."],
            uploadButtonAction[img, "Get[\"http://goo.gl/NaH6rM\"][\"", "\"]"]
          ]
        ];


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
            PrependTo[CurrentValue[pnb, {TaggingRules, tagHistory }],
              {Thumbnail@Image[img], url}];
            If[Length[CurrentValue[pnb, {TaggingRules, tagHistory }]] > 9,
              CurrentValue[pnb, {TaggingRules, tagHistory }] =
                Most@CurrentValue[pnb, {TaggingRules, tagHistory }]];
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

        encodeSelection[] := With[{expr = NotebookRead[SelectedNotebook[]]},
          If[MemberQ[Hold[{}, $Failed, NotebookRead[$Failed]], expr] || Not[Head[expr] === Cell || MatchQ[expr, {_Cell..}]],
            $Failed, (* there was nothing selected that we want to encode as image *)
            SETools`SEImageExpressionEncode`SEEncodeExpression[expr]
          ]];

        encodeCurrentNotebook[] := With[{nb = NotebookGet[SelectedNotebook[]]},
          If[Head[nb] =!= Notebook,
            $Failed,
            SETools`SEImageExpressionEncode`SEEncodeExpression[nb]
          ]
        ];

      )
  (* init end *)
  ],

    TaggingRules -> {tagHistory -> {}},
    WindowTitle -> "SE Uploader",
  (* Position the opening palette directly at mouse position *)
    WindowMargins -> Dynamic[Transpose[{CurrentValue[$FrontEnd, "MousePosition"], {Automatic, Automatic}}]]
  ]

];

End[];
EndPackage[];

