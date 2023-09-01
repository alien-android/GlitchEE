{$R-}
 Unit bmp3;
{
            This unit comes AS IS, very buggy code. may not dispaly 24 bmps
             I found this code on pascal swag, although it compiles when
            loading bmps it can load 8 bit 256 color bmps but they do not
            display correctly, I have modified the code so that
            readbmp is actually reading the palette to the screen.
            so you have to modify this code, maybe it still works in tp 7.0
            but I could never get this to display the bmps correctly in fpc
             Not sure how to liscence this... Im assuming its public domain... for this files source code.
             Im providing this because this is a modified version of this file.
             That works with the main program, I could easily incoporate this into the glitchee source code and may
             eventually be part of that, I just kept it seperate since it
             only being used to load bmps palette only.And I didnt make the code for this.

             €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
             €€€›‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ﬁ€€€±±
             €€€›€€                                      €€ﬁ€€€±±
             €€€›€€     Complete unit for BMP images     €€ﬁ€€€±±
             €€€›€€                                      €€ﬁ€€€±±
             €€€›€€           Aleksandar Dlabac          €€ﬁ€€€±±
             €€€›€€     (C)1995. Dlabac Bros. Company    €€ﬁ€€€±±
             €€€›€€    ------------------------------    €€ﬁ€€€±±
             €€€›€€      adlabac@urcpg.urc.cg.ac.yu      €€ﬁ€€€±±
             €€€›€€      adlabac@urcpg.pmf.cg.ac.yu      €€ﬁ€€€±±
             €€€›€€                                      €€ﬁ€€€±±
             €€€›ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬁ€€€±±
             €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€±±
               ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 }

   Interface

   Type BMPInfoType = Record
                        Width   : longint;
                        Height  : longint;
                        Colors  : longint;
                        Palette : array [0..255] of Record
                                                      Red   : byte;
                                                      Green : byte;
                                                      Blue  : byte
                                                    End
                      End;

   Procedure ReadBMP (x1,y1:integer;FileName : string);
   Function  BMPResult : integer;
   Function  BMPErrorMsg (ErrorCode : integer) : string;
   Procedure BMPInfo (var Info : BMPInfoType);

   Implementation

   Uses sysutils,ptcGraph;

   Const Rasters : array [0..15] of array [0..7] of byte =
         ((0,0,0,0,0,0,0,0),(128,0,8,0,128,0,8,0),(136,0,34,0,136,0,34,0),
          (168,0,42,0,138,0,42,0),(136,34,136,34,136,34,136,34),
          (168,136,42,34,168,136,42,34),(170,68,170,68,170,68,170,68),
          (170,85,170,85,170,85,170,85),(170,213,170,93,170,213,170,93),
          (85,187,85,187,85,187,85,187),(87,119,213,221,117,119,213,221),
          (119,221,119,221,119,221,119,221),(87,255,213,255,117,255,213,255),
          (119,255,221,255,119,255,221,255),(127,255,247,255,127,255,247,255),
          (255,255,255,255,255,255,255,255));

   { This rasters is used for mono image dithering. Whenever program
     determines that number of colors available is smaller than number of
     colors in picture, picture is shown in mono (1 color) dither. }

   Var B             : array [1..4] of byte;
       K             : byte;
       BMPError      : integer;
       I, J          : longint;
       I_,Colors        : longint;
       MaxColor      : longint;
       CoreHeader    : Boolean;
       BMPFileHeader : Record
                         BfType      : integer; { Signature "BM" ($4D $42) }
                         BfSize      : longint; { File size }
                         BfReserved1 : integer; { Reserved }
                         BfReserved2 : integer; { Reserved }
                         BfOffBits   : longint  { Data offset address: }
                       End;                     {    2 colors        $3E  }
                                                {   16 colors        $76  }
                                                {  256 colors       $436  }
                                                {  true color        $36  }

       BMPInfoHeader : Record
                         BiSize          : longint; { $28 - Header length in bytes }
                         BiWidth         : longint; { Picture width }
                         BiHeight        : longint; { Picture height }
                         BiPlanes        : word;    { Number of planes }
                         BiBitCount      : word;    { Bits per pixel }
                         BiCompression   : longint; { Compression type (0-none) }
                         BiSizeImage     : longint; { Picture size in bytes (can be 0 for no compression) }
                         BiXPelsPerMeter : longint;
                         BiYPelsPerMeter : longint;
                         BiClrUsed       : longint;
                         BiClrImportant  : longint
                       End;

       RGBColors : array [0..255] of Record
                                       RGBBlue     : byte;
                                       RGBGreen    : byte;
                                       RGBRed      : byte;
                                       RGBReserved : byte
                                     End;

   Procedure PutPix (X,Y,Col:longint);
     Var Pix       : byte;
         Intensity : real;
       Begin
        If (Y=0) and (Col<>255) then  Write ('');
         If X>getmaxx then x:=639;
         If Y>getmaxy then y:=399;
         If X>BMPInfoHeader.BiWidth-1 then Exit;
         If Y>BMPInfoHeader.BiHeight-1 then  Exit;
         If MaxColor<Colors-1 then
           With RGBColors [Col] do
             Begin
               Intensity:=0.299*RGBRed+0.587*RGBGreen+0.114*RGBBlue;
               Intensity:=Intensity/255;
               Pix:=Rasters [Round (Intensity*15)][Y and 7];
               Pix:=(Pix shr (X and 7)) and 1;
               PutPixel (X,Y,Pix);
             End
                              else
           PutPixel (X,Y,Col)
       End;

   Procedure ReadBMP (x1,y1:integer;FileName : string);
     Var F        : file;
         Size     : longint;
       Begin
         Assign (F,FileName);
{$I-}
         Reset (F,1);
{$I+}
         If IOResult<>0 then
           Begin
             BMPError:=1;
             Exit
           End;
         Size:=FileSize (F);
         If Size<246 then
           Begin
             BMPError:=2;
             Exit
           End;
         BlockRead (F,BMPFileHeader,14);
         If BMPFileHeader.BfType<>$4D42 then
           Begin
             BMPError:=4;
             Exit
           End;
         If Size<BMPFileHeader.BfSize then
           Begin
             BMPError:=2;
             Exit
           End;
         BlockRead (F,Size,4);
         CoreHeader:=Size=$0C;
         BMPInfoHeader.BiSize:=Size;
         If Size=$28 then
           BlockRead (F,BMPInfoHeader.BiWidth,$24)
                     else
           If Size=$0C then
             With BMPInfoHeader do
               Begin
                 BlockRead (F,BiWidth,8);
                 BiCompression:=0;
                 BiSizeImage:=0;
                 BiXPelsPerMeter:=0;
                 BiYPelsPerMeter:=0;
                 BiClrUsed:=0;
                 BiClrImportant:=0
               End
                       else
             Begin
               BMPError:=5;
               Exit
             End;
             {bmpinfoheader.bibitcount:=8;}
           Case BMPInfoHeader.BiBitCount of
             1  : Colors:=2;
             4  : Colors:=16;
             8  : Colors:=256;
             24 : Colors:=16777216;
             else
               Begin
                 BMPError:=6;
                 Exit
                End
             End;
       { bmpinfoheader.bibitcount:=24;
        colors:=16777216;}
       if GetGraphMode<0 then
           Begin
             BMPError:=7;
             Exit
           End;
         If Colors<=256 then
           For I:=0 to Colors-1 do
             Begin
               SetPalette (I,I);
               If Colors=2 then
                 With RGBColors [I] do
                   Begin
                     RGBBlue:=I*255;
                     RGBGreen:=I*255;
                     RGBRed:=I*255;
                     RGBReserved:=0
                   End
                           else
                 If CoreHeader then
                   Begin
                     BlockRead (F,RGBColors [I],3);
                     RGBColors [I].RGBReserved:=0
                   End
                               else
                   BlockRead (F,RGBColors [I],4);
                 With RGBColors [I] do
                   SetRGBPalette (I,RGBRed ,RGBGreen ,RGBBlue )   {ALL DIV 4}
             End;

         If GetMaxColor+1<Colors then
           MaxColor:=1
                                 else
           MaxColor:=GetMaxColor;
         If MaxColor=1 then
           Begin
             SetRGBPalette (0,0,0,0);
             SetRGBPalette (1,63,63,63)
           End;
         Seek (F,BMPFileHeader.BfOffBits);
         With BMPInfoHeader do
           For J:=399 downto 0 do {BIHEIGHT-1}
             Begin
               I_:=0;
                { SLEEP(1);}
                 Repeat
                   If Colors<=256 then
                     BlockRead (F,B [1],4)
                                  else
                     BlockRead (F,B [1],3);
                     Case BiBitCount of
                       1  : Begin
                             { K:=1;
                                Repeat
                                  If B [K] and $80>0 then
                                    PutPix (I_,J,1)
                                                     else
                                    PutPix (I_,J,0);
                                  Inc (I_);
                                  B [K]:=B [K] shl 1;
                                  If I_ mod 8=0 then Inc (K)
                                Until K=5}
                            End;
                       4  : For K:=1 to 4 do
                              Begin
                                {PutPix (I_,J,(B [K] and $F0) shr 4);
                                Inc (I_);
                                PutPix (I_,J,B [K] and $0F);
                                Inc (I_)}
                              End;
                       8  : for K:=1 to 4 do{4}
                              Begin
                               {PutPix (I_+x1,J+y1,B[K]);}
                                {putpixel(I_,J,B[K]);}
                                inc(I_);
                                {putpixel(I,j,b[k]);
                                Inc (I)}
                                End;
                       24 : {PutPix (I_,J,longint (B [3])*65536+B [2]*256+B [1]) }
                     End

                 Until I_>=639;  {BIWIDTH-1}
               If Colors>256 then
                 For K:=1 to (I_*3) and 3 do
                   BlockRead (F,B[1],1)
             End;
         BMPError:=0;

        close(F);
       End;

   Function BMPResult : integer;
     Begin
       BMPResult:=BMPError;
       BMPError:=0
     End;

   Function BMPErrorMsg (ErrorCode : integer) : string;
     Var Temp : string;
       Begin
           Case ErrorCode of
             0 : Temp:='No error';
             1 : Temp:='Error opening file';
             2 : Temp:='File too short';
             3 : Temp:='File not loaded';
             4 : Temp:='Not a BMP file';
             5 : Temp:='Invalid header';
             6 : Temp:='Invalid number of colors';
             7 : Temp:='Graphics mode not initialized';
             else Temp:='Unknown error'
           End;
         BMPErrorMsg:=Temp;
       End;

   Procedure BMPInfo (var Info : BMPInfoType);
     Var I : integer;
       Begin
         With Info do
           Begin
             Width:=0;
             Height:=0;
             Colors:=0;
             If BMPError=0 then
               With BMPInfoHeader do
                 Begin
                   Width:=BiWidth;
                   Height:=BiHeight;
                     Case BiBitCount of
                       1  : Colors:=2;
                       4  : Colors:=16;
                       8  : Colors:=256;
                       24 : Colors:=16777216;
                       else Colors:=0
                     End;
                   For I:=0 to Info.Colors-1 do
                     With Palette [I], RGBColors [I] do
                       Begin
                         Red:=RGBRed;
                         Green:=RGBGreen;
                         Blue:=RGBBlue
                       End
                 End
           End
       End;

     Begin
       BMPError:=3
     End.

{ ---------------------- Demo program ---------------------- }

Program LoadBMP;

  Uses Crt, Graph, BMP;

  Const VGA256 = False;

  Var Gd, Gm, Result    : integer;
      AutoDetectPointer : pointer;

{$F+}
  Function DetectCard:integer;
    Var DetectedDriver, SuggestedMode : integer;
      Begin
        DetectGraph (DetectedDriver,SuggestedMode);
        If (DetectedDriver=VGA) or (DetectedDriver=MCGA) then
          DetectCard:=grOk
                                                         else
          DetectCard:=grError
      End;
{$F-}

  Procedure InitGraph256;
    Var Gd, Gm, ErrorCode : integer;
      Begin
        AutoDetectPointer:=@DetectCard;
        Gd:=InstallUserDriver ('VGA256',AutoDetectPointer);
        If GraphResult<>grOk then
          Begin
            Writeln ('Error installing driver');
            Halt
          End;
        Gd:=Detect;
        InitGraph (Gd,Gm,'');
        ErrorCode:=GraphResult;
        If ErrorCode<>grOk then
          Begin
            Writeln ('Error: ',GraphErrorMsg (ErrorCode));
            Halt
          End
      End;

    Begin
      If VGA256 then
        InitGraph256
                    else
        Begin
          DetectGraph (Gd,Gm);
          InitGraph (Gd,Gm,'')
        End;
      ReadBMP ('\WINDOWS\TARTAN.BMP');
      Write (#7);
      Result:=BMPResult;
      If Result=0 then Repeat Until ReadKey<>'';
      CloseGraph;
      Writeln ('BMP status = ',BMPErrorMsg (Result))
    End.
