unit LayeredStream_DebugLayer;

{$IFDEF FPC}
  {$MODE ObjFPC}
  {$DEFINE FPC_DisableWarns}
  {$MACRO ON}
{$ENDIF}
{$H+}

interface

uses
  Classes,
  SimpleNamedValues,
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                               TDebugLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLayerReader - class declaration
===============================================================================}
type
  TDebugLayerReader = class(TLSLayerReader)
  protected
    fDebugging: Boolean;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    procedure DebugStart; virtual;
    procedure DebugStop; virtual;
    property Debugging: Boolean read fDebugging;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TDebugLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLayerWriter - class declaration
===============================================================================}
type
  TDebugLayerWriter = class(TLSLayerWriter)
  protected
    fDebugging: Boolean;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    procedure DebugStart; virtual;
    procedure DebugStop; virtual;
    property Debugging: Boolean read fDebugging;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TDebugLowLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLowLayerReader - class declaration
===============================================================================}
type
  TDebugLowLayerReader = class(TDebugLayerReader)
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TDebugHighLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugHighLayerReader - class declaration
===============================================================================}
type
  TDebugHighLayerReader = class(TDebugLayerReader)
  private
    fMemory:  Pointer;
    fSize:    LongInt;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure DebugStop; override;
    property Memory: Pointer read fMemory;
    property Size: LongInt read fSize;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TDebugLowLayerWriter                              
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLowLayerWriter - class declaration
===============================================================================}
type
  TDebugLowLayerWriter = class(TDebugLayerWriter)
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TDebugHighLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugHighLayerWriter - class declaration
===============================================================================}
type
  TDebugHighLayerWriter = class(TDebugLayerWriter)
  private
    fMemory:  Pointer;
    fSize:    LongInt;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property Memory: Pointer read fMemory;
    property Size: LongInt read fSize;
  end;

implementation

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

const
  DEBUGLAYER_SIZE_DEFAULT = 1024;  // 1KiB

{===============================================================================
--------------------------------------------------------------------------------
                               TDebugLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugLayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TDebugLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fDebugging := False;
end;

//------------------------------------------------------------------------------

procedure TDebugLayerReader.DebugStart;
begin
fDebugging := True;
end;

{-------------------------------------------------------------------------------
    TDebugLayerReader - public methods
-------------------------------------------------------------------------------}

procedure TDebugLayerReader.DebugStop;
begin
fDebugging := False;
end;


{===============================================================================
--------------------------------------------------------------------------------
                               TDebugLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugLayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TDebugLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fDebugging := False;
end;

//------------------------------------------------------------------------------

procedure TDebugLayerWriter.DebugStart;
begin
fDebugging := True;
end;

{-------------------------------------------------------------------------------
    TDebugLayerWriter - public methods
-------------------------------------------------------------------------------}

procedure TDebugLayerWriter.DebugStop;
begin
fDebugging := False;
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TDebugLowLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLowLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugLowLayerReader - protected methods
-------------------------------------------------------------------------------}

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TDebugLowLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := Random(DEBUGLAYER_SIZE_DEFAULT + 1);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

Function TDebugLowLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
var
  BuffPtr:  PByte;
  i:        Integer;
begin
If fDebugging then
  begin
    // decide whether to fill entire buffer, its part, or return nothing at all
    case Random(5) of // 0..4
      0:  Result := 0;
      4:  Result := Size;
    else
      Result := Random(Size) + 1;
    end;
    // fill the output
    If Result > 0 then
      begin
        BuffPtr := @Buffer;
        For i := 1 to Result do
          begin
            BuffPtr^ := Byte(Random(256));
            Inc(BuffPtr);
          end;
      end;
    // do not propagate reading to next layer
  end
else Result := 0;
end;

//------------------------------------------------------------------------------

procedure TDebugLowLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
Randomize;
end;

{-------------------------------------------------------------------------------
    TDebugLowLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TDebugLowLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopDebug];
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TDebugHighLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugHighLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugHighLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TDebugHighLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TDebugHighLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
{
  buffer and size are ignored, internal buffer is used and size is randomized,
  return value is a true return value from a call to ReadOut

  not that buffer can be nil^ since it is not accessed in any way
}
If fDebugging then
  begin
    FillChar(fMemory^,fSize,0);
    // decide whether to read full buffer, nothing, or something in between
    case Random(5) of // 0..4
      0:  Size := 0;
      4:  Size := fSize;
    else
      Size := Random(fSize) + 1;
    end;
    // do reading
    Result := ReadOut(fMemory^,Size);
  end
else Result := ReadOut(fMemory^,fSize);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TDebugHighLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
Randomize;
fSize := DEBUGLAYER_SIZE_DEFAULT;
If Assigned(Params) then
  If Params.Exists('TDebugHighLayerReader.Size',nvtInteger) then
    fSize := Params.IntegerValue['TDebugHighLayerReader.Size'];
GetMem(fMemory,fSize);
end;

//------------------------------------------------------------------------------

procedure TDebugHighLayerReader.Finalize;
begin
FreeMem(fMemory,fSize);
inherited;
end;

{-------------------------------------------------------------------------------
    TDebugHighLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TDebugHighLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopDebug];
end;

//------------------------------------------------------------------------------

class Function TDebugHighLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TDebugHighLayerReader.Size',nvtInteger,[loprConstructor]);
end;

//------------------------------------------------------------------------------

procedure TDebugHighLayerReader.DebugStop;
begin
fDebugging := False;
while ReadOut(fMemory^,fSize) <> 0 do;
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TDebugLowLayerWriter                              
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugLowLayerWriter - class declaration
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugLowLayerWriter - protected methods
-------------------------------------------------------------------------------}

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TDebugLowLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := Random(DEBUGLAYER_SIZE_DEFAULT + 1);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TDebugLowLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
{
  decide whether to write entire buffer, its part, or nothing at all
  do not propagate writing to next layer, discard the actual data
}
If fDebugging then
  case Random(5) of // 0..4
    0:  Result := 0;
    4:  Result := Size;
  else
    Result := Random(Size) + 1;
  end
else Result := Size;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TDebugLowLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
Randomize;
end;

{-------------------------------------------------------------------------------
    TDebugLowLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TDebugLowLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopDebug];
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TDebugHighLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDebugHighLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDebugHighLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TDebugHighLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TDebugHighLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
var
  BuffPtr:  PByte;
  i:        Integer;
begin
If fDebugging then
  begin
    FillChar(fMemory^,fSize,0);
    // decide whether to pass entire buffer, its part, or nothing
    case Random(5) of // 0..4
      0:  Size := 0;
      4:  Size := fSize;
    else
      Size := Random(fSize) + 1;
    end;
    // fill buffer
    If Size > 0 then
      begin
        BuffPtr := fMemory;
        For i := 1 to Size do
          begin
            BuffPtr^ := Byte(Random(256));
            Inc(BuffPtr);
          end;
      end;
    // pass it to the next layer for writing
    Result := WriteOut(fMemory^,Size);
  end
else Result := WriteOut(fMemory^,0);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TDebugHighLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
Randomize;
fSize := DEBUGLAYER_SIZE_DEFAULT;
If Assigned(Params) then
  If Params.Exists('TDebugHighLayerWriter.Size',nvtInteger) then
    fSize := Params.IntegerValue['TDebugHighLayerWriter.Size'];
GetMem(fMemory,fSize);
end;

//------------------------------------------------------------------------------

procedure TDebugHighLayerWriter.Finalize;
begin
FreeMem(fMemory,fSize);
inherited;
end;

{-------------------------------------------------------------------------------
    TDebugHighLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TDebugHighLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopDebug];
end;

//------------------------------------------------------------------------------

class Function TDebugHighLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TDebugHighLayerWriter.Size',nvtInteger,[loprConstructor]);
end;


end.
