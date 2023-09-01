ATTENTION !!! WARNING !!! ATTENTION !!! WARNING !!! ATTENTION !!! WARNING
YOU MAY NOT WANT TO US IF YOU ARE PHOTOSENSITIVE TO FLASHING COLORS AND LIGHTS.



MIT License

Copyright (c) 2023 Tavis Baird

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

                             Glitchee Introduction

        Welcome to Glitchee this is a music visualizer, that reads the sound card inputs so
    you can set this to what ever system default you want it to be: microphone,line in,stereo mix,
    monitor Spotify if you wish.  It also uses 640x400 bmp images in 8 bit mode 256 color.
    You can add them to the Bmp/ direrctory, remove the ones I have placed if you wish.

    Hints:  -Use windows paint or something like that to convert your bmps to the 256 mode format.
            -adjust the volume will adjust the intensity.

       I made this as a basic simple example of how to get the byte data from the soundcard Using
       Openal.  I hope to see others make their version of a musical visualizer, I plan to implement
       Opengl soon as well.

       I Currently compiled this program using FPC (FREE PASCAL) COMPILER VERSION 3.2.2+dfsg-20

       All Units are part of the fpc units that come with the entire package, if it does not compile
       then you will need to use sysnaptics check that all packages are installed in linux for your fpc.
       It should compile and run in Windows if you have openAL installed on the system.  Although I
       have not tested it yet though.




files incluced in project.


LICENSE.txt    MIT license
readme.txt     this files
glitchee.pas   main program files
bmp3.pas       included bmp unit only using palette read.


