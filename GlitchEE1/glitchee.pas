program glitchee;
{$mode objfpc}

{
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

}



uses   {objfpc}
  cthreads,crt,sysutils, openal,ptcgraph,
  fpimage, fppixlcanv, fpquantizer, fpditherer,
  fpreadbmp,bmp3;
const
  Seconds = 1;                           //- We'll record for 5 seconds
  Frequency = 22050; {8000}                      //- Recording a frequency of 8000
  Format = AL_FORMAT_MONO16;              //- Recording 16-bit mono
  BufferSize = 4000; {(Frequency*2)*(Seconds+1);} //- (frequency * 2bytes(16-bit)) * seconds
var
  names_files : array[0..1024] of shortstring;{rawbytestring;}
  info:tsearchRec;
  pCaptureDevice: pALCDevice;                  //- Device used to capture audio
  CaptureBuffer: array[0..BufferSize] of ALubyte; //- Capture buffer external from openAL, sized as calculated above for 5 second recording
  CaptureBuffer2: array[0..BufferSize] of Alubyte;
  PlayBuffer: ALInt;                           //- openAL internal playback buffer
  oldy: array[0..640] of integer;
  //- These two are used to control when to begin/end recording and playback
  Samples: ALInt;                //- count of the number of samples recorded

  num:longint;
  znum:longint;
  num_capture:longint;
  cnt:longint;
cnt_b, nmz, x,y,snd_avg:integer;
  readsnd2:byte;
 {getbeat:boolean;}
 oldavg_snd:byte;
xc,yc,tmpnum, avgsound:integer;
  gd,gm:smallint;
  current_page:shortint;
  maxfiles_,numz3:integer;


procedure recordinput;
begin
 num:=0;
 {inc(num_capture);}
{ repeat}
    alcGetIntegerv(pCaptureDevice, ALC_CAPTURE_SAMPLES, ALsizei(sizeof(ALint)), @samples);
 { Writeln(IntToStr(samples)+'/'+IntToStr(Seconds*Frequency)+' samples');}
  {if num <=16 then begin}
                  { writeln(num ,' num  ', capturebuffer2[num],' Captures : ',num_capture);}

                  { snd_avg:=snd_avg+capturebuffer2[num] div 2;
                   if capturebuffer2[num] > snd_avg+10 then clrscr;
                   gotoxy(capturebuffer2[num] div 4+1, capturebuffer[num] div 6+1);
                   textcolor(capturebuffer2[num] div 16);
                   write('#');
                   }
                    {readsnd2:=capturebuffer2[cnt]}
{                   end;
  inc(num);
   if num > 16 then num:=17;} {17}
  { until samples>=16;} {samples>= seconds*frequency;}
  //- Capture the samples into our capture buffer
  alcCaptureSamples(pCaptureDevice, @CaptureBuffer, samples);

          {for znum:=0 to 128 do   begin
                          capturebuffer2[znum]:=capturebuffer[znum];
                          writeln(znum,' num ',capturebuffer[znum],' ');
                         end; }
          {znum:=0;
          repeat
          capturebuffer2[znum]:=capturebuffer[znum];}
         {if znum=cnt then readsnd2:=capturebuffer2[cnt];}
         { inc(znum);
          until znum>=16;}
          {sleep(random(3));}
          end;

  function readsnd: byte;
 begin
{if cnt=0 then recordinput;}
{readsnd:=readsnd2;
inc(cnt);
if cnt >=64 then cnt:=0;}
readsnd:=capturebuffer[cnt];
inc(cnt);
if cnt >= 2000 then begin    {using 16 instead tooo fast}

                                recordinput;
                                {sleep(1);}
                                cnt:=0;
                                end;
end;


function getbeat: boolean;
begin
      if abs (readsnd-127) >=abs((avgsound-127)+80) then getbeat:=true
                                                    else getbeat:=false;
end;


procedure clr_oss;
var
x1,y1:integer;
begin
setcolor(0);
bar(0,0+100,639,128+100);
end;


procedure DisplayImage(AFileName: String; XPos, YPos, NumColors: Integer);
var
  srcImg: TFPMemoryImage;
  destImg: TFPMemoryImage;

  procedure ReduceColors;
  var
    quantizer: TFPColorQuantizer;
    ditherer: TFPFloydSteinbergDitherer;
    palette: TFPPalette;
    color: TFPColor;
    i: Integer;
  begin
    // Create image for destination bitmap
    destImg := TFPMemoryImage.Create(srcImg.Width, srcImg.Height);

    // Create a palette from the source image
    quantizer := TFPMedianCutQuantizer.Create;
    quantizer.ColorNumber := NumColors;
    quantizer.Add(srcImg);
    palette := quantizer.Quantize;

    // Copy the created palette to the screen
    {for i := 0 to palette.Count-1 do
    begin
      color := palette.Color[i];
      SetRGBPalette(i, color.Red shr 8, color.Green shr 8, color.Blue shr 8);
    end;}

    // Replace image colors by nearest palette colors
   { ditherer := TFPFloydSteinbergDitherer.Create(palette);
    ditherer.Dither(srcImg, destImg);}
  end;

var
  x, y: Integer;
begin
  // Load the image file
  srcImg := TFPMemoryImage.Create(0, 0);
  srcImg.LoadFromFile(AFileName);

  // Adjust colors
  ReduceColors;
   readbmp(xpos,ypos,Afilename);   {loads bmp undithered :P grabs palette i want undithered}
  // Draw the (color-reduced) bitmap
  for y := 0 to srcImg.Height-1 do
    for x := 0 to srcImg.Width-1 do
      PutPixel(XPos+x, YPos+y, srcImg.Pixels[x,y]); {was destImg for dithering reductionof palette}

  // Clean-up
  destImg.Free;
  srcImg.Free;
end;




Procedure circle_(x,y,r:real);
  var temp:real;
      x0,y0:word;

  begin
  x := (-1) * R;  { go from 0 - R to 0 }
  temp := R * R;
    Repeat
        y := sqrt(temp - (x * x));
       if (x0+(trunc(x)) >=0) and (y0-trunc(y) >=0) and (x0+trunc(x) <= 639) and (y0 -trunc(y) <=339) then putpixel((x0 + trunc(x)), (y0 - trunc(y)), readsnd); { 4.th quadrant }
       if (x0-(trunc(x)) >=0) and (y0-trunc(y) >=0) and (x0-trunc(x) <= 639) and (y0 -trunc(y) <=339) then putpixel((x0 - trunc(x)), (y0 - trunc(y)), readsnd); { 1.st quadrant }
       if (x0+(trunc(x)) >=0) and (y0+trunc(y) >=0) and (x0+trunc(x) <= 639) and (y0 +trunc(y) <=339) then putpixel((x0 + trunc(x)), (y0 + trunc(y)), readsnd); { 3.rd quadrant }
       if (x0-(trunc(x)) >=0) and (y0+trunc(y) >=0) and (x0-trunc(x) <= 639) and (y0 +trunc(y) <=339) then putpixel((x0 - trunc(x)), (y0 + trunc(y)), readsnd); { 2.nd quadrant }
        x := x + 0.1; { change this if you want coarse or fine circle. }
    Until (x >= 0.0);
  end;



procedure scr_rnd_snd1;
var
x_,y_:integer;
clr_avg:integer;
clr1,clr2,clr3:byte;
r3,g3,b3,r1,r2,g2,g1,b1,b2:smallint;
clr_r_avg,clr_b_avg,clr_g_avg:smallint;
begin
x_:=0;
y_:=0;
repeat
inc(x_);
repeat
clr1:=getpixel(x_,y_);
getrgbpalette(clr1,r1,g1,b1);
if y_+1 <=399 then clr2:=getpixel(x_,y_+1)
               else clr2:=readsnd;
getrgbpalette(clr2,r2,g2,b2);
if y_+1 <=399 then clr3:=getpixel(x_,y_+1)
               else clr3:=readsnd;
getrgbpalette(clr3,r3,g3,b3);
clr_avg:=(clr1+clr2+clr3) div 3;
clr_r_avg:=(r1+r2+r3+readsnd) div 4;
clr_g_avg:=(g1+g2+g3+readsnd) div 4;
clr_b_avg:=(b1+b2+b3+readsnd) div 4;
IF CLR1>0 THEN setrgbpalette(clr1,clr_r_avg,clr_g_avg,clr_b_avg)
          ELSE SETRGBPALETTE(CLR1,0,0,0);

if (x_+1 >=639) and (y_+1>=399) then putpixel(x_+1,y_+1,abs(255-(clr_avg+random(clr_avg)) div 2));
putpixel(x_,y_,abs(255-clr_avg));
inc(y_);
until y_>=399;
y_:=0;
until x_ >= 639;
end;

PROCEDURE pop;
   var num:integer;
   begin
   num:=0;
   repeat
   inc(num);
   setrgbpalette(num,readsnd,readsnd,readsnd);
   if num>255 then num:=255;
   until num=255
   end;

procedure fadeout;
var num:byte;
 r,g,b:smallint;
begin
num:=0; {keep black ?}
repeat
inc(num);
getrgbpalette(num,r,g,b);

{if readsnd < 127 then r:=(r+readsnd+random(readsnd)) div 3;
if readsnd > 127 then g:=(g+readsnd+random(readsnd)) div 3;
if readsnd > 127 then b:=(b+readsnd+random(readsnd)) div 3;
if r=0 then r:=abs(255-(32+random(readsnd div 8)));
if g=0 then g:=abs(255-(32+random(readsnd div 8)));
if b=0 then b:=abs(255-(32+random(readsnd div 8)));}

{r:=r-1;
g:=g-1;
b:=b-1;}
repeat
dec(r);
dec(g);
dec(b);
if r<0 then r:=0;
if g<0 then g:=0;
if b<0 then b:=0;
{if num>=1 then}  setrgbpalette(num,r,g,b);
          {else setrgbpalette(num,0,0,0);}
  {SLEEP(1);}
until (r=0) and (g=0) and (b=0);
  until num >= 255;
end;


procedure sndpalette1;
var num:byte;
 r,g,b:smallint;
begin
num:=0; {keep black ?}
repeat
inc(num);
getrgbpalette(num,r,g,b);
if readsnd < 127 then r:=(r+readsnd+readsnd) div 3;
if readsnd > 127 then g:=(g+readsnd+readsnd) div 3;
if readsnd > 127 then b:=(b+readsnd+readsnd) div 3;
if r=0 then r:=abs(255-(32+random(readsnd div 8)));
if g=0 then g:=abs(255-(32+random(readsnd div 8)));
if b=0 then b:=abs(255-(32+random(readsnd div 8)));
if num>0 then setrgbpalette(num,r,g,b);
until num >= 255;
end;


procedure scr_rnd_snd;
var
x_,y_:integer;
clr_avg:integer;
clr1,clr2,clr3:byte;
r3,g3,b3,r1,r2,g2,g1,b1,b2:byte;
clr_r_avg,clr_b_avg,clr_g_avg:byte;
begin
x_:=0;
y_:=0;
repeat
inc(x_);
repeat
{clr1:=getpixel(x_,y_);
getrgbpalette(clr1,r1,g1,b1);
clr2:=getpixel(x_,y_+1);
getrgbpalette(clr2,r2,g2,b2);
clr3:=readsnd;
getrgbpalette(clr3,r3,g3,b3);
clr_r_avg:=(r1+r2+r3+random(32)) div 4;
clr_g_avg:=(g1+g2+g3+random(32)) div 4;
clr_b_avg:=(b1+b2+b3+random(32)) div 4;
setrgbpalette(clr1,clr_r_avg,clr_g_avg,clr_b_avg);
}
putpixel(x_,y_,readsnd);
inc(y_);
until y_>=399;
y_:=0;
until x_ >= 639;
{delay(3);}
end;


procedure scr_avg4;
var
x_,y_:integer;
clr_avg:integer;
clr1,clr2,clr3:byte;
r1,r2,g2,g1,b1,b2,r3,g3,b3:byte;
clr_r_avg,clr_b_avg,clr_g_avg:byte;
begin
x_:=0;
y_:=0;
repeat
inc(x_);
repeat
                    clr1:=getpixel(x_,y_);
{getrgbpalette(clr1,r1,g1,b1);}
if (y_+1 <= 399) and (x_+1 <=639) then clr2:=getpixel(x_+1,y_+1)
               else clr2:=getpixel(x_,y_);
{getrgbpalette(clr2,r2,g2,b2);}
if (y_+2 <= 399) then clr3:=getpixel(x_,y_+2)
               else clr3:=getpixel(x_,y_);
{getrgbpalette(clr3,r3,g3,b3);}
{clr_r_avg:=r1+r2+r3 div 3;
clr_g_avg:=g1+g2+g3 div 3;
clr_b_avg:=b1+b2+b3 div 3;
setrgbpalette(clr1,clr_r_avg,clr_g_avg,clr_b_avg);}
clr_avg:=(clr1+clr2+clr3) div 3;
putpixel(x_+1,y_+1,clr_avg);
inc(y_);
until y_=399;
y_:=0;
until x_ = 639;
{delay(3);}
end;




procedure scr_avg3;
var
x_,y_:integer;
clr_avg:integer;
clr1,clr2,clr3:byte;
r1,r2,g2,g1,b1,b2,r3,g3,b3:byte;
clr_r_avg,clr_b_avg,clr_g_avg:byte;
begin
x_:=0;
y_:=0;
repeat
inc(y_);
repeat
if x_+1 <= 639 then clr1:=getpixel(x_+1,y_)
               else clr1:=getpixel(x_,y_);
{getrgbpalette(clr1,r1,g1,b1);}
if x_+1 <= 639 then clr2:=getpixel(x_+1,y_)
               else clr2:=getpixel(x_,y_);
{getrgbpalette(clr2,r2,g2,b2);}
if y_+1 <= 399 then clr3:=getpixel(x_,y_+1)
               else clr3:=getpixel(x_,y_);
{getrgbpalette(clr3,r3,g3,b3);}
{clr_r_avg:=r1+r2+r3 div 3;
clr_g_avg:=g1+g2+g3 div 3;
clr_b_avg:=b1+b2+b3 div 3;
setrgbpalette(clr1,clr_r_avg,clr_g_avg,clr_b_avg);}
clr_avg:=(clr1+clr2+clr3) div 3;
putpixel(x_+1,y_+1,clr_avg);
inc(x_);
until x_=639;
x_:=0;
until y_ = 339;
{delay(3);}
end;

procedure scr_avg2;
var
x_,y_:integer;
clr_avg:integer;
clr1,clr2,clr3:byte;
r1,r2,g2,g1,b1,b2,r3,g3,b3:byte;
clr_r_avg,clr_b_avg,clr_g_avg:byte;
begin
x_:=0;
y_:=0;
repeat
inc(x_);
repeat
if x_+1 <= 639 then clr1:=getpixel(x_+1,y_)
               else clr1:=getpixel(x_,y_);
{getrgbpalette(clr1,r1,g1,b1);}
if x_+1 <= 639 then clr2:=getpixel(x_+1,y_)
               else clr2:=getpixel(x_,y_);
{getrgbpalette(clr2,r2,g2,b2);}
if y_+1 <= 399 then clr3:=getpixel(x_,y_+1)
               else clr3:=getpixel(x_,y_);
{getrgbpalette(clr3,r3,g3,b3);}
{clr_r_avg:=r1+r2+r3 div 3;
clr_g_avg:=g1+g2+g3 div 3;
clr_b_avg:=b1+b2+b3 div 3;
setrgbpalette(clr1,clr_r_avg,clr_g_avg,clr_b_avg);}
clr_avg:=(clr1+clr2+clr3) div 3;
putpixel(x_+1,y_,clr_avg);
inc(y_);
until y_=399;
y_:=0;
until x_ = 639;
{delay(3);}
end;


procedure scr_avg1;
var
x_,y_:integer;
clr_avg:integer;
clr1,clr2,clr3:byte;
r1,r2,g2,g1,b1,b2,r3,g3,b3:byte;
clr_r_avg,clr_b_avg,clr_g_avg:byte;
begin
x_:=0;
y_:=0;
repeat
inc(x_);
repeat
                    clr1:=getpixel(x_,y_);
{getrgbpalette(clr1,r1,g1,b1);}
if y_+1 <= 399 then clr2:=getpixel(x_,y_+1)
               else clr2:=getpixel(x_,y_);
{getrgbpalette(clr2,r2,g2,b2);}
if x_+1 <= 639 then clr3:=getpixel(x_+1,y_)
               else clr3:=getpixel(x_,y_);
{getrgbpalette(clr3,r3,g3,b3);}
{clr_r_avg:=r1+r2+r3 div 3;
clr_g_avg:=g1+g2+g3 div 3;
clr_b_avg:=b1+b2+b3 div 3;
setrgbpalette(clr1,clr_r_avg,clr_g_avg,clr_b_avg);}
clr_avg:=(clr1+clr2+clr3) div 3;
putpixel(x_,y_+1,clr_avg);
inc(y_);
until y_=399;
y_:=0;
until x_ = 639;
{delay(3);}
end;



procedure scr_avg;
var
x_,y_:integer;
clr_avg:integer;
clr1,clr2,clr3:smallint;
r1,r2,g2,g1,b1,b2,r3,g3,b3:smallint;
clr_r_avg,clr_b_avg,clr_g_avg:smallint;
begin
x_:=0;
y_:=0;
repeat
inc(x_);
repeat
if y_+1 <=399 then clr1:=getpixel(x_,y_+1)
              else clr1:=getpixel(x_,y_);
getrgbpalette(clr1,r1,g1,b1);
if x_+1 <=639 then clr2:=getpixel(x_+1,y_)
              else clr2:=getpixel(x_,y_);
getrgbpalette(clr2,r2,g2,b2);
if (x_+1 <=639) and (y_+1 <=399) then clr3:=getpixel(x_+1,y_+1)
                                 else clr3:=getpixel(x_,y_);
getrgbpalette(clr3,r3,g3,b3);
clr_r_avg:=(r1+r2+r3) div 3;
clr_g_avg:=(g1+g2+g3) div 3;
clr_b_avg:=(b1+b2+b3) div 3;
setrgbpalette(clr1,clr_r_avg,clr_g_avg,clr_b_avg);
if (x_+1 <=639) and( y_+1 <=399) then putpixel(x_+1,y_+1,clr1);
inc(y_);
until y_=399;
y_:=0;
until x_ = 639;
{sleep(1);}
{delay(3);}
end;




  begin
  clrscr;
{ FUllscreenGraph:=true; }
  gd:=detect;
  gm:=0;
  Initgraph(gd,gm,'');
  {setdirectvideo(true);}
  setgraphmode(m640x400x256);

  cnt:=0;
  snd_avg:=0;
  x:=1;
  //- Find out which extensions are supported and print them (could error check for capture extension here)
  writeln('OpenAL Extensions = ',PChar(alGetString(AL_EXTENSIONS)));

  //- Print device specifiers for default devices
  writeln('ALC_DEFAULT_DEVICE_SPECIFIER = ',PChar(alcGetString(nil, ALC_DEFAULT_DEVICE_SPECIFIER )));
  writeln('ALC_CAPTURE_DEVICE_SPECIFIER = ',PChar(alcGetString(nil, ALC_CAPTURE_DEVICE_SPECIFIER )));

  //- Setup the input capture device (default device)
  writeln('Setting up alcCaptureOpenDevice to use default device');
  pcaptureDevice:=alcCaptureOpenDevice(nil, Frequency, Format, BufferSize);
  if pcaptureDevice=nil then begin
    raise exception.create('Capture device is nil!');
    exit;
  end;
  //===========================================================================
  // Here's where we do the recording bit :)
  //===========================================================================
{for znum:=0 to buffersize do capturebuffer2[znum]:=12;}
  //- Start capturing data
  numz3:=0;
  if findfirst('Bmp/*.bmp',faanyfile and fadirectory,info)=0 then begin
                                                                            repeat
                                                                             names_files[numz3] :=info.name;
                                                                            inc(numz3);
                                                                            until findnext(info) <>0;
                                                                           end;
                                                                           maxfiles_:=numz3;
                                                                           findclose(info);
  alcCaptureStart(PCaptureDevice);
 avgsound:=127;
  num_capture:=0;
  textcolor(9);   {div 16}
  scr_rnd_snd;
   nmz:=0;
  current_page:=1;
   randomize;
   repeat
 { setactivepage(1);} {1}
 { setvisualpage(0);} {0}

 if avgsound>255 then avgsound:=127;
  putpixel(readsnd mod 639,readsnd mod 399,readsnd);
  inc(nmz);
 until nmz=1300;

  repeat
{snd_avg:=snd_avg+readsnd;
  snd_avg:=snd_avg div 2;
 if  readsnd >= snd_avg+30 then if readsnd >= snd_avg+30 then
                                                         else
                                                       clrscr;}
 y:=50+(readsnd-127) div 9 ; {div 7}
{ if x>80  then x:=80;}
{ if y> 44 then y:=44;}
{ if x <1 then x:=1;
 if y <1 then y:=1; }
{  gotoxy(1,1);
  write(x, ' , ',y);}
 if (readsnd>=245) and (readsnd>=245) or (readsnd<=15) and (readsnd<=15) then
                                                                              begin
                                                                              fadeout;
                                                                              {setrgbpalette(0,0,0,0);}
                                                                              {cleardevice;}
                                                                              setcolor(0);
                                                                              Bar(0,0,639,399);
                                                                              repeat


                                                                              {initpalette256;}
                                                                              avgsound:=127;

                                                                              {if getbeat=true then sleep(readsnd div 16);}
                                                                              until (readsnd>126) and (readsnd < 130) or (keypressed);
                                                                              if random < 0.5 then begin
                                                                                                    if random < 0.003 then scr_rnd_snd1;
                                                                                                    if random < 0.003 then {pop};
                                                                                                    if random < 0.003 then scr_avg3;

                                                                                                    {scr_rnd_snd;
                                                                                                    scr_avg1;}
                                                                                                    end;
                                                                              end
                                                 else
                                                 begin
                                                  avgsound:=avgsound+readsnd div 2;

                                                 if getbeat = true then if random < 0.2 then scr_avg1
                                                                                        else if random < 0.319 then scr_avg;
                                                 {putpixel(x,(y*5-35),abs(255-readsnd));
                                                 putpixel(x,(y*5+1-35),(readsnd));
                                                 putpixel(x,(y*5+1-35),abs(255-readsnd));}
                                                 {if getbeat=true then if random < 0.5 then sleep(readsnd div 16);}
                                                 {gotoxy(x ,y div 3);
                                                 write('@');}

                                                 end;

                                                 { gotoxy(readsnd div 4+1, readsnd div 6+1);}

  oldy[x]:=y;
  inc(x);
  {x:=x mod 80;}
 if x>639 then begin
               x:=0;
               {clrscr;}
               {clr_oss;}
               end;
 {if y> 44 then y:=44;}
  {readsnd;}
   {scr_avg1;}
   avgsound:=(avgsound+readsnd) div 2;

  if getbeat=true then
                            begin

                              for tmpnum:=readsnd downto 0 do

                                if getbeat=true then if random < 0.5 then if random < 0.02034 then
                                begin
                                {setfillstyle(10,readsnd);}
                                setcolor(readsnd);
                                {circle(random(readsnd)+readsnd+126,yc,(tmpnum+readsnd)div 2);}
                                 circle(random(639),yc,tmpnum);
                             end
                               else begin
                                    setcolor(readsnd);
                                    circle(xc,yc,(tmpnum));
                                    end;

                               avgsound:=(avgsound+readsnd) div 2;

                               if getbeat=true then scr_avg1;


                              end;

{  if getbeat=true then if random < 0.5 then scr_rnd_snd1
                  else if random < 0.5 then scr_rnd_snd;}
  {if getbeat=true then
 begin }

  avgsound:=(avgsound+readsnd) div 2;
 if getbeat=true then if random < 0.0444 then scr_avg4;
 if getbeat=true then if random < 0.430 then scr_avg1
                                          else if random < 0.00431 then scr_avg2;
 {if getbeat=true then if random < 0.0431 then scr_avg;}
 {end;}
    xc:=readsnd;
    yc:=readsnd;
   avgsound:=(avgsound+readsnd) div 2;


  if getbeat=true then if random < 0.05 then begin

 {nmz:=0;
 repeat
  putpixel(readsnd mod 639,readsnd mod 399,readsnd);
  inc(nmz);
 until nmz=33000;}
                      {scr_rnd_snd1;}
                          {scr_avg1;}
                          {scr_avg2;}

 { if random < 0.3 then  scr_avg1;}

  avgsound:=(avgsound+readsnd) div 2;


 {if getbeat=true then if random < 0.319 then begin
                                              scr_rnd_snd1;
                                              scr_avg;
                                              end; }
  {if random < 0.2333 then if getbeat=false then scr_avg1
                                           else scr_avg2;}

                   avgsound:=(avgsound+readsnd) div 2;


 if getbeat=true then  sndpalette1
                 else scr_avg;

 end;
  {if getbeat=true then if random < 0.3 then scr_avg;}
 { if getbeat=true then scr_avg;}
 { if getbeat=true then inc(cnt_b)
                  else dec(cnt_b);
  if cnt_b>5 then cnt_b:=5;;
  if cnt_b<0 then cnt_b:=0;
  sleep(cnt_b);}
{if getbeat=true then if random < 0.329 then scr_avg;}
{if getbeat=true then if random < 0.032 then sndpalette1;}
 {sleep(3);}
 gotoxy(1,10);
 writeln('beat=',getbeat,'   ');
 writeln('snd byte: ',readsnd,'   ');
 writeln('avg snd: ',avgsound,'   ');
 {if getbeat=true then scr_avg1;}

  avgsound:=(avgsound+readsnd) div 2;

  if (getbeat=true) and (readsnd>5) then pop;
 if getbeat = true then if (readsnd-127) >= (abs(avgsound-127)+80) then sleep(avgsound div 2); {64}
    if getbeat=true then  if random < 0.0309 then scr_avg4;
     avgsound:=(avgsound+readsnd) div 2;
if getbeat=true and getbeat=true then if random < 0.5 then sleep((avgsound) div 6+random(readsnd div 6)); {paces the beat slows it down so you can notice when}
 if getbeat=true then if random < 0.15 then if random < 0.15 then
                                                              begin
                                                              DisplayImage('Bmp/'+names_files[random(maxfiles_)],0,0, GetPaletteSize);
                                                            { readbmp('Bmp/'+names_files[random(maxfiles_)]);}
                                                               if getbeat=true then sleep(readsnd div 4);
                                                              end;
{setactivepage(0);
 setvisualpage(1);}

 until keypressed;

  writeln;
  writeln(snd_avg);
  writeln(readsnd);
writeln(x ,' , ',y);

  //- Done recording
  alcCaptureStop(pCaptureDevice);
  //- Shutdown/Clean up the capture stuff
  alcCaptureStop( pCaptureDevice );
  gotoxy(1,6);
  writeln('Stoping Capture device.');
  alcCaptureCloseDevice( pCaptureDevice );
  writeln('Capture Device Closed');
  closegraph;
  writeln('Graphics Window Closed');
  writeln('Palette size ',getpalettesize);
  gotoxy(1,18);
{  for num:=0 to maxfiles_ do writeln(names_files[num]);}
  end.