unit LSStatsLayer;

interface

uses
  Classes,
  SimpleNamedValues,
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                   TStatReader
--------------------------------------------------------------------------------
===============================================================================}
type
  TStatsPerByte = array[Byte] of UInt64;

{===============================================================================
    TStatReader - class declaration
===============================================================================}
type
  TStatReader = class(TLSLayerReader)
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
    class Function LayerObjectKind: TLSLayerObjectKind; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); overload; override;
    property Counter: UInt64 read fCounter;
    property ByteCounters: TStatsPerByte read fByteCounters;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                   TStatWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStatWriter - class declaration
===============================================================================}
type
  TStatWriter = class(TLSLayerWriter)
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
    class Function LayerObjectKind: TLSLayerObjectKind; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); overload; override;
    property Counter: UInt64 read fCounter;
    property ByteCounters: TStatsPerByte read fByteCounters;
  end;

implementation

{===============================================================================
--------------------------------------------------------------------------------
                                   TStatReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStatReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TStatReader - protected methods
-------------------------------------------------------------------------------}

Function TStatReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStatReader.ReadActive(out Buffer; Size: LongInt): LongInt;
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

procedure TStatReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fFullStats := False;
ClearStats;
If Assigned(Params) then
  If Params.Exists('TStatReader.FullStats',nvtBool) then
    fFullStats := Params.BoolValue['TStatReader.FullStats'];
end;

//------------------------------------------------------------------------------

procedure TStatReader.ClearStats;
begin
fCounter := 0;
FillChar(fByteCounters,SizeOf(TStatsPerByte),0);
end;

{-------------------------------------------------------------------------------
    TStatReader - public methods
-------------------------------------------------------------------------------}

class Function TStatReader.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobPassthrough,lobObserver];
end;

//------------------------------------------------------------------------------

class Function TStatReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TStatReader.FullStats',nvtBool,[loprConstructor,loprInitializer],'Observe all statistics');
Result[1] := LayerObjectParam('TStatReader.KeepStats',nvtBool,[loprInitializer],'Keep current statistics');
end;

//------------------------------------------------------------------------------

procedure TStatReader.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TStatReader.FullStats',nvtBool) then
      fFullStats := Params.BoolValue['TStatReader.FullStats'];
    If Params.Exists('TStatReader.KeepStats',nvtBool) then
      If not Params.BoolValue['TStatReader.KeepStats'] then
        ClearStats;
  end
else ClearStats;
end;


{===============================================================================
--------------------------------------------------------------------------------
                                   TStatWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStatWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TStatWriter - protected methods
-------------------------------------------------------------------------------}

Function TStatWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStatWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
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

procedure TStatWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fFullStats := False;
ClearStats;
If Assigned(Params) then
  If Params.Exists('TStatWriter.FullStats',nvtBool) then
    fFullStats := Params.BoolValue['TStatWriter.FullStats'];
end;

//------------------------------------------------------------------------------

procedure TStatWriter.ClearStats;
begin
fCounter := 0;
FillChar(fByteCounters,SizeOf(TStatsPerByte),0);
end;

{-------------------------------------------------------------------------------
    TStatWriter - public methods
-------------------------------------------------------------------------------}

class Function TStatWriter.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobPassthrough,lobObserver];
end;

//------------------------------------------------------------------------------

class Function TStatWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TStatWriter.FullStats',nvtBool,[loprConstructor,loprInitializer],'Observe all statistics');
Result[1] := LayerObjectParam('TStatWriter.KeepStats',nvtBool,[loprInitializer],'Keep current statistics');
end;

//------------------------------------------------------------------------------

procedure TStatWriter.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TStatWriter.FullStats',nvtBool) then
      fFullStats := Params.BoolValue['TStatWriter.FullStats'];
    If Params.Exists('TStatWriter.KeepStats',nvtBool) then
      If not Params.BoolValue['TStatWriter.KeepStats'] then
        ClearStats;
  end
else ClearStats;
end;

end.
