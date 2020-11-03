unit LayeredStream_BufferLayer;

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
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
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
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
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

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W4055:={$WARN 4055 OFF}} // Conversion between ordinals and pointers is not portable
  {$DEFINE W5058:={$WARN 5058 OFF}} // Variable "$1" does not seem to be initialized
{$ENDIF}

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

{$IFDEF FPCDWM}{$PUSH}W5058{$ENDIF}
Function TBufferLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
var
  BytesRead:    LongInt;
  BytesCopied:  LongInt;
  BytesToCopy:  LongInt;
begin
// if buffer is empty, try to fill it
If fUsed <= 0 then
  begin
    fUsed := ReadOut(fMemory^,fSize);
    fOffset := 0;
  end;
// now for the fun stuff...
If Size <= fUsed then
  begin
  {
    all required data are buffered - just copy them to the output
  }
  {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
    Move(Pointer(PtrUInt(fMemory) + PtrUInt(fOffset))^,Buffer,Size);
  {$IFDEF FPCDWM}{$POP}{$ENDIF}
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
    not all required data are buffered, but can all fit into allocated buffer -
    copy whatever is buffered to the output...
  }
    If fUsed <> 0 then
      begin
      {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
        Move(Pointer(PtrUInt(fMemory) + PtrUInt(fOffset))^,Buffer,fUsed);
      {$IFDEF FPCDWM}{$POP}{$ENDIF}
        BytesCopied := fUsed;
        fUsed := 0;
      end
    else BytesCopied := 0;
    fOffset := 0;
    If (Size - BytesCopied) <= (fSize shr 1) then
      begin
      {
        remaining required size is smaller or equal than 1/2 of the buffer - try
        to fill the buffer and move the remaining data (or at least part of
        them) to the output
      }
        BytesRead := ReadOut(fMemory^,fSize);
        BytesToCopy := Min(BytesRead,Size - BytesCopied);
      {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
        Move(fMemory^,Pointer(PtrUInt(@Buffer) + PtrUInt(BytesCopied))^,BytesToCopy);
      {$IFDEF FPCDWM}{$POP}{$ENDIF}
        fUsed := BytesRead - BytesToCopy;
        fOffset := BytesToCopy;
        Result := BytesCopied + BytesToCopy;        
      end
    else
      begin
      {
        remaining required size is larger than 1/2 of the buffer - try read the
        rest directly to the output
      }
      {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
        BytesRead := ReadOut(Pointer(PtrUInt(@Buffer) + PtrUInt(BytesCopied))^,Size - BytesCopied);
      {$IFDEF FPCDWM}{$POP}{$ENDIF}
        Result := BytesCopied + BytesRead;
      end;
  end
else
  begin
  {
    required data not buffered and required size is larger than size of the
    allocated buffer - copy what is buffered and then try read the rest directly
    to the output
  }
    If fUsed <> 0 then
      begin
      {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
        Move(Pointer(PtrUInt(fMemory) + PtrUInt(fOffset))^,Buffer,fUsed);
      {$IFDEF FPCDWM}{$POP}{$ENDIF}
        BytesCopied := fUsed;
        fUsed := 0;
      end
    else BytesCopied := 0;
    fOffset := 0;
  {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
    BytesRead := ReadOut(Pointer(PtrUInt(@Buffer) + PtrUInt(BytesCopied))^,Size - BytesCopied);
  {$IFDEF FPCDWM}{$POP}{$ENDIF}
    Result := BytesCopied + BytesRead;
  end;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

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

class Function TBufferLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopPassthrough,lopDelayer];
end;

//------------------------------------------------------------------------------

class Function TBufferLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TBufferLayerReader.Size',nvtInteger,[loprConstructor]);
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
  BytesToWrite: LongInt;
begin
If Size <= (fSize - fUsed) then
  begin
  {
    data will fit free space in the buffer - just copy them to the buffer
  }
  {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
    Move(Buffer,Pointer(PtrUInt(fMemory) + PtrUInt(fUsed))^,Size);
  {$IFDEF FPCDWM}{$POP}{$ENDIF}
    fUsed := fUsed + Size;
    Result := Size;
  end
else If Size < fSize then
  begin
  {
    data won't fit free space, but are smaller than allocated buffer - try to
    write what is buffered, when successful, buffer new data, when unsuccessful,
    buffer at least part of the new data
  }
    BytesWritten := WriteOut(fMemory^,fUsed);
    If BytesWritten < fUsed then
      begin
        // only part of the buffered data was written, buffer at least part of new data
      {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
        Move(Pointer(PtrUInt(fMemory) + PtrUInt(BytesWritten))^,fMemory^,fUsed - BytesWritten);
      {$IFDEF FPCDWM}{$POP}{$ENDIF}
        fUsed := fUsed - BytesWritten;
        If Size <= (fSize - fUsed) then
          begin
            // whole new data will now fit into free space - buffer them
          {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
            Move(Buffer,Pointer(PtrUInt(fMemory) + PtrUInt(fUsed))^,Size);
          {$IFDEF FPCDWM}{$POP}{$ENDIF}
            fUsed := fUsed + Size;
            Result := Size;
          end
        else
          begin
            // only part of the new data can fit
            BytesToWrite := fSize - fUsed;
          {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
            Move(Buffer,Pointer(PtrUInt(fMemory) + PtrUInt(fUsed))^,BytesToWrite);
          {$IFDEF FPCDWM}{$POP}{$ENDIF}
            fUsed := fSize;
            Result := BytesToWrite;
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
  {
    data won't fit free space and are larger than allocated buffer - try to
    write buffered data and then, when successful, directly write out the new
    data, if unsuccessful, buffer part of new data that can fit
  }
    If fUsed > 0 then
      begin
        BytesWritten := WriteOut(fMemory^,fUsed);
        If BytesWritten < fUsed then
          begin
            // only part of the buffered data was written...
          {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
            Move(Pointer(PtrUInt(fMemory) + PtrUInt(BytesWritten))^,fMemory^,fUsed - BytesWritten);
          {$IFDEF FPCDWM}{$POP}{$ENDIF}
            fUsed := fUsed - BytesWritten;
            // ...buffer part of new data
            BytesToWrite := fSize - fUsed;
          {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
            Move(Buffer,Pointer(PtrUInt(fMemory) + PtrUInt(fUsed))^,BytesToWrite);
          {$IFDEF FPCDWM}{$POP}{$ENDIF}
            fUsed := fSize;
            Result := BytesToWrite;
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
      {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
        Move(Pointer(PtrUInt(fMemory) + PtrUInt(BytesWritten))^,fMemory^,fSize - BytesWritten);
      {$IFDEF FPCDWM}{$POP}{$ENDIF}
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

class Function TBufferLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopPassthrough,lopDelayer];
end;

//------------------------------------------------------------------------------

class Function TBufferLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TBufferLayerWriter.Size',nvtInteger,[loprConstructor]);
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
