Mathematica Tools for Stack Exchange
=====================

<img src="http://i.stack.imgur.com/e4yiN.png" align="right" Hspace="30" Vspace="10"/>

This *Mathematica* package provides tools to share images and source-code from within *Mathematica* notebooks directly with Stack Exchange. At its core is a palette, the *SE Uploader Palette*, that lets you access most of its current features. 

On the right, you see how the palette looks under Ubuntu Linux. The buttons give you access to the following features:

- The `Image` button lets you upload any selected graphics, cell, selected region as an image. 
- The `Image (pp)` does the same but uses a pixel perfect version. This is only available under Windows and Mac OSX
- The `Selected Cell` button works when you have selected one or more *cell brackets*. It will encode the *code* as an image and upload it to Stack Exchange. This image can then easily be decoded again and you get the exact same code on your local machine
- The `Selected Notebook` button works equivalently with the difference, that it will encode a whole notebook into an image

All upload buttons copy appropriate markdown-code in your clipboard after uploading the data so that you can directly paste it into your post at Stack Exchange. This will later be explained in detail.

##![Install Icon](http://i.imgur.com/ayLRwo3.png) Installation and Update

The palette should work on *Mathematica* versions >= 8.0.4 but it was mainly tested and developed under version 10.0.1. The installation is simple: Copy the `SETools` package directory into a location where *Mathematica* can find it. Usually this is the `Applications` directory in your `$UserBaseDirectory`. Just evaluate

    FileNameJoin[{$UserBaseDirectory, "Applications"}]

to see it. If there is an old installation of the `SETools` (or the older `SEUploader`), remove it. Please find detailed steps below.

###Automatic Installation for *Mathematica* 9 and above

We have set up [an installation script](https://raw.githubusercontent.com/halirutan/Mathematica-SE-Tools/master/SETools/Installer.m) that does all the steps, except deleting old installations, for you. If it finds an old installation, it will prompt you with the location and quit, so that you can remove the old installation. After removing the old files, just start it again and it will proceed through all the steps pointed out in the manual installation section. To start the installation script, simply call

    Import["http://goo.gl/rQtfHZ"]

After this, the palette should appear in the `Palettes` menu and be ready to use.

###Manual installation

####Removing old installations

Old installation packages can be found by simply searching directories in your `$Path`. 

    FileNames["SETools", $Path]
    FileNames["SEUploader", $Path]

Please remove old installation directories that appear after evaluating the commands above. You can use 

    DeleteDirectory[dir, DeleteContents -> True]

for that, but note that on Windows this might fail, because there, some files are locked when *Mathematica* is running. In this case, close *Mathematica* and do it manually using an explorer.

###Downloading, extracting and copying the current version

The easiest way is, to download the whole repository as zip file. Use [this master.zip](https://github.com/halirutan/Mathematica-SE-Tools/archive/master.zip) or click the *Download ZIP* on the right side on this page.

After you have downloaded the file extract it. If you have no tool for this on Windows, you could use the [free 7-Zip](http://7-zip.org/). Under Mac OSX and Linux this should work out of the box.

Inside the extracted directory, you will find a subdirectory `SETools` which has the following structure

    SETools/
    ├── FrontEnd
    │   └── Palettes
    │       └── SEUploader.nb
    ├── Installer.m
    ├── Java
    │   └── SETools.jar
    ├── Kernel
    │   └── init.m
    ├── Resources
    │   └── banner.png
    ├── SEImageExpressionDecode.m
    ├── SEImageExpressionEncode.m
    ├── SEUploader.m
    └── Version.m

Copy the whole `SETools` directory with all its content to your `Applications` folder under your `$UserBaseDiretory`. If everything is in place proceed to the next step.

###Finishing the installation

To make the palette appear, you can simply restart *Mathematica*. There is another possibility to rebuild the `Palette` menu which worked fine too in all my tests, but it might not be enough under Windows. Just evaluate

    FrontEndExecute[FrontEnd`ResetMenusPacket[{Automatic, Automatic}]]

##![doc image](http://i.stack.imgur.com/erf8e.png) Usage

To be continued...

##![bug image](http://i.stack.imgur.com/K4fGd.png) Troubleshooting

Basically the installation is nothing more than putting the package directory into a place where *Mathematica* expects packages and ensuring that there are not more than one installation, because otherwise different java `jar` libraries might conflict. If the palette does not appear, then either it is not in the right place or you need to restart *Mathematica*. 

If you get java-exceptions when you try to use the palette, then this can have 2 possible reasons. First, if the java-version is not correct, then you will see an error message like the following

    JLink`Java::excptn: "A Java exception occurred: java.lang.UnsupportedClassVersionError: de/halirutan/se/tools/SEUploader

In this case, the problem is my fault because I have compiled the used java code with a more recent java version that what is used by *Mathematica*. Once the `SETools` are thoroughly tested, this should not happen with supported *Mathematica* versions and I would be glad, when you report this to me.

Second, you get an exception of the form

    java.lang.ClassNotFoundException: de.halirutan.se.tools.SEUploader
Then, the java library `SETools.jar` is not in the java classpath and can not be found. Please ensure that the file `SETools.jar` is located in the package directory under

    Applications/SETools/Java/SETools.jar
in your `$UserBaseDirectory`.