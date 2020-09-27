unit LayeredStream_StatLayer;

interface

uses
  Classes,
  SimpleNamedValues,
  LayeredStream;

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
    procedure Init(Params: TSimpleNamedValues); overload; override;
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
    procedure Init(Params: TSimpleNamedValues); overload; override;
    property Counter: UInt64 read fCounter;
    property ByteCounters: TStatsPerByte read fByteCounters;
  end;

implementation

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
fFullStats := False;
ClearStats;
If Assigned(Params) then
  If Params.Exists('TStatLayerReader.FullStats',nvtBool) then
    fFullStats := Params.BoolValue['TStatLayerReader.FullStats'];
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
Result[0] := LayerObjectParam('TStatLayerReader.FullStats',nvtBool,[loprConstructor,loprInitializer],'');
Result[1] := LayerObjectParam('TStatLayerReader.KeepStats',nvtBool,[loprInitializer],'');
end;

//------------------------------------------------------------------------------

procedure TStatLayerReader.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TStatLayerReader.FullStats',nvtBool) then
      fFullStats := Params.BoolValue['TStatLayerReader.FullStats'];
    If Params.Exists('TStatLayerReader.KeepStats',nvtBool) then
      If not Params.BoolValue['TStatLayerReader.KeepStats'] then
        ClearStats;
  end
else ClearStats;
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
fFullStats := False;
ClearStats;
If Assigned(Params) then
  If Params.Exists('TStatLayerWriter.FullStats',nvtBool) then
    fFullStats := Params.BoolValue['TStatLayerWriter.FullStats'];
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
Result[0] := LayerObjectParam('TStatLayerWriter.FullStats',nvtBool,[loprConstructor,loprInitializer],'');
Result[1] := LayerObjectParam('TStatLayerWriter.KeepStats',nvtBool,[loprInitializer],'');
end;

//------------------------------------------------------------------------------

procedure TStatLayerWriter.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TStatLayerWriter.FullStats',nvtBool) then
      fFullStats := Params.BoolValue['TStatLayerWriter.FullStats'];
    If Params.Exists('TStatLayerWriter.KeepStats',nvtBool) then
      If not Params.BoolValue['TStatLayerWriter.KeepStats'] then
        ClearStats;
  end
else ClearStats;
end;

end.
