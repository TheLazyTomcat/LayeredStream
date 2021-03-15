{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - Stop layer

    Stops reads, writes and, depending on settings, seeks so they are not
    propagated to the next layer.
    Note that internal seeking is affected the same way as normal seeking,
    except that it is always silent (does not raise an exception).

  Version 1.0 beta 2 (2021-03-14)

  Last change 2021-03-14

  ©2020-2021 František Milt

  Contacts:
    František Milt: frantisek.milt@gmail.com

  Support:
    If you find this code useful, please consider supporting its author(s) by
    making a small donation using the following link(s):

      https://www.paypal.me/FMilt

  Changelog:
    For detailed changelog and history please refer to this git repository:

      github.com/TheLazyTomcat/LayeredStream

  Dependencies:
    AuxTypes          - github.com/TheLazyTomcat/Lib.AuxTypes
    AuxClasses        - github.com/TheLazyTomcat/Lib.AuxClasses
    SimpleNamedValues - github.com/TheLazyTomcat/Lib.SimpleNamedValues

  Dependencies required by implemented layers:
    Adler32            - github.com/TheLazyTomcat/Lib.Adler32
    CRC32              - github.com/TheLazyTomcat/Lib.CRC32
    MD2                - github.com/TheLazyTomcat/Lib.MD2
    MD4                - github.com/TheLazyTomcat/Lib.MD4
    MD5                - github.com/TheLazyTomcat/Lib.MD5
    SHA0               - github.com/TheLazyTomcat/Lib.SHA0
    SHA1               - github.com/TheLazyTomcat/Lib.SHA1
    SHA2               - github.com/TheLazyTomcat/Lib.SHA2
    SHA3               - github.com/TheLazyTomcat/Lib.SHA3
    CityHash           - github.com/TheLazyTomcat/Lib.CityHash
    HashBase           - github.com/TheLazyTomcat/Lib.HashBase
    StrRect            - github.com/TheLazyTomcat/Lib.StrRect
    StaticMemoryStream - github.com/TheLazyTomcat/Lib.StaticMemoryStream
  * SimpleCPUID        - github.com/TheLazyTomcat/Lib.SimpleCPUID
    BitOps             - github.com/TheLazyTomcat/Lib.BitOps
    UInt64Utils        - github.com/TheLazyTomcat/Lib.UInt64Utils
    MemoryBuffer       - github.com/TheLazyTomcat/Lib.MemoryBuffer
    ZLibUtils          - github.com/TheLazyTomcat/Lib.ZLibUtils
    DynLibUtils        - github.com/TheLazyTomcat/Lib.DynLibUtils
    ZLib               - github.com/TheLazyTomcat/Bnd.ZLib

  SimpleCPUID might not be needed, see BitOps and CRC32 libraries for details.

===============================================================================}
unit LayeredStream_StopLayer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues,  
  LayeredStream_Layers;

{===============================================================================
    Stop exception
===============================================================================}
type
  TLSLayerStopException = class(ELSException);

{===============================================================================
--------------------------------------------------------------------------------
                                TStopLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStopLayerReader - class declaration
===============================================================================}
type
  TStopLayerReader = class(TLSLayerReader)
  private
    fStopSeek:    Boolean;
    fSilentStop:  Boolean;
    fReadZeroes:  Boolean;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    Function SeekInternal(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property StopSeek: Boolean read fStopSeek write fStopSeek;
    property SilentStop: Boolean read fSilentStop write fSilentStop;
    property ReadZeroes: Boolean read fReadZeroes write fReadZeroes;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TStopLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStopLayerWriter - class declaration
===============================================================================}
type
  TStopLayerWriter = class(TLSLayerWriter)
  private
    fStopSeek:    Boolean;
    fSilentStop:  Boolean;
    fWriteSink:   Boolean;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    Function SeekInternal(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property StopSeek: Boolean read fStopSeek write fStopSeek;
    property SilentStop: Boolean read fSilentStop write fSilentStop;
    property WriteSink: Boolean read fWriteSink write fWriteSink;
  end;

implementation

uses
  LayeredStream;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
  {$DEFINE W5058:={$WARN 5058 OFF}} // Variable "$1" does not seem to be initialized
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                TStopLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStopLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TStopLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TStopLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
If fStopSeek then
  begin
    If fSilentStop then
      Result := 0
    else
      raise TLSLayerStopException.CreateFmt('TStopLayerReader.SeekActive: Stopped seek (%d,%d).',[Offset,Ord(Origin)]);
  end
else Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5058{$ENDIF}
Function TStopLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
If fSilentStop then
  begin
    If Size > 0 then
      begin
        If fReadZeroes then
          begin
            FillChar(Buffer,Size,0);
            Result := Size;
          end
        else Result := 0;
      end
    else Result := 0;
  end
else raise TLSLayerStopException.CreateFmt('TStopLayerReader.ReadActive: Stopped read (%p,%d).',[@Buffer,Size]);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TStopLayerReader.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
begin
GetNamedValue(Params,'TStopLayerReader.StopSeek',fStopSeek);
GetNamedValue(Params,'TStopLayerReader.SilentStop',fSilentStop);
GetNamedValue(Params,'TStopLayerReader.ReadZeroes',fReadZeroes);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TStopLayerReader.Initialize(Params: TSimpleNamedValues);
begin
fStopSeek := False;
fSilentStop := True;
fReadZeroes := True;
inherited;
end;

{-------------------------------------------------------------------------------
    TStopLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TStopLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopStopper];
end;

//------------------------------------------------------------------------------

class Function TStopLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,3);
Result[0] := LayerObjectParam('TStopLayerReader.StopSeek',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TStopLayerReader.SilentStop',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
Result[2] := LayerObjectParam('TStopLayerReader.ReadZeroes',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

Function TStopLayerReader.SeekInternal(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
If fStopSeek then
  Result := 0
else
  Result := inherited SeekInternal(Offset,Origin);
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TStopLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStopLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TStopLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TStopLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
If fStopSeek then
  begin
    If fSilentStop then
      Result := 0
    else
      raise TLSLayerStopException.CreateFmt('TStopLayerWriter.SeekActive: Stopped seek (%d,%d).',[Offset,Ord(Origin)]);
  end
else Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStopLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
If fSilentStop then
  begin
    If Size > 0 then
      begin
        If fWriteSink then
          Result := Size
        else
          Result := 0;
      end
    else Result := 0;
  end
else raise TLSLayerStopException.CreateFmt('TStopLayerWriter.WriteActive: Stopped write (%p,%d).',[@Buffer,Size]);
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TStopLayerWriter.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
begin
GetNamedValue(Params,'TStopLayerWriter.StopSeek',fStopSeek);
GetNamedValue(Params,'TStopLayerWriter.SilentStop',fSilentStop);
GetNamedValue(Params,'TStopLayerWriter.WriteSink',fWriteSink);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TStopLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fStopSeek := False;
fSilentStop := True;
fWriteSink := True;
inherited;
end;

{-------------------------------------------------------------------------------
    TStopLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TStopLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopStopper];
end;

//------------------------------------------------------------------------------

class Function TStopLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,3);
Result[0] := LayerObjectParam('TStopLayerWriter.StopSeek',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TStopLayerWriter.SilentStop',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
Result[2] := LayerObjectParam('TStopLayerWriter.WriteSink',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

Function TStopLayerWriter.SeekInternal(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
If fStopSeek then
  Result := 0
else
  Result := inherited SeekInternal(Offset,Origin);
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_Stop',TStopLayerReader,TStopLayerWriter);

end.
