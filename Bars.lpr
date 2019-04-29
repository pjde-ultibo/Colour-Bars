program Bars;

{$mode objfpc}{$H+}
{$define use_tftp}
{$hints off}
{$notes off}

uses
  RaspberryPi3,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  SysUtils,
  Classes,
  Ultibo,
  FrameBuffer,
  {$ifdef use_tftp}
  uTFTP, Winsock2
{$endif}
  { Add additional units here };

var
  IPAddress : string;
  DefFrameBuff : PFramebufferDevice;
  Props : TFramebufferProperties;
  x, y, w, h, c : LongWord;

procedure WaitForSDDrive;
begin
  while not DirectoryExists ('C:\') do sleep (500);
end;

function WaitForIPComplete : string;
var
  TCP : TWinsock2TCPClient;
begin
  TCP := TWinsock2TCPClient.Create;
  Result := TCP.LocalAddress;
  if (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') then
    begin
      while (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') do
        begin
          sleep (1000);
          Result := TCP.LocalAddress;
        end;
    end;
  TCP.Free;
end;

begin
  DefFrameBuff := FramebufferDeviceGetDefault;
  FramebufferDeviceGetProperties (DefFrameBuff, @Props);
  h := Props.PhysicalHeight;
  w := Props.PhysicalWidth div 8;
  for x := 0 to 7 do
    begin
      case x of
        0 : c := COLOR_WHITE;
        1 : c := $FFA8B201;
        2 : c := COLOR_CYAN;
        3 : c := COLOR_GREEN;
        4 : c := COLOR_MAGENTA;
        5 : c := COLOR_RED;
        6 : c := COLOR_BLUE;
        7 : c := COLOR_BLACK;
        end;
      FramebufferDeviceFillRect (DefFrameBuff, x * w, 0, w, h, c, FRAMEBUFFER_TRANSFER_DMA);
    end;
  WaitForSDDrive;
  IPAddress := WaitForIPComplete;
  ThreadHalt (0);
end.

