(* Mathematica source file *)
(* :Author: patrick *)
(* :Date: 6/28/13 *)

If[$VersionNumber < 9,
  Print[ "This works only in Mathematica version 9" ],
  With[{repoName = "Mathematica-SE-Tools-master"},
    Block[{url,
      zipFile = FileNameJoin[{$TemporaryDirectory, "master.zip" }],
      extractedDir = FileNameJoin[{$TemporaryDirectory, repoName }],
      file
    },

      url = "https://github.com/halirutan/Mathematica-SE-Tools/archive/master.zip";
      If[FileExistsQ[zipFile] || DirectoryQ[extractedDir] || FileNames["SETools", $Path] =!= {} || FileNames["SEUploader", $Path] =!= {},
        Print[ "Error, the following file/directory already exists. Please remove it and restart:" ];
        If[FileExistsQ[zipFile], Print[zipFile]];
        If[DirectoryQ[extractedDir], Print[extractedDir]];
        If[FileNames["SETools", $Path] =!= {}, Print[FileNames["SETools", $Path]]];
        If[FileNames["SEUploader", $Path] =!= {}, Print[FileNames["SEUploader", $Path]]];
        Abort[];
      ];

      file = URLSave[url, zipFile];
      If[Not[FileExistsQ[file]],
        Print[ "Couldn't download resource" ];
        Abort[];
      ];
      ExtractArchive[file, $TemporaryDirectory];
      CopyDirectory[FileNameJoin[{$TemporaryDirectory, repoName , "SETools" }],
        FileNameJoin[{$UserAddOnsDirectory, "Applications" , "SETools" }]];
      DeleteDirectory[FileNameJoin[{$TemporaryDirectory, repoName }], DeleteContents -> True];
      DeleteFile[file];
      Print[ "Please restart Mathematica to see the palette in the Palette menu" ]
    ]
  ]
]