{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - Stat layer

    Layer intended for watching and analyzing of reads, writes or seaks.

    Currently, only basic statistic is implemented, more will be probably
    introduced later.

  Version 1.0 beta (2021-02-12)

  Last change 2021-02-12

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
    HashBase           - github.com/TheLazyTomcat/Lib.HashBase
    StrRect            - github.com/TheLazyTomcat/Lib.StrRect
    BitOps             - github.com/TheLazyTomcat/Lib.BitOps
    StaticMemoryStream - github.com/TheLazyTomcat/Lib.StaticMemoryStream
  * SimpleCPUID        - github.com/TheLazyTomcat/Lib.SimpleCPUID
    ZLibUtils          - github.com/TheLazyTomcat/Lib.ZLibUtils
    MemoryBuffer       - github.com/TheLazyTomcat/Lib.MemoryBuffer
    DynLibUtils        - github.com/TheLazyTomcat/Lib.DynLibUtils
    ZLib               - github.com/TheLazyTomcat/Bnd.ZLib

  SimpleCPUID might not be needed, see BitOps and CRC32 libraries for details.

===============================================================================}
unit LayeredStream_StatLayer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  AuxTypes, SimpleNamedValues,
  LayeredStream_Layers;

{===============================================================================
    Statistics types
===============================================================================}
type
  TStatData = record
    // seek stats
    SeekCalls:          UInt64;
    SeekOriginCounters: array[TSeekOrigin] of UInt32;
    SeekOffsetZero:     UInt64;
    SeekOffsetMax:      Int64;
    SeekOffsetMin:      Int64;
    case Integer of
      // read stats
      0: (ReadCalls:          UInt64;
          ReadSizeZero:       UInt64;
          ReadSizeMax:        LongInt;
          ReadSizeMin:        LongInt;
          ReadBytes:          UInt64;
          PartialReads:       UInt64;
          ZeroReads:          UInt64;
          LargestReadDev:     LongInt;  // largest read deviation (size - result)
          ReadByteCounters:   array[Byte] of UInt64);
      // write stats
      1: (WriteCalls:         UInt64;
          WriteSizeZero:      UInt64;
          WriteSizeMax:       LongInt;
          WriteSizeMin:       LongInt;
          WriteBytes:         UInt64;
          PartialWrites:      UInt64;
          ZeroWrites:         UInt64;
          LargestWriteDev:    LongInt;
          WriteByteCounters:  array[Byte] of UInt64);
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TStatLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStatLayerReader - class declaration
===============================================================================}
type
  TStatLayerReader = class(TLSLayerReader)
  private
    fStartTime:     TDateTIme;
    fClearCounter:  UInt32;
    fFullStats:     Boolean;
    fStatData:      TStatData;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure ClearStats; virtual;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    property StartTime: TDateTime read fStartTime write fStartTime;
    property ClearCounter: UInt32 read fClearCounter write fClearCounter;
    property FullStats: Boolean read fFullStats write fFullStats;
    property StatData: TStatData read fStatData;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TStatLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStatLayerWriter - class declaration
===============================================================================}
type
  TStatLayerWriter = class(TLSLayerWriter)
  private
    fStartTime:     TDateTIme;
    fClearCounter:  UInt32;
    fFullStats:     Boolean;
    fStatData:      TStatData;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure ClearStats; virtual;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    property StartTime: TDateTime read fStartTime write fStartTime;
    property ClearCounter: UInt32 read fClearCounter write fClearCounter;
    property FullStats: Boolean read fFullStats write fFullStats;
    property StatData: TStatData read fStatData;
  end;

implementation

uses
  SysUtils,
  LayeredStream;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                TStatLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStatLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TStatLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TStatLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Inc(fStatData.SeekCalls);
Inc(fStatData.SeekOriginCounters[Origin]);
If Offset = 0 then
  Inc(fStatData.SeekOffsetZero);
If fStatData.SeekCalls > 1 then
  begin
    If Offset > fStatData.SeekOffsetMax then
      fStatData.SeekOffsetMax := Offset;
    If Offset < fStatData.SeekOffsetMin then
      fStatData.SeekOffsetMin := Offset;
  end
else
  begin
    fStatData.SeekOffsetMax := Offset;
    fStatData.SeekOffsetMin := Offset;
  end;
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStatLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
var
  BuffPtr:  PByte;
  i:        Integer;
begin
// pre-call stats
Inc(fStatData.ReadCalls);
If Size = 0 then
  Inc(fStatData.ReadSizeZero);
If fStatData.ReadCalls > 1 then
  begin
    If Size > fStatData.ReadSizeMax then
      fStatData.ReadSizeMax := Size;
    If Size < fStatData.ReadSizeMin then
      fStatData.ReadSizeMin := Size;
  end
else
  begin
    fStatData.ReadSizeMax := Size;
    fStatData.ReadSizeMin := Size;
  end;
Result := ReadOut(Buffer,Size);
// post-call stats
fStatData.ReadBytes := fStatData.ReadBytes + UInt64(Result);
If Result <> Size then
  Inc(fStatData.PartialReads);
If Result = 0 then
  Inc(fStatData.ZeroReads);
If fFullStats then
  begin
    If (Size - Result) > fStatData.LargestReadDev then
      fStatData.LargestReadDev := Size - Result;
    BuffPtr := @Buffer;
    For i := 1 to Result do
      begin
        Inc(fStatData.ReadByteCounters[BuffPtr^]);
        Inc(BuffPtr);
      end;
  end;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TStatLayerReader.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
begin
GetNamedValue(Params,'TStatLayerReader.FullStats',fFullStats);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TStatLayerReader.Initialize(Params: TSimpleNamedValues);
begin
fFullStats := False;  // can be set in ParamsCommon called from inherited code
inherited;
fStartTime := Now;
fClearCounter := 0;
ClearStats;
end;

//------------------------------------------------------------------------------

procedure TStatLayerReader.ClearStats;
begin
Inc(fClearCounter);
FillChar(fStatData,SizeOf(fStatData),0);
end;

{-------------------------------------------------------------------------------
    TStatLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TStatLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopPassthrough,lopObserver];
end;

//------------------------------------------------------------------------------

class Function TStatLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TStatLayerReader.FullStats',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TStatLayerReader.KeepStats',nvtBool,[loprInitializer]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

procedure TStatLayerReader.Init(Params: TSimpleNamedValues);
var
  KeepStats:  Boolean;
begin
inherited;
KeepStats := False;
GetNamedValue(Params,'TStatLayerReader.KeepStats',KeepStats);
If not KeepStats then
  ClearStats;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TStatLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStatLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TStatLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TStatLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Inc(fStatData.SeekCalls);
Inc(fStatData.SeekOriginCounters[Origin]);
If Offset = 0 then
  Inc(fStatData.SeekOffsetZero);
If fStatData.SeekCalls > 1 then
  begin
    If Offset > fStatData.SeekOffsetMax then
      fStatData.SeekOffsetMax := Offset;
    If Offset < fStatData.SeekOffsetMin then
      fStatData.SeekOffsetMin := Offset;
  end
else
  begin
    fStatData.SeekOffsetMax := Offset;
    fStatData.SeekOffsetMin := Offset;
  end;
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStatLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
var
  BuffPtr:  PByte;
  i:        Integer;
begin
// pre-call stats
Inc(fStatData.WriteCalls);
If Size = 0 then
  Inc(fStatData.WriteSizeZero);
If fStatData.WriteCalls > 1 then
  begin
    If Size > fStatData.WriteSizeMax then
      fStatData.WriteSizeMax := Size;
    If Size < fStatData.WriteSizeMin then
      fStatData.WriteSizeMin := Size;
  end
else
  begin
    fStatData.WriteSizeMax := Size;
    fStatData.WriteSizeMin := Size;
  end;
Result := WriteOut(Buffer,Size);
// post-call stats
fStatData.WriteBytes := fStatData.WriteBytes + UInt64(Result);
If Result <> Size then
  Inc(fStatData.PartialWrites);
If Result = 0 then
  Inc(fStatData.ZeroWrites);
If fFullStats then
  begin
    If (Size - Result) > fStatData.LargestWriteDev then
      fStatData.LargestWriteDev := Size - Result;
    BuffPtr := @Buffer;
    For i := 1 to Result do
      begin
        Inc(fStatData.WriteByteCounters[BuffPtr^]);
        Inc(BuffPtr);
      end;
  end;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TStatLayerWriter.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
begin
GetNamedValue(Params,'TStatLayerWriter.FullStats',fFullStats);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TStatLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fFullStats := False;
inherited;
fStartTime := Now;
fClearCounter := 0;
ClearStats;
end;

//------------------------------------------------------------------------------

procedure TStatLayerWriter.ClearStats;
begin
Inc(fClearCounter);
FillChar(fStatData,SizeOf(fStatData),0);
end;

{-------------------------------------------------------------------------------
    TStatLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TStatLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopPassthrough,lopObserver];
end;

//------------------------------------------------------------------------------

class Function TStatLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TStatLayerWriter.FullStats',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TStatLayerWriter.KeepStats',nvtBool,[loprInitializer]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

procedure TStatLayerWriter.Init(Params: TSimpleNamedValues);
var
  KeepStats:  Boolean;
begin
inherited;
KeepStats := False;
GetNamedValue(Params,'TStatLayerWriter.KeepStats',KeepStats);
If not KeepStats then
  ClearStats;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_Stat',TStatLayerReader,TStatLayerWriter);

end.
