{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - Buffer layer

    Buffers read or written data.

    Can be used eg. for buffering when reading/writing large number of small
    data blocks to/from a file.

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
unit LayeredStream_BufferLayer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues,
  LayeredStream_Layers;

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
    fMemory:    Pointer;
    fSize:      LongInt;
    fUsed:      LongInt;
    fOffset:    LongInt;
    fStartPos:  Int64;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure InternalFinal; override;
    procedure Flush; override;
    procedure Final; override; // only calls Flush
    Function SeekInternal(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property Memory: Pointer read fMemory;
    property Size: LongInt read fSize;
    property Used: LongInt read fUsed;
    property Offset: LongInt read fOffset;
  {
    StartPos is a position in the underlying stream where the currently
    buffered data starts (all data from the start of the buffer, not just from
    offset - it is threfore equivalent to position before last read).
    If nothing is buffered, it will be set to a negative value.
  }
    property StartPos: Int64 read fStartPos;
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
    fMemory:    Pointer;
    fSize:      LongInt;
    fUsed:      LongInt;
    fStartPos:  Int64;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure InternalFinal; override;
    procedure Flush; override;
    procedure Final; override;
    Function SeekInternal(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property Memory: Pointer read fMemory;
    property Size: LongInt read fSize;
    property Used: LongInt read fUsed;
  {
    StartPos is a position in the underlying stream where the currently
    buffered data will be written on next write.
    If nothing is buffered, it will be set to a negative value.
  }    
    property StartPos: Int64 read fStartPos;    
  end;

implementation

uses
  Math,
  AuxTypes,
  LayeredStream;

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
  LS_READER_BUFF_SIZE = 1024 * 1024;  // 1MiB

{===============================================================================
    TBufferLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TBufferLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TBufferLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
// should be flushed by layered stream at this point
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
If Size > 0 then
  begin
    // if buffer is empty, try to fill it
    If fUsed <= 0 then
      begin
        fStartPos := SeekInternal(0,soCurrent);
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
        If fUsed <= 0 then
          begin
            // buffer is now empty
            fOffset := 0;
            fStartPos := Low(Int64);
          end
        // some data are left in the buffer
        else fOffset := fOffset + Size;
        Result := Size;
      end
    else If Size <= fSize then
      begin
      {
        not all required data are buffered, but can all fit into allocated
        buffer - copy whatever is buffered to the output...
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
        // buffer is now empty
        fOffset := 0;
        fStartPos := Low(Int64);
        If (Size - BytesCopied) <= (fSize shr 1) then
          begin
          {
            remaining required size is smaller or equal than 1/2 of the buffer -
            try to fill the buffer and move the remaining data (or at least part
            of them) to the output
          }
            fStartPos := SeekInternal(0,soCurrent);
            BytesRead := ReadOut(fMemory^,fSize);
            BytesToCopy := Min(BytesRead,Size - BytesCopied);
          {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
            Move(fMemory^,Pointer(PtrUInt(@Buffer) + PtrUInt(BytesCopied))^,BytesToCopy);
          {$IFDEF FPCDWM}{$POP}{$ENDIF}
            fUsed := BytesRead - BytesToCopy;
            If fUsed <= 0 then
              begin
                // buffer is empty
                fOffset := 0;
                fStartPos := Low(Int64);
              end
            // buffer still contains data
            else fOffset := BytesToCopy;
            Result := BytesCopied + BytesToCopy;
          end
        else
          begin
          {
            remaining required size is larger than 1/2 of the buffer - try read
            the rest directly to the output
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
        allocated buffer - copy what is buffered and then try read the rest
        directly to the output
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
        fStartPos := Low(Int64);
      {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
        BytesRead := ReadOut(Pointer(PtrUInt(@Buffer) + PtrUInt(BytesCopied))^,Size - BytesCopied);
      {$IFDEF FPCDWM}{$POP}{$ENDIF}
        Result := BytesCopied + BytesRead;
      end;
  end
else Result := 0;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TBufferLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fSize := LS_READER_BUFF_SIZE;
GetIntegerNamedValue(Params,'TBufferLayerReader.Size',fSize);
GetMem(fMemory,fSize);
fUsed := 0;
fOffset := 0;
fStartPos := Low(Int64);
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
Result := [lopNeedsFlush,lopPassthrough,lopDelayer];
end;

//------------------------------------------------------------------------------

class Function TBufferLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TBufferLayerReader.Size',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

procedure TBufferLayerReader.InternalFinal;
begin
Flush;
inherited;
end;

//------------------------------------------------------------------------------

procedure TBufferLayerReader.Flush;
var
  Temp: LongInt;
begin
inherited;
If fActive then
  begin
    Temp := fUsed;
    fUsed := 0;
    fOffset := 0;
    fStartPos := Low(Int64); // nothing is buffered anymore
    // discard everything still in the buffer and seek back the buffered amount
    If Temp > 0 then
      SeekInternal(-Temp,soCurrent);
  end;
end;

//------------------------------------------------------------------------------

procedure TBufferLayerReader.Final;
begin
Flush;
end;

//------------------------------------------------------------------------------

Function TBufferLayerReader.SeekInternal(const Offset: Int64; Origin: TSeekOrigin): Int64;

  Function FlushAndSeek(const Offset: Int64; Origin: TSeekOrigin): Int64;
  begin
    Flush;
    Result := inherited SeekInternal(Offset,Origin);
  end;

begin
If fActive and (fUsed <> 0) and (fStartPos >= 0) then
  case Origin of
    soBeginning:  If (Offset >= fStartPos) and (Offset < (fStartPos + fOffset + fUsed)) then
                    begin
                      // seek into buffer
                      fUsed := (fOffset + fUsed) - LongInt(Offset - fStartPos);
                      fOffset := LongInt(Offset - fStartPos);
                      Result := Offset;
                    end
                  // seek outside of the buffer                    
                  else Result := FlushAndSeek(Offset,Origin);

    soCurrent:    If Offset = 0 then
                    // seek to current position (start of buffer)
                    Result := fStartPos + Int64(fOffset)
                  else If (Offset >= -fOffset) and (Offset < fUsed) then
                    begin
                      // seek into buffer
                      fUsed := fUsed - Offset;
                      fOffset := fOffset + LongInt(Offset);
                      Result := StartPos + fOffset;
                    end
                  // seek outside of the buffer
                  else Result := FlushAndSeek(Offset,Origin);
  {
    There is no way of knowing where the stream ends in relation to currently
    buffered data, so flush and do normal seek.
  }
    soEnd:        Result := FlushAndSeek(Offset,Origin);
  else
    Result := FlushAndSeek(Offset,Origin);
  end
else Result := inherited SeekInternal(Offset,Origin); // no flush needed
end;


{===============================================================================
--------------------------------------------------------------------------------
                               TBufferLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
const
  LS_WRITER_BUFF_SIZE = 1024 * 1024;  // 1MiB

{===============================================================================
    TBufferLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TBufferLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TBufferLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
// should be flushed by layered stream at this point
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TBufferLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
var
  BytesWritten: LongInt;
  BytesToWrite: LongInt;

  procedure ShiftBuffer(Amount: LongInt);
  begin
  {
    Called when part of the buffer was consumed (written) and the remaining
    data needs to be shifted down.
    Parameter Amount indicates number of bytes consumed.
  }
    If (fUsed - Amount) > 0 then
    {$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
      Move(Pointer(PtrUInt(fMemory) + PtrUInt(Amount))^,fMemory^,fUsed - Amount);
    {$IFDEF FPCDWM}{$POP}{$ENDIF}
    fUsed := fUsed - Amount;
    If fUsed <> 0 then
      begin
        If fStartPos < 0 then
          fStartPos := SeekInternal(0,soCurrent)
        else
          fStartPos := fStartPos + Amount;
      end
    else fStartPos := Low(Int64);
  end;

begin
If Size > 0 then
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
        If (fUsed <> 0) and (fStartPos < 0) then
          fStartPos := SeekInternal(0,soCurrent);
        Result := Size;
      end
    else If Size < fSize then
      begin
      {
        data won't fit free space, but are smaller than allocated buffer - try
        to write what is buffered, when successful, buffer new data, when
        unsuccessful, buffer at least part of the new data
      }
        BytesWritten := WriteOut(fMemory^,fUsed);
        If BytesWritten < fUsed then
          begin
            // only part of the buffered data was written, buffer at least part of new data
            ShiftBuffer(BytesWritten);  // shift buffer also moves fStartPos
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
            fUsed := Size;  // size is always non-zero here
            If fStartPos < 0 then
              fStartPos := SeekInternal(0,soCurrent)
            else
              fStartPos := fStartPos + BytesWritten;
            Result := Size;
          end;
      end
    else
      begin
      {
        data won't fit free space and are larger than allocated buffer - if
        nothing is buffered, do direct writethrough of the new data, if
        something is in the buffer, try to write buffered data and then, when
        successful, directly write out the new data, if write of all buffered
        data was unsuccessful, buffer part of new data that can fit
      }
        If fUsed > 0 then
          begin
            BytesWritten := WriteOut(fMemory^,fUsed);
            If BytesWritten < fUsed then
              begin
                // only part of the buffered data was written...
                ShiftBuffer(BytesWritten);  // changes fStartPos
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
                fStartPos := Low(Int64);
                Result := WriteOut(Buffer,Size);
              end;
          end
        else Result := WriteOut(Buffer,Size);
      end;
    // if the buffer is full, try to flush it
    If fUsed >= fSize then
      begin
        BytesWritten := WriteOut(fMemory^,fSize);
        If BytesWritten >= fSize then
          begin
            // entire buffer was written
            fUsed := 0;
            fStartPos := Low(Int64);
          end
        else ShiftBuffer(BytesWritten); // changes fStartPos
      end;
  end
else Result := 0;
end;

//------------------------------------------------------------------------------

procedure TBufferLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fSize := LS_WRITER_BUFF_SIZE;
GetIntegerNamedValue(Params,'TBufferLayerWriter.Size',fSize);
GetMem(fMemory,fSize);
fUsed := 0;
fStartPos := Low(Int64);
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
Result := [lopNeedsFlush,lopPassthrough,lopDelayer];
end;

//------------------------------------------------------------------------------

class Function TBufferLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TBufferLayerWriter.Size',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

procedure TBufferLayerWriter.InternalFinal;
begin
Flush;
inherited;
end;

//------------------------------------------------------------------------------

procedure TBufferLayerWriter.Flush;
begin
inherited;
If fActive then
  begin
    If fUsed > 0 then
      If WriteOut(fMemory^,fUsed) <> fUsed then
        raise EWriteError.Create('TBufferLayerWriter.Flush: Failed to flush all buffered data.');
    fUsed := 0;
    fStartPos := Low(Int64);
  end;
end;

//------------------------------------------------------------------------------

procedure TBufferLayerWriter.Final;
begin
Flush;
end;

//------------------------------------------------------------------------------

Function TBufferLayerWriter.SeekInternal(const Offset: Int64; Origin: TSeekOrigin): Int64;

  Function FlushAndSeek(const Offset: Int64; Origin: TSeekOrigin): Int64;
  begin
    Flush;
    Result := inherited SeekInternal(Offset,Origin);
  end;

begin
If fActive and (fUsed <> 0) and (fStartPos >= 0) then
  case Origin of
    soBeginning:  If Offset = fStartPos + fUsed then
                    // seek to current position (end of buffer), do nothing
                    Result := Offset
                  else
                  {
                    Seeking outside of the buffered data is clear enough - flush
                    and the pass seek request further.
                    Why not to seek into the buffer is more complex - as this
                    is writer, everything buffered is actually supposed to be
                    already written into the underlying stream. And because
                    seek into the buffer would inevitably discard some data, it
                    cannot be allowed.
                  }
                    Result := FlushAndSeek(Offset,Origin);

    soCurrent:    If Offset = 0 then
                    Result := fStartPos + fUsed // seek to current position
                  else
                    Result := FlushAndSeek(Offset,Origin);
  {
    There is no way of knowing where the stream ends in relation to currently
    buffered data, so flush and do normal seek.
  }
    soEnd:        Result := FlushAndSeek(Offset,Origin);
  else
    Result := FlushAndSeek(Offset,Origin);
  end
else Result := inherited SeekInternal(Offset,Origin);
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_Buffer',TBufferLayerReader,TBufferLayerWriter);

end.
