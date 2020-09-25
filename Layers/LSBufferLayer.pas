unit LSBufferLayer;

{$message 'add ConnectedBuffer(Writer/Reader)'}

interface

uses
  Classes,
  SimpleNamedValues,
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                               TBufferLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBufferLayerReader - class declaration
===============================================================================}
type
  TBufferLayerReader = class(TLSLayerReader)
  private
    fMemory:  Pointer;
    fSize:    LongInt;
    fUsed:    LongInt;
    fOffset:  LongInt;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectKind: TLSLayerObjectKind; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Flush; override;
    property Memory: Pointer read fMemory;
    property Size: LongInt read fSize;
    property Used: LongInt read fUsed;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TBufferLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBufferLayerWriter - class declaration
===============================================================================}
type
  TBufferLayerWriter = class(TLSLayerWriter)
  private
    fMemory:  Pointer;
    fSize:    LongInt;
    fUsed:    LongInt;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectKind: TLSLayerObjectKind; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Flush; override;
    property Memory: Pointer read fMemory;
    property Size: LongInt read fSize;
    property Used: LongInt read fUsed;
  end;

implementation

uses
  Math,
  AuxTypes;

{===============================================================================
--------------------------------------------------------------------------------
                               TBufferLayerReader
--------------------------------------------------------------------------------
===============================================================================}
const
  LS_BUFFERLAYERREADER_SIZE = 1024 * 1024;  // 1MiB

{===============================================================================
    TBufferLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TBufferLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TBufferLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Flush;
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TBufferLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
var
  BytesRead:  LongInt;
begin
{$message 'revisit'}
// if buffer is empty, fill it
If fUsed <= 0 then
  begin
    fUsed := ReadOut(fMemory^,fSize);
    fOffset := 0;
  end;
// now for the fun stuff...
If Size <= fUsed then
  begin
  {
    all required data are buffered
  }
    Move(Pointer(PtrUInt(fMemory) + PtrUInt(fOffset))^,Buffer,Size);
    fUsed := fUsed - Size;
    If fUsed <> 0 then
      fOffset := fOffset + Size
    else
      fOffset := 0;
    Result := Size;
  end
else If Size <= fSize then
  begin
  {
    not all required data are buffered, but can all fit into allocated buffer
  }
    If fUsed <> 0 then
      Move(Pointer(PtrUInt(fMemory) + PtrUInt(fOffset))^,Buffer,fUsed);
    fOffset := 0;
    If (Size - fUsed) <= (fSize shr 1) then
      begin
        // remaining required size is smaller or equal than 1/2 of the buffer
        BytesRead := ReadOut(fMemory^,fSize);
        fOffset := Min(BytesRead,Size - fUsed);
        Move(fMemory^,Pointer(PtrUInt(@Buffer) + PtrUInt(fUsed))^,fOffset);
        Result := fUsed + fOffset;
        fUsed := BytesRead - fOffset;
      end
    else
      begin
        // remaining required size is larger than 1/2 of the buffer
        BytesRead := ReadOut(Pointer(PtrUInt(@Buffer) + PtrUInt(fUsed))^,Size - fUsed);
        Result := fUsed + BytesRead;
        fUsed := 0;
      end;
  end
else
  begin
  {
    required data not buffered and required size is larger than size of the
    allocated buffer
  }
    If fUsed <> 0 then
      Move(Pointer(PtrUInt(fMemory) + PtrUInt(fOffset))^,Buffer,fUsed);
    BytesRead := ReadOut(Pointer(PtrUInt(@Buffer) + PtrUInt(fUsed))^,Size - fUsed);
    Result := BytesRead + fUsed;
    fUsed := 0;
    fOffset := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TBufferLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fSize := LS_BUFFERLAYERREADER_SIZE;
If Assigned(Params) then
  If Params.Exists('TBufferLayerReader.Size',nvtInteger) then
    fSize := LongInt(Params.IntegerValue['TBufferLayerReader.Size']);
GetMem(fMemory,fSize);
fUsed := 0;
fOffset := 0;
end;

//------------------------------------------------------------------------------

procedure TBufferLayerReader.Finalize;
begin
FreeMem(fMemory,fSize);
inherited;
end;

{-------------------------------------------------------------------------------
    TBufferLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TBufferLayerReader.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobAccumulator];
end;

//------------------------------------------------------------------------------

class Function TBufferLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TBufferLayerReader.Size',nvtInteger,[loprConstructor],'Size of the memory buffer');
end;

//------------------------------------------------------------------------------

procedure TBufferLayerReader.Flush;
begin
inherited;
// discard everything still in the buffer and seek back the buffered amount
If fActive and (fUsed > 0) then
  SeekOut(-fUsed,soCurrent);
fUsed := 0;
fOffset := 0;
end;


{===============================================================================
--------------------------------------------------------------------------------
                               TBufferLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
const
  LS_BUFFERLAYERWRITER_SIZE = 1024 * 1024;  // 1MiB

{===============================================================================
    TBufferLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TBufferLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TBufferLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Flush;
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TBufferLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
var
  BytesWritten: LongInt;
begin
{$message 'revisit'}
If Size <= (fSize - fUsed) then
  begin
  {
    data will fit free space in the buffer
  }
    Move(Buffer,Pointer(PtrUInt(fMemory) + PtrUInt(fUsed))^,Size);
    fUsed := fUsed + Size;
    Result := Size;
  end
else If Size < fSize then
  begin
  {
    data won't fit free space, but are smaller than allocated buffer
  }
    If fUsed > 0 then
      begin
        // some data are buffered
        BytesWritten := WriteOut(fMemory^,fUsed);
        If BytesWritten < fUsed then
          begin
            // only part of the buffered data was written, buffer at least part of new data
            Move(Pointer(PtrUInt(fMemory) + PtrUInt(BytesWritten))^,fMemory^,fUsed - BytesWritten);
            fUsed := fUsed - BytesWritten;
            If Size <= (fSize - fUsed) then
              begin
                // whole new data will now fit into free space
                Move(Buffer,Pointer(PtrUInt(fMemory) + PtrUInt(fUsed))^,Size);
                fUsed := fUsed + Size;
                Result := Size;
              end
            else
              begin
                // only part of the new data can fit
                Result := Min(fSize - fUsed,Size);
                Move(Buffer,Pointer(PtrUInt(fMemory) + PtrUInt(fUsed))^,Result);
                fUsed := fUsed + Result;
              end;
          end
        else
          begin
            // all buffered data were written, buffer new data
            Move(Buffer,fMemory^,Size);
            fUsed := Size;
            Result := Size;
          end;
      end
    else
      begin
        // nothing is buffered (this should never occur here, but whatever...)
        Move(Buffer,fMemory^,Size);
        fUsed := Size;
        Result := Size;
      end;
  end
else
  begin
  {
    data won't fit free space and are larger than allocated buffer
  }
    If fUsed > 0 then
      begin
        BytesWritten := WriteOut(fMemory^,fUsed);
        If BytesWritten < fUsed then
          begin
            // only part of the buffered data was written
            Move(Pointer(PtrUInt(fMemory) + PtrUInt(BytesWritten))^,fMemory^,fUsed - BytesWritten);
            fUsed := fUsed - BytesWritten;
            // buffer part of new data
            Result := fSize - fUsed;
            Move(Buffer,Pointer(PtrUInt(fMemory) + PtrUInt(fUsed))^,Result);
            fUsed := fSize;
          end
        else
          begin
            // all buffered data were written
            fUsed := 0;
            Result := WriteOut(Buffer,Size);
          end;
      end
    else Result := WriteOut(Buffer,Size);
  end;
// if the buffer is full, try to flush it
If fUsed >= fSize then
  begin
    BytesWritten := WriteOut(fMemory^,fSize);
    If BytesWritten < fSize then
      begin
        Move(Pointer(PtrUInt(fMemory) + PtrUInt(BytesWritten))^,fMemory^,fSize - BytesWritten);
        fUsed := fSize - BytesWritten;
      end
    else fUsed := 0
  end;
end;

//------------------------------------------------------------------------------

procedure TBufferLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fSize := LS_BUFFERLAYERWRITER_SIZE;
If Assigned(Params) then
  If Params.Exists('TBufferLayerWriter.Size',nvtInteger) then
    fSize := LongInt(Params.IntegerValue['TBufferLayerWriter.Size']);
GetMem(fMemory,fSize);
fUsed := 0;
end;

//------------------------------------------------------------------------------

procedure TBufferLayerWriter.Finalize;
begin
FreeMem(fMemory,fSize);
inherited;
end;

{-------------------------------------------------------------------------------
    TBufferLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TBufferLayerWriter.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobAccumulator];
end;

//------------------------------------------------------------------------------

class Function TBufferLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TBufferLayerWriter.Size',nvtInteger,[loprConstructor],'Size of the memory buffer');
end;

//------------------------------------------------------------------------------

procedure TBufferLayerWriter.Flush;
begin
inherited;
If fActive and (fUsed > 0) then
  If WriteOut(fMemory^,fUsed) <> fUsed then
    raise EWriteError.Create('TBufferLayerWriter.Flush: Failed to flush all buffered data.');
fUsed := 0;
end;

end.
