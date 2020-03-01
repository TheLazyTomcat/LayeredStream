unit LayeredStream;

interface

uses
  SysUtils, Classes,
  AuxTypes;

type
  ELSException = class(Exception);

  ELSIndexOutOfBounds  = class(ELSException);
  ELSInvalidConnection = class(ELSException);

//==============================================================================

  TLSLayerType = (ltUndefined,ltReader,ltWriter,ltReaderWriter);

  TLSLayerKind = (
    lkPasstrough,   // data are passing trought with no change or processing
    lkObserver,     // same as lkPasstrough, but some processing is done (eg. hashing)
    lkProcessor,    // data are passing but are changed (eg. compressed, encrypted, ...)
    lkSplitter,     // data are passing without change, but some (or all) of them are also passed to a side channel
    lkJoiner,       // data are passing and some data are added to them from a side channel
    lkAccumulator,  // data are accumulated in the layer and are not streamed (might pass trough all at once at the end of operation)
    lkConsumer,     // data are not passing and are completely consumed by the layer
    lkGenerator     // new data are generated without a need of any input data
  );

  TLSLayerReadConnection = Function(out Buffer; Size: LongInt): LongInt of object;
  TLSLayerWriteConnection = Function(const Buffer; Size: LongInt): LongInt of object;
  TLSLayerSeekConnection = Function(const Offset: Int64; Origin: TSeekOrigin): Int64 of object;

  TLSLayerClass = class of TLSLayerBase;

  TLSLayerBase = class(TObject)
  protected
    fCounterpart:     TLSLayerBase;   // the orher object in layer pair
    fReadConnection:  TLSLayerReadConnection;
    fWriteConnection: TLSLayerWriteConnection;
    fSeekConnection:  TLSLayerSeekConnection;
    Function ReadOutput(out Buffer; Size: LongInt): LongInt; virtual;
    Function WriteOutput(const Buffer; Size: LongInt): LongInt; virtual;
    Function SeekOutput(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
  public
    class Function LayerType: TLSLayerType; virtual;
    class Function LayerKind: TLSLayerKind; virtual;
    class Function LayerCounterpartClass: TLSLayerClass; virtual;
    constructor Create(Data: Pointer = nil);
    destructor Destroy; override;
    procedure InitInternal; virtual;    // called only by TLayerStream, do not call explicitly
    procedure FinalInternal; virtual;   // -//-
    procedure Init; overload; virtual;  // calls Init(nil)
    procedure Init(Data: Pointer); overload; virtual;
    procedure Final; virtual;
    procedure Flush; virtual;    
    Function ReadInput(out Buffer; Size: LongInt): LongInt; virtual;
    Function WriteInput(const Buffer; Size: LongInt): LongInt; virtual;
    Function SeekInput(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
    property Counterpart: TLSLayerBase read fCounterpart write fCounterpart;
    property ReadConnection: TLSLayerReadConnection read fReadConnection write fReadConnection;
    property WriteConnection: TLSLayerWriteConnection read fWriteConnection write fWriteConnection;
    property SeekConnection:  TLSLayerSeekConnection read fSeekConnection write fSeekConnection;
  end;

  TLSLayerPasstrough = class(TLSLayerBase)
  public
    class Function LayerType: TLSLayerType; override;
  end;

//==============================================================================

  TLSLayerPair = record
    Reader: TLSLayerBase;
    Writer: TLSLayerBase;
  end;

  TLayeredStreamMode = (lsmUndefined,lsmSeek,lsmRead,lsmWrite);

  TLayeredStream = class(TStream)
  private
    fMode:        TLayeredStreamMode;
    fTarget:      TStream;
    fOwnsTarget:  Boolean;
    fLayers:      array of TLSLayerPair;
    Function GetLayerCount: Integer;
    Function GetLayer(Index: Integer): TLSLayerPair;
  protected
    Function ReadInput(out Buffer; Size: LongInt): LongInt; virtual;
    Function ReadOutput(out Buffer; Size: LongInt): LongInt; virtual;
    Function WriteInput(const Buffer; Size: LongInt): LongInt; virtual;
    Function WriteOutput(const Buffer; Size: LongInt): LongInt; virtual;
    Function SeekInput(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
    Function SeekOutput(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
    procedure FlushReaders; virtual;
    procedure FlushWriters; virtual;
    procedure ChangeMode(NewMode: TLayeredStreamMode); virtual;
    procedure InitializePair(Index: Integer); virtual;
    procedure FinalizePair(Index: Integer); virtual;
    procedure Initialize; virtual;
    procedure Finalize; virtual;    
  public
    constructor Create(Target: TStream); overload;
    constructor Create(Target: TStream; Layers: array of TLSLayerClass); overload;
    destructor Destroy; override;
    Function LowIndex: Integer; virtual;
    Function HighIndex: Integer; virtual;
    Function CheckIndex(Index: Integer): Boolean; virtual;
    procedure Init; virtual;
    procedure Final; virtual;
    procedure Flush; virtual;
    Function IndexOf(Layer: TLSLayerClass): Integer; overload; virtual;
    Function IndexOf(LayerObject: TLSLayerBase): Integer; overload; virtual;
    //Function Add(Layer: TLSLayerClass; ReaderData, WriteData: Pointer): Integer; virtual;
    //Function Insert(Index: Integer; Layer: TLSLayerClass; ReaderData, WriteData: Pointer): Integer; virtual;
    Function Remove(Layer: TLSLayerClass): Integer; overload; virtual;
    Function Remove(LayerObject: TLSLayerBase): Integer; overload; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    Function Read(var Buffer; Count: LongInt): LongInt; override;
    Function Write(const Buffer; Count: LongInt): LongInt; override;
    Function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property Mode: TLayeredStreamMode read fMode;
    property Target: TStream read fTarget;
    property OwnsTarget: Boolean read fOwnsTarget write fOwnsTarget;
    property LayerCount: Integer read GetLayerCount;
    property Layers[Index: Integer]: TLSLayerPair read GetLayer; default;
  end;

implementation

Function TLSLayerBase.ReadOutput(out Buffer; Size: LongInt): LongInt;
begin
Result := 0;
If Assigned(fReadConnection) then
  Result := fReadConnection(Buffer,Size)
else
  ELSInvalidConnection.Create('TLSLayerBase.ReadOutput: Read connection not assigned.');
end;

//------------------------------------------------------------------------------

Function TLSLayerBase.WriteOutput(const Buffer; Size: LongInt): LongInt;
begin
Result := 0;
If Assigned(fWriteConnection) then
  Result := fWriteConnection(Buffer,Size)
else
  ELSInvalidConnection.Create('TLSLayerBase.WriteOutput: Write connection not assigned.');
end;

//------------------------------------------------------------------------------

Function TLSLayerBase.SeekOutput(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := 0;
If Assigned(fSeekConnection) then
  Result := fSeekConnection(Offset,Origin)
else
  ELSInvalidConnection.Create('TLSLayerBase.SeekOutput: Seek connection not assigned.');
end;

//==============================================================================

class Function TLSLayerBase.LayerType: TLSLayerType;
begin
Result := ltUndefined;
end;

//------------------------------------------------------------------------------

class Function TLSLayerBase.LayerKind: TLSLayerKind;
begin
Result := lkPasstrough;
end;

//------------------------------------------------------------------------------

class Function TLSLayerBase.LayerCounterpartClass: TLSLayerClass;
begin
Result := Self;
end;

//------------------------------------------------------------------------------

constructor TLSLayerBase.Create(Data: Pointer);
begin
inherited Create;
fCounterpart := nil;
fReadConnection := nil;
fWriteConnection := nil;
fSeekConnection := nil;
end;

//------------------------------------------------------------------------------

destructor TLSLayerBase.Destroy;
begin
Flush;
inherited;
end;

//------------------------------------------------------------------------------

procedure TLSLayerBase.InitInternal;
begin
// nothing to do
end;

//------------------------------------------------------------------------------

procedure TLSLayerBase.FinalInternal;
begin
// nothing to do
end;

//------------------------------------------------------------------------------

procedure TLSLayerBase.Init;
begin
Init(nil);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLSLayerBase.Init(Data: Pointer);
begin
// nothing to do
end;

//------------------------------------------------------------------------------

procedure TLSLayerBase.Final;
begin
// nothing to do
end;

//------------------------------------------------------------------------------

procedure TLSLayerBase.Flush;
begin
// nothing to do
end;

//------------------------------------------------------------------------------

Function TLSLayerBase.ReadInput(out Buffer; Size: LongInt): LongInt;
begin
If LayerType in [ltReader,ltReaderWriter] then
  Result := ReadOutput(Buffer,Size)
else
  Result := 0;
end;

//------------------------------------------------------------------------------

Function TLSLayerBase.WriteInput(const Buffer; Size: LongInt): LongInt;
begin
If LayerType in [ltWriter,ltReaderWriter] then
  Result := WriteOutput(Buffer,Size)
else
  Result := 0;
end;

//------------------------------------------------------------------------------

Function TLSLayerBase.SeekInput(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOutput(Offset,Origin);
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************

class Function TLSLayerPasstrough.LayerType: TLSLayerType;
begin
Result := ltReaderWriter;
end;

//******************************************************************************
//******************************************************************************
//******************************************************************************

Function TLayeredStream.GetLayerCount: Integer;
begin
Result := Length(fLayers);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.GetLayer(Index: Integer): TLSLayerPair;
begin
If CheckIndex(Index) then
  Result := fLayers[Index]
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.GetLayer: Index (%d) out of bounds.',[Index]);
end;

//==============================================================================

Function TLayeredStream.ReadInput(out Buffer; Size: LongInt): LongInt;
begin
ChangeMode(lsmRead);
If Length(fLayers) > 0 then
  Result := fLayers[HighIndex].Reader.ReadInput(Buffer,Size)
else
  Result := ReadOutput(Buffer,Size);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.ReadOutput(out Buffer; Size: LongInt): LongInt;
begin
Result := fTarget.Read(Buffer,Integer(Size));
end;

//------------------------------------------------------------------------------

Function TLayeredStream.WriteInput(const Buffer; Size: LongInt): LongInt;
begin
ChangeMode(lsmWrite);
If Length(fLayers) > 0 then
  Result := fLayers[HighIndex].Writer.WriteInput(Buffer,Size)
else
  Result := WriteOutput(Buffer,Size);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.WriteOutput(const Buffer; Size: LongInt): LongInt;
begin
Result := fTarget.Write(Buffer,Integer(Size));
end;

//------------------------------------------------------------------------------

Function TLayeredStream.SeekInput(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
ChangeMode(lsmSeek);
// seek is not channeled trough layers
Result := SeekOutput(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.SeekOutput(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := fTarget.Seek(Offset,Origin);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.FlushReaders;
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  fLayers[i].Reader.Flush;
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.FlushWriters;
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  fLayers[i].Writer.Flush;
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.ChangeMode(NewMode: TLayeredStreamMode);
begin
If fMode <> NewMode then
  begin
    case fMode of
      lsmSeek:  ; // do nothing
      lsmRead:  FlushReaders;
      lsmWrite: FlushWriters;
    else
     {lsmUndefined}
      // do nothing
    end;
    fMode := NewMode;
  end;
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.InitializePair(Index: Integer);
begin
fLayers[Index].Reader.Counterpart := fLayers[Index].Writer;
fLayers[Index].Writer.Counterpart := fLayers[Index].Reader;
If Index > LowIndex then
  begin
    fLayers[Index].Reader.ReadConnection := fLayers[Index - 1].Reader.ReadInput;
    fLayers[Index].Reader.SeekConnection := fLayers[Index - 1].Reader.SeekInput;
    fLayers[Index].Writer.WriteConnection := fLayers[Index - 1].Writer.WriteInput;
    fLayers[Index].Writer.SeekConnection := fLayers[Index - 1].Writer.SeekInput;
  end
else
  begin
    fLayers[Index].Reader.ReadConnection := ReadOutput;
    fLayers[Index].Reader.SeekConnection := SeekOutput;
    fLayers[Index].Writer.WriteConnection := WriteOutput;
    fLayers[Index].Writer.SeekConnection := SeekOutput;
  end;
fLayers[Index].Reader.InitInternal;
fLayers[Index].Writer.InitInternal;
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.FinalizePair(Index: Integer);
begin
fLayers[Index].Reader.FinalInternal;
fLayers[Index].Writer.FinalInternal;
If Index < HighIndex then
  begin
    fLayers[Index + 1].Reader.ReadConnection := fLayers[Index].Reader.ReadConnection;
    fLayers[Index + 1].Reader.Seekconnection := fLayers[Index].Reader.Seekconnection;
    fLayers[Index + 1].Writer.ReadConnection := fLayers[Index].Writer.ReadConnection;
    fLayers[Index + 1].Writer.Seekconnection := fLayers[Index].Writer.Seekconnection;
  end;
fLayers[Index].Reader.Counterpart := nil;
fLayers[Index].Writer.Counterpart := nil;
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Initialize;
begin
fMode := lsmUndefined;
fOwnsTarget := False;
SetLength(fLayers,0);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Finalize;
begin
Clear;  // calls flush
If fOwnsTarget then
  fTarget.Free;
end;

//==============================================================================

constructor TLayeredStream.Create(Target: TStream);
begin
inherited Create;
fTarget := Target;
Initialize;
end;

//------------------------------------------------------------------------------

constructor TLayeredStream.Create(Target: TStream; Layers: array of TLSLayerClass);
var
  i:  Integer;
begin
Create(Target);
SetLength(fLayers,Length(Layers));
For i := Low(Layers) to High(Layers) do
  begin
    If Layers[i].LayerType in [ltReader,ltReaderWriter] then
      begin
        fLayers[i].Reader := Layers[i].Create(fTarget);
        fLayers[i].Writer := Layers[i].LayerCounterpartClass.Create(fTarget);
      end
    else
      begin
        fLayers[i].Reader := Layers[i].LayerCounterpartClass.Create(fTarget);
        fLayers[i].Writer := Layers[i].Create(fTarget);
      end;
    InitializePair(i);
  end;
end;

//------------------------------------------------------------------------------

destructor TLayeredStream.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

Function TLayeredStream.LowIndex: Integer;
begin
Result := Low(fLayers);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.HighIndex: Integer;
begin
Result := High(fLayers);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.CheckIndex(Index: Integer): Boolean;
begin
Result := (Index >= LowIndex) and (Index <= HighIndex);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Init;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  begin
    fLayers[i].Reader.Init;
    fLayers[i].Writer.Init;
  end;
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Final;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  begin
    fLayers[i].Reader.Final;
    fLayers[i].Writer.Final;
  end;
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Flush;
begin
FlushReaders;
FlushWriters;
end;

//------------------------------------------------------------------------------

Function TLayeredStream.IndexOf(Layer: TLSLayerClass): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If (fLayers[i].Reader is Layer) or (fLayers[i].Writer is Layer) then
    begin
      Result := i;
      Break{For i};
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.IndexOf(LayerObject: TLSLayerBase): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If (fLayers[i].Reader = LayerObject) or (fLayers[i].Writer = LayerObject) then
    begin
      Result := i;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------
(*
Function TLayeredStream.Add(Layer: TLSLayerClass; ReaderData, WriteData: Pointer): Integer;
begin
SetLength(fLayers,Length(fLayers) + 1);
Result := High(fLayers);
fLayers[Result].Reader
end;

Function TLayeredStream.Insert(Index: Integer; Layer: TLSLayerClass; ReaderData, WriteData: Pointer): Integer;
*)


Function TLayeredStream.Remove(Layer: TLSLayerClass): Integer;
begin
Result := IndexOf(Layer);
If CheckIndex(Result) then
  Delete(Result);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.Remove(LayerObject: TLSLayerBase): Integer;
begin
Result := IndexOf(LayerObject);
If CheckIndex(Result) then
  Delete(Result);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Delete(Index: Integer);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    FinalizePair(Index);
    fLayers[Index].Reader.Free;
    fLayers[Index].Writer.Free;
    For i := Index to Pred(HighIndex) do
      fLayers[i] := fLayers[i + 1];
    SetLength(fLayers,Length(fLayers) - 1);
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Delete: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Clear;
var
  i:  Integer;
begin
Flush;
For i := HighIndex downto LowIndex do
  begin
    FinalizePair(i);
    fLayers[i].Reader.Free;
    fLayers[i].Writer.Free;
  end;
SetLength(fLayers,0);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.Read(var Buffer; Count: LongInt): LongInt;
begin
Result := ReadInput(Buffer,Count);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.Write(const Buffer; Count: LongInt): LongInt;
begin
Result := WriteInput(Buffer,Count);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekInput(Offset,Origin);
end;

end.
