unit LSBufferLayer;

{$message 'add ConnectedBuffer(Writer/Reader)'}

interface

uses
  Classes,
  SimpleNamedValues,
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                  TBufferReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBufferReader - class declaration
===============================================================================}
type
  TBufferReader = class(TLSLayerReader)
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
                                  TBufferWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TBufferWriter - class declaration
===============================================================================}
type
  TBufferWriter = class(TLSLayerWriter)
  private
    fAllowPartialWrites:  Boolean;
    fMemory:              Pointer;
    fSize:                LongInt;
    fUsed:                LongInt;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectKind: TLSLayerObjectKind; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Flush; override;
    property AllowPartialWrites: Boolean read fAllowPartialWrites write fAllowPartialWrites;
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
                                  TBufferReader
--------------------------------------------------------------------------------
===============================================================================}
const
  LS_BUFFERREADER_BUFFERSIZE = 1024 * 1024; // 1MiB

{===============================================================================
    TBufferReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TBufferReader - protected methods
-------------------------------------------------------------------------------}

Function TBufferReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Flush;
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TBufferReader.ReadActive(out Buffer; Size: LongInt): LongInt;
var
  BytesRead:  LongInt;
begin
{$message 'implement'}
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
        // remaining required size is smaller or equal than 1/2 of buffer
        BytesRead := ReadOut(fMemory^,fSize);
        Move(fMemory^,Pointer(PtrUInt(@Buffer) + PtrUInt(fUsed))^,Min(BytesRead,Size - fUsed));

        //fOffset := fUsed -
      end
    else
      begin
        // remaining required size is larger than 1/2 of buffer
        BytesRead := ReadOut(Pointer(PtrUInt(@Buffer) + PtrUInt(fUsed))^,Size - fUsed);
        Result := fUsed + BytesRead;
        fUsed := 0;
      end;

    {$message 'change'}
    (*
    If fUsed <> 0 then
      Move(Pointer(PtrUInt(fMemory) + PtrUInt(fOffset))^,fMemory^,fUsed);
    fOffset := 0;
    BytesRead := ReadOut(Pointer(PtrUInt(fMemory) + PtrUInt(fOffset))^,fSize - fUsed);
    fUsed := fUsed + BytesRead;
    If fUsed < Size then
      begin
        // buffer does not contain enough data for read
        Move(fMemory^,Buffer,fUsed);
        fUsed := 0;
        fOffset := 0;
        Result := fUsed;
      end
    else
      begin
        // buffer contains enough data for read
        Move(fMemory^,Buffer,Size);
        fUsed := fUsed - Size;
        fOffset := Size;
        Result := Size;
      end;
    *)  
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

procedure TBufferReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fSize := LS_BUFFERREADER_BUFFERSIZE;
If Assigned(Params) then
  If Params.Exists('TBufferReader.Size',nvtInteger) then
    fSize := LongInt(Params.IntegerValue['TBufferReader.Size']);
GetMem(fMemory,fSize);
fUsed := 0;
fOffset := 0;
end;

//------------------------------------------------------------------------------

procedure TBufferReader.Finalize;
begin
FreeMem(fMemory,fSize);
inherited;
end;

{-------------------------------------------------------------------------------
    TBufferReader - public methods
-------------------------------------------------------------------------------}

class Function TBufferReader.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobAccumulator];
end;

//------------------------------------------------------------------------------

class Function TBufferReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TBufferReader.Size',nvtInteger,[loprConstructor],'Size of the memory buffer');
end;

//------------------------------------------------------------------------------

procedure TBufferReader.Flush;
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
                                  TBufferWriter
--------------------------------------------------------------------------------
===============================================================================}
const
  LS_BUFFERWRITER_BUFFERSIZE = 1024 * 1024; // 1MiB

{===============================================================================
    TBufferWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TBufferWriter - protected methods
-------------------------------------------------------------------------------}

Function TBufferWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Flush;
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TBufferWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
var
  BytesWritten: LongInt;
begin
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
                If fAllowPartialWrites then
                  begin
                    // store the part that can fit
                    Result := Min(fSize - fUsed,Size);
                    Move(Buffer,Pointer(PtrUInt(fMemory) + PtrUInt(fUsed))^,Result);
                    fUsed := fUsed + Result;
                  end
                else Result := 0; // partial write is not allowed, don't write anything
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
            If fAllowPartialWrites then
              begin
                // buffer part of new data
                Result := fSize - fUsed;
                Move(Buffer,Pointer(PtrUInt(fMemory) + PtrUInt(fUsed))^,Result);
                fUsed := fSize;
              end
            else Result := 0;
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

procedure TBufferWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fAllowPartialWrites := False;
fSize := LS_BUFFERWRITER_BUFFERSIZE;
If Assigned(Params) then
  begin
    If Params.Exists('TBufferWriter.Size',nvtInteger) then
      fSize := LongInt(Params.IntegerValue['TBufferWriter.Size']);
    If Params.Exists('TBufferWriter.AllowPartialWrites',nvtBool) then
      fAllowPartialWrites := Params.BoolValue['TBufferWriter.AllowPartialWrites'];
  end;
GetMem(fMemory,fSize);
fUsed := 0;
end;

//------------------------------------------------------------------------------

procedure TBufferWriter.Finalize;
begin
FreeMem(fMemory,fSize);
inherited;
end;

{-------------------------------------------------------------------------------
    TBufferWriter - public methods
-------------------------------------------------------------------------------}

class Function TBufferWriter.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobAccumulator];
end;

//------------------------------------------------------------------------------

class Function TBufferWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TBufferWriter.Size',nvtInteger,[loprConstructor],'Size of the memory buffer');
Result[1] := LayerObjectParam('TBufferWriter.AllowPartialWrites',nvtInteger,[loprConstructor],'Enables partial data writing');
end;

//------------------------------------------------------------------------------

procedure TBufferWriter.Flush;
begin
inherited;
If fActive and (fUsed > 0) then
  If WriteOut(fMemory^,fUsed) <> fUsed then
    raise EWriteError.Create('TBufferWriter.Flush: Failed to flush all buffered data.');
fUsed := 0;
end;

end.
