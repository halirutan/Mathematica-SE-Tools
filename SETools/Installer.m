(* Mathematica source file *)
(* :Author: patrick *)
(* :Date: 6/28/13 *)

With[
  {
    repositoryURL = "https://github.com/halirutan/Mathematica-SE-Tools/archive/master.zip",
    repositoryDir = "Mathematica-SE-Tools-master", (* This is fixed by GitHub which always names the ZIP content like this *)
    zipFileName = FileNameJoin[{$TemporaryDirectory, "master.zip" }]

  },
  Module[
    {
      extractedDir = FileNameJoin[{$TemporaryDirectory, repositoryDir }],
      existingFiles,
      zipFile,
      deleteQDialog,
      fetchURL
    },

    If[$VersionNumber < 9,
      Get["Utilities`URLTools`"];
      fetchURL = FetchURL,
      fetchURL = URLSave
    ];

    deleteQDialog[str_String] := With[{dirQ = DirectoryQ[str]}, ChoiceDialog[
      "The following " <> If[dirQ, "directory", "file"] <> " already exists:\n" <> str <> "\nDelete it?",
      {
        "Yes" :> Quiet@Check[
          If[dirQ, DeleteDirectory[str, DeleteContents -> True], DeleteFile[str]],
          MessageDialog["Error. Could not delete. Aborting"]; $Aborted],
        "No" :> $Aborted
      }]
    ];

    existingFiles = Select[Flatten[{zipFileName, extractedDir, FileNames[#, $Path]& /@ {"SETools", "SEUploader"}}], FileExistsQ];
    Do[
      If[deleteQDialog[f] === $Aborted,
        Print["Could not delete " <> f];
        Abort[]
      ], {f, existingFiles}
    ];

    zipFile = fetchURL[repositoryURL, zipFileName];
    If[Not[FileExistsQ[zipFile]],
      Print[ "Couldn't download resource" ];
      Abort[];
    ];
    ExtractArchive[zipFile, $TemporaryDirectory];
    CopyDirectory[FileNameJoin[{$TemporaryDirectory, repositoryDir , "SETools" }],
      FileNameJoin[{$UserAddOnsDirectory, "Applications" , "SETools" }]];
    DeleteDirectory[FileNameJoin[{$TemporaryDirectory, repositoryDir }], DeleteContents -> True];
    DeleteFile[zipFile];
    FrontEndExecute[FrontEnd`ResetMenusPacket[{Automatic, Automatic}]];

  ]
]
