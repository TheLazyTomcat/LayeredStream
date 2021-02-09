{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - Stat Layer

    Layer intended for watching and analyzing of reads, writes or seaks.
    
    Currently, only wery basic statistic is implemented, more will be probably
    introduced later.

  Version 1.0 (2020-11-03)

  Last change 2020-11-03

  ©2020 František Milt

  Contacts:
    František Milt: frantisek.milt@gmail.com

  Support:
    If you find this code useful, please consider supporting its author(s) by
    making a small donation using the following link(s):

      https://www.paypal.me/FMilt

  Changelog:
    For detailed changelog and history please refer to this git repository:

      github.com/TheLazyTomcat/Lib.LayeredStream

  Dependencies:
    AuxTypes          - github.com/TheLazyTomcat/Lib.AuxTypes
    AuxClasses        - github.com/TheLazyTomcat/Lib.AuxClasses
    SimpleNamedValues - github.com/TheLazyTomcat/Lib.SimpleNamedValues
    LayeredStream     - github.com/TheLazyTomcat/Lib.LayeredStream

===============================================================================}
unit LayeredStream_StatLayer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues,
  LayeredStream_Layers;

{===============================================================================
--------------------------------------------------------------------------------
                                TStatLayerReader
--------------------------------------------------------------------------------
===============================================================================}
type
  TStatsPerByte = array[Byte] of UInt64;

{===============================================================================
    TStatLayerReader - class declaration
===============================================================================}
type
  TStatLayerReader = class(TLSLayerReader)
  private
    fFullStats:     Boolean;
    fCounter:       UInt64;
    fByteCounters:  TStatsPerByte;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure ClearStats; virtual;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Update(Params: TSimpleNamedValues); override;
    property Counter: UInt64 read fCounter;
    property ByteCounters: TStatsPerByte read fByteCounters;
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
    fFullStats:     Boolean;
    fCounter:       UInt64;
    fByteCounters:  TStatsPerByte;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure ClearStats; virtual;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Update(Params: TSimpleNamedValues); override;
    property Counter: UInt64 read fCounter;
    property ByteCounters: TStatsPerByte read fByteCounters;
  end;

implementation

uses
  LayeredStream;

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
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStatLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
var
  BuffPtr:  PByte;
  i:        Integer;
begin
Result := ReadOut(Buffer,Size);
// observe only the amount really read
Inc(fCounter,Result);
If fFullStats then
  begin
    BuffPtr := @Buffer;
    For i := 1 to Result do
      begin
        Inc(fByteCounters[BuffPtr^]);
        Inc(BuffPtr);
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TStatLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
ClearStats;
fFullStats := False;
GetNamedValue(Params,'TStatLayerReader.FullStats',fFullStats);
end;

//------------------------------------------------------------------------------

procedure TStatLayerReader.ClearStats;
begin
fCounter := 0;
FillChar(fByteCounters,SizeOf(TStatsPerByte),0);
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
GetNamedValue(Params,'TStatLayerReader.FullStats',fFullStats);
KeepStats := False;
GetNamedValue(Params,'TStatLayerReader.KeepStats',KeepStats);
If not KeepStats then
  ClearStats;
end;

//------------------------------------------------------------------------------

procedure TStatLayerReader.Update(Params: TSimpleNamedValues);
begin
inherited;
GetNamedValue(Params,'TStatLayerReader.FullStats',fFullStats);
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
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStatLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
var
  BuffPtr:  PByte;
  i:        Integer;
begin
Result := WriteOut(Buffer,Size);
// observe only the amount really written
Inc(fCounter,Result);
If fFullStats then
  begin
    BuffPtr := @Buffer;
    For i := 1 to Result do
      begin
        Inc(fByteCounters[BuffPtr^]);
        Inc(BuffPtr);
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TStatLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
ClearStats;
fFullStats := False;
GetNamedValue(Params,'TStatLayerWriter.FullStats',fFullStats);
end;

//------------------------------------------------------------------------------

procedure TStatLayerWriter.ClearStats;
begin
fCounter := 0;
FillChar(fByteCounters,SizeOf(TStatsPerByte),0);
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
GetNamedValue(Params,'TStatLayerWriter.FullStats',fFullStats);
KeepStats := False;
GetNamedValue(Params,'TStatLayerWriter.KeepStats',KeepStats);
If not KeepStats then
  ClearStats;
end;

//------------------------------------------------------------------------------

procedure TStatLayerWriter.Update(Params: TSimpleNamedValues);
begin
inherited;
GetNamedValue(Params,'TStatLayerWriter.FullStats',fFullStats);
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_Stat',TStatLayerReader,TStatLayerWriter);

end.
