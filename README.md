Mathematica Tools for Stack Exchange
=====================

<img src="http://i.stack.imgur.com/e4yiN.png" align="right" Hspace="30" Vspace="10"/>

This *Mathematica* package provides tools to share images and source-code from within *Mathematica* notebooks directly with Stack Exchange. At its core is a palette, the *SE Uploader Palette*, that lets you access most of its current features. 

On the right, you see how the palette looks under Ubuntu Linux. The buttons give you access to the following features:

- The `Image` button lets you upload any selected graphics, cell, selected region as an image. 
- The `Image (pp)` does the same but uses a pixel perfect version. This is only available under Windows and Mac OSX
- The `Selected Cell` button works when you have selected one or more *cell brackets*. It will encode the *code* as an image and upload it to Stack Exchange. This image can then easily be decoded again and you get the exact same code on your local machine
- The `Selected Notebook` button works equivalently with the difference, that it will encode a whole notebook into an image

All upload buttons copy appropriate markdown-code, URL's or *Mathematica snippets into your clipboard after uploading the data, so that you can directly paste it into your Stack Exchange post.

---
**Navigation**

- [Detailed Usage](#-detailed-usage)
	- [Uploading Images](#uploading-images)
	- [Uploading Code Cells and Notebooks](#uploading-code-cells-and-notebooks)
		- [Background Information](#background-information)
		- [How Decoding works](#how-decoding-works)
		- [Limitations and Security](#limitations-and-security)
- [Installation and Update](#-installation-and-update)
	- [Automatic Installation for *Mathematica* 9 and above](#automatic-installation-for-mathematica-9-and-above)
	- [Manual Installation](#manual-installation)
- [Troubleshooting](#-troubleshooting)
- [Contact](#-contact)

---



##![doc image](http://i.stack.imgur.com/erf8e.png) Detailed Usage

###Uploading Images

You can upload not only *Mathematica* graphics and plots. The image upload lets you basically turn almost every selected cell, cell-group or region into an image. Here, I will describe the two most use-cases. First, when you want to share a graphics you have created with e.g. `Plot3D`, the first step is to select the final graphics by clicking on it

![Input Plot](http://i.stack.imgur.com/ZbEHj.png)

Note the orange frame around the graphic in the image above, which indicates, that the graphic is selected. After that, simply click on `Image` in the Uploader-palette and a preview dialogue will pop up that looks like this

![upload preview](http://i.stack.imgur.com/1jnGB.png)

You buttons for uploading an image either for usage in [a Stack Exchange Chat room](http://chat.stackexchange.com/rooms/2234/wolfram-mathematica) or for direct usage in an answer or question. Both buttons upload the image to the exact same server and the difference of those two buttons is the following:

- *Upload for chat* will simply copy the URL of the image into your clipboard. So when you press <kbd>Ctrl</kbd>+<kbd>V</kbd> after uploading the image, you will get something like `http://i.stack.imgur.com/1jnGB.png`. In a Stack Exchange chat-room, you can insert images (that are indeed displayed as images and not as links) by posting a message that consists of a valid image URL.
- *Upload for site* will give you the complete markdown code that is required to insert an image into a Stack Exchange answer/question. What you insert with <kbd>Ctrl</kbd>+<kbd>V</kbd> will look like this:
`![Mathematica graphics](http://i.stack.imgur.com/M4zAO.png)` and it will be displayed as the following image in a markdown page

![Mathematica graphics](http://i.stack.imgur.com/M4zAO.png)

###Uploading Code Cells and Notebooks

For uploading code there are two buttons on the palette. The <kbd>Selected Cell</kbd> button lets you upload the code currently selected cell. When you have selected several cells, all of them are uploaded. So when you are working in a notebook, simply select the cell-brackets you want to share (note the blue selection at the right)

![upload code](http://i.stack.imgur.com/n8fat.png)

When you click on <kbd>Selected Cell</kbd> you will see a small progress-indicator in the palette that vanishes when the upload is finished. After this, you have a very small *Mathematica* code snipped in your clipboard that you can share:

    Import["http://goo.gl/NaH6rM"]["http://i.stack.imgur.com/9nBGT.png"]

Anyone who evaluates the above line will get have your selected code cells inserted into his notebook. 

Using the <kbd>Selected Notebook</kbd> button works similar. Just click in the notebook you want to share so that it is selected. Then press the <kbd>Selected Notebook</kbd> button and wait until the upload is complete.

**Memory Limitation:** Note that there is a limit of 1MB for uploading cells or notebooks!

####Background Information
This section is probably a bit confusing, so let me explain this in more detail. You have to understand, that we *always upload images*, because this is the only thing that Stack Exchange allows us to do. By the way, we do not really upload the images to a *Stack Exchange server*, as you might have guessed when looking at the URL. Stack Exchange has some agreement with [imgur.com](http://imgur.com/) which is a pretty famous image sharer and all the images you insert in a post are hosted there.

The possibility to insert images is pretty nice, but what if you need to share a large expression, that is too large to include it as code-block in an answer? Or you want to share a cell with fancy formatting? Or you want to share a whole Notebook with titles, sections, text, code, etc? You *could* post a screenshot of this, but then no one can edit your code.

There is a solution: What if we forget for one moment, that an image consists of pixels that represent colours in an rectangle? Then we are dealing with a matrix of numbers. Fortunately,  a *Mathematica* cell or a notebook is from the computers point of view only an array of bytes, which can be represented as numbers too. Wouldn't it be possible to simply turn *Mathematica* cells or notebooks into a list of numbers and store them as *blind passengers* in an image? Well, yes this is possible and it is exactly how we will do it.

When you use the `Selected Cell` or the `Selected Notebook` button, the *Mathematica* expression behind your selection is turned into numbers that are used as pixel of an image.

####How Decoding works

As seen above, the short *Mathematic* snippet that decodes an uploaded code-expression has the form

    Import["http://goo.gl/NaH6rM"]["http://i.stack.imgur.com/9nBGT.png"]

This call consists of two parts. The first part `Import["http://goo.gl/NaH6rM"]` does nothing more than to load the [online version of the `SEImageExpressionDecode` package](http://goo.gl/NaH6rM). The short URL simply points to the package file in this repository. This package-loading call simply returns the `SEDecodeImageAndPrint` function which is then applied to the  `"http://i.stack.imgur.com/9nBGT.png"` argument. 

If you have the `SETools` installed on your local system, the encoding- and decoding-functions are directly accessible. With them, you can not only encode cells or notebooks, you can encode any expression you want!

    << SETools`
    img = SEEncodeExpression[Expand[(x + y)^10]]
    SEDecodeImage[img]

With this, you encode anything you like (without size-limit!) and send this image, for instance in a mail.

<img src="http://i.stack.imgur.com/9nBGT.png" align="right" width="128" height="128" Hspace="30" Vspace="10"/>

Btw, it should be noted that uploaded expressions are still images and can be viewed like normal ones. The above image looks like the one on the right. To make it better visible that those images include encoded expressions, they will always look like the [Wolfram Wolf](http://reference.wolfram.com/language/ref/character/Wolf.html). The wolf is overlaid as alpha-channel and the encoded data is in the background. When you watch closely, you see randomly looking grey-values in the wolf's ears. 

####Limitations and Security

There are several limitations when the SE-Uploader Palette is used. First of all, there is a size-limit for uploading expressions of currently 1MB. This size limit has its origin in the behaviour of the Stack Exchange image uploading procedure. Every image that is larger than 1MB is automatically converted into a jpeg image which have the property of *lossily* compressing images. When the palette encodes the image, it uses PNG which has a *lossless* compression, so that every single byte can be reconstructed. By converting an image into a jpeg, the encoded *Mathematica* expression is lost forever. Therefore, we reject encodings that exceed the size-limit.

The palette lets you only encode selected cells and notebooks. It won't work, if you select a small region inside your code. Nevertheless, with the palette installed, you can load the `SETools` package and encode any expression you like as shown above.

Note that the `SEEncodeExpression` function evaluates its arguments before encoding! Therefore, the following

    SEEncodeExpression[1 + 1]

will encode the expression `2` and not the expression `1+1`. You can use `Unevaluated[1+1]` to prevent the evaluation.

Finally, the decoding functions will (except heads `Cell` and `Notebook`) always return its result in unevaluated form. This is mainly for security reasons. Therefore, make sure that you always use the proper decoding function from this very package. The short URL in the decoding snipped **`goo.gl/NaH6rM`** is very convenient, but if you are in doubt, then always check that you have the correct link that leads to this repository. Or, and this is an even better solution, just use your local package for decoding:

    Get["SETools`SEImageExpressionDecode`"]["http://i.stack.imgur.com/9nBGT.png"]


##![Install Icon](http://i.imgur.com/ayLRwo3.png) Installation and Update

The palette should work on *Mathematica* versions >= 8.0.4 but it was mainly tested and developed under version 10.0.1. The installation is simple: Copy the `SETools` package directory into a location where *Mathematica* can find it. Usually this is the `Applications` directory in your `$UserBaseDirectory`. Just evaluate

    FileNameJoin[{$UserBaseDirectory, "Applications"}]

to see it. If there is an old installation of the `SETools` (or the older `SEUploader`), remove it. Please find detailed steps below.

###Automatic Installation for *Mathematica* 9 and above

We have set up [an installation script](https://raw.githubusercontent.com/halirutan/Mathematica-SE-Tools/master/SETools/Installer.m) that does all the steps, except deleting old installations, for you. If it finds an old installation, it will prompt you with the location and quit, so that you can remove the old installation. After removing the old files, just start it again and it will proceed through all the steps pointed out in the manual installation section. To start the installation script, simply call

    Import["http://goo.gl/rQtfHZ"]

After this, the palette should appear in the `Palettes` menu and be ready to use.

###Manual Installation

####Removing old Installations

Old installation packages can be found by simply searching directories in your `$Path`. 

    FileNames["SETools", $Path]
    FileNames["SEUploader", $Path]

Please remove old installation directories that appear after evaluating the commands above. You can use 

    DeleteDirectory[dir, DeleteContents -> True]

for that, but note that on Windows this might fail, because there, some files are locked when *Mathematica* is running. In this case, close *Mathematica* and do it manually using an explorer.

###Downloading, Extracting and Copying the New Version

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

###Finishing the Installation

To make the palette appear, you can simply restart *Mathematica*. There is another possibility to rebuild the `Palette` menu which worked fine too in all my tests, but it might not be enough under Windows. Just evaluate

    FrontEndExecute[FrontEnd`ResetMenusPacket[{Automatic, Automatic}]]


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

##![contact team](http://i.stack.imgur.com/tCbmW.png) Contact

If you find bugs or have any other questions, please [create a new issue](https://github.com/halirutan/Mathematica-SE-Tools/issues) in the bug-tracker. Additionally, you can always ask in the [*Mathematica* chat](http://chat.stackexchange.com/rooms/2234/wolfram-mathematica) at Stack Exchange.

Many thanks go to [Szabolcs Horvát](https://github.com/szhorvat), who implemented and maintained the first version of the [SE-Uploader](https://github.com/szhorvat/SEUploader)!
