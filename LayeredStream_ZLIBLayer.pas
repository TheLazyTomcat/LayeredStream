unit LayeredStream_ZLIBLayer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  AuxTypes, SimpleNamedValues, MemoryBuffer, ZLibUtils,
  LayeredStream_Layers;

{===============================================================================
    Values and helpers for parameters passing
===============================================================================}
const
  ZLIB_CLEVEL_DEFAULT   = 0;
  ZLIB_CLEVEL_NOCOMP    = 1;
  ZLIB_CLEVEL_BESTSPEED = 2;
  ZLIB_CLEVEL_BESTCOMP  = 3;
  ZLIB_CLEVEL_LEVEL0    = 4;
  ZLIB_CLEVEL_LEVEL1    = 5;
  ZLIB_CLEVEL_LEVEL2    = 6;
  ZLIB_CLEVEL_LEVEL3    = 7;
  ZLIB_CLEVEL_LEVEL4    = 8;
  ZLIB_CLEVEL_LEVEL5    = 9;
  ZLIB_CLEVEL_LEVEL6    = 10;
  ZLIB_CLEVEL_LEVEL7    = 11;
  ZLIB_CLEVEL_LEVEL8    = 12;
  ZLIB_CLEVEL_LEVEL9    = 13;

  ZLIB_STREAMF_DEFAULT = 0;
  ZLIB_STREAMF_ZLIB    = 1;
  ZLIB_STREAMF_GZIP    = 2;
  ZLIB_STREAMF_RAW     = 3;

Function ZLibCompLevelToInteger(Level: TZCompressionLevel): Integer;
Function ZLibCompLevelFromInteger(Value: Integer): TZCompressionLevel;

Function ZLibStreamTypeToInteger(StreamType: TZStreamType): Integer;
Function ZLibStreamTypeFromInteger(Value: Integer): TZStreamType;

{===============================================================================
--------------------------------------------------------------------------------
                                TZLIBLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBLayerReader - class declaration
===============================================================================}
type
  TZLIBLayerReader = class(TLSLayerReader)
  protected
    fProcessing:    Boolean;
    fOutputBuffer:  TMemoryBuffer;
    fReadBuffer:    TMemoryBuffer;
    fUsed:          LongInt;
    fPropagateSeek: Boolean;
    fProcessor:     TZProcessor;
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
    procedure OutputHandler(Sender: TObject; const Buffer; Size: TMemSize); virtual;
    Function ReadBuffered(out Buffer; Size: LongInt): LongInt; virtual;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Update(Params: TSimpleNamedValues); override;
    procedure Final; override;
    property Processing: Boolean read fProcessing;
    property PropagateSeek: Boolean read fPropagateSeek write fPropagateSeek;
    property Processor: TZProcessor read fProcessor;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TZLIBLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBLayerWriter - class declaration
===============================================================================}
type
  TZLIBLayerWriter = class(TLSLayerWriter)
  protected
    fProcessing:    Boolean;
    fOutputBuffer:  TMemoryBuffer;
    fUsed:          LongInt;
    fPropagateSeek: Boolean;
    fProcessor:     TZProcessor;
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
    procedure OutputHandler(Sender: TObject; const Buffer; Size: TMemSize); virtual;
    procedure WriteBuffered; virtual;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Update(Params: TSimpleNamedValues); override;
    procedure Flush; override;
    procedure Final; override;
    property Processing: Boolean read fProcessing;
    property PropagateSeek: Boolean read fPropagateSeek write fPropagateSeek;
    property Processor: TZProcessor read fProcessor;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                          TZLIBCompressionLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBCompressionLayerReader - class declaration
===============================================================================}
type
  TZLIBCompressionLayerReader = class(TZLIBLayerReader)
  private
    Function GetCompressor: TZCompressor;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property Compressor: TZCompressor read GetCompressor;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                          TZLIBCompressionLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBCompressionLayerWriter - class declaration
===============================================================================}
type
  TZLIBCompressionLayerWriter = class(TZLIBLayerWriter)
  private
    Function GetCompressor: TZCompressor;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property Compressor: TZCompressor read GetCompressor;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                         TZLIBDecompressionLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBDecompressionLayerReader - class declaration
===============================================================================}
type
  TZLIBDecompressionLayerReader = class(TZLIBLayerReader)
  private
    Function GetDecompressor: TZDecompressor;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property Decompressor: TZDecompressor read GetDecompressor;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                         TZLIBDecompressionLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBDecompressionLayerWriter - class declaration
===============================================================================}
type
  TZLIBDecompressionLayerWriter = class(TZLIBLayerWriter)
  private
    Function GetDecompressor: TZDecompressor;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property Decompressor: TZDecompressor read GetDecompressor;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
    Values and helpers for parameters passing
===============================================================================}

Function ZLibCompLevelToInteger(Level: TZCompressionLevel): Integer;
begin
case Level of
//zclNoCompression:   Result := ZLIB_CLEVEL_NOCOMP;     //  zclLevel0
//zclBestSpeed:       Result := ZLIB_CLEVEL_BESTSPEED;  //  zclLevel1
//zclBestCompression: Result := ZLIB_CLEVEL_BESTCOMP;   //  zclLevel9
  zclDefault:         Result := ZLIB_CLEVEL_DEFAULT;
  zclLevel0:          Result := ZLIB_CLEVEL_LEVEL0;
  zclLevel1:          Result := ZLIB_CLEVEL_LEVEL1;
  zclLevel2:          Result := ZLIB_CLEVEL_LEVEL2;
  zclLevel3:          Result := ZLIB_CLEVEL_LEVEL3;
  zclLevel4:          Result := ZLIB_CLEVEL_LEVEL4;
  zclLevel5:          Result := ZLIB_CLEVEL_LEVEL5;
  zclLevel6:          Result := ZLIB_CLEVEL_LEVEL6;
  zclLevel7:          Result := ZLIB_CLEVEL_LEVEL7;
  zclLevel8:          Result := ZLIB_CLEVEL_LEVEL8;
  zclLevel9:          Result := ZLIB_CLEVEL_LEVEL9;
else
  raise ELSInvalidValue.CreateFmt('ZLibCompLevelToInteger: Invalid compression level (%d).',[Ord(Level)]);
end;
end;

//------------------------------------------------------------------------------

Function ZLibCompLevelFromInteger(Value: Integer): TZCompressionLevel;
begin
case Value of
  ZLIB_CLEVEL_NOCOMP:     Result := zclNoCompression;
  ZLIB_CLEVEL_BESTSPEED:  Result := zclBestSpeed;
  ZLIB_CLEVEL_BESTCOMP:   Result := zclBestCompression;
  ZLIB_CLEVEL_DEFAULT:    Result := zclDefault;
  ZLIB_CLEVEL_LEVEL0:     Result := zclLevel0;
  ZLIB_CLEVEL_LEVEL1:     Result := zclLevel1;
  ZLIB_CLEVEL_LEVEL2:     Result := zclLevel2;
  ZLIB_CLEVEL_LEVEL3:     Result := zclLevel3;
  ZLIB_CLEVEL_LEVEL4:     Result := zclLevel4;
  ZLIB_CLEVEL_LEVEL5:     Result := zclLevel5;
  ZLIB_CLEVEL_LEVEL6:     Result := zclLevel6;
  ZLIB_CLEVEL_LEVEL7:     Result := zclLevel7;
  ZLIB_CLEVEL_LEVEL8:     Result := zclLevel8;
  ZLIB_CLEVEL_LEVEL9:     Result := zclLevel9;
else
  raise ELSInvalidValue.CreateFmt('ZLibCompLevelFromInteger: Invalid compression level (%d).',[Value]);
end;
end;

//------------------------------------------------------------------------------

Function ZLibStreamTypeToInteger(StreamType: TZStreamType): Integer;
begin
case StreamType of
  zstZLib:    Result := ZLIB_STREAMF_ZLIB;
  zstGZip:    Result := ZLIB_STREAMF_GZIP;
  zstRaw:     Result := ZLIB_STREAMF_RAW;
//zstDefault: Result := ZLIB_STREAMF_DEFAULT; //  zstZLib
else
  raise ELSInvalidValue.CreateFmt('ZLibStreamTypeToInteger: Invalid stream type (%d).',[Ord(StreamType)]);
end;
end;

//------------------------------------------------------------------------------

Function ZLibStreamTypeFromInteger(Value: Integer): TZStreamType;
begin
case Value of
  ZLIB_STREAMF_ZLIB:    Result := zstZLib;
  ZLIB_STREAMF_GZIP:    Result := zstGZip;
  ZLIB_STREAMF_RAW:     Result := zstRaw;
  ZLIB_STREAMF_DEFAULT: Result := zstDefault;
else
  raise ELSInvalidValue.CreateFmt('ZLibStreamTypeFromInteger: Invalid stream type (%d).',[Value]);
end;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TZLIBLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBLayerReader - class implementation
===============================================================================}
const
  LS_READ_OUTPUTBUFFER_DELTA = 64 * 1024; // 64KiB
  LS_READ_READBUFFER_DEFSIZE = 64 * 1024; // 64KiB

{-------------------------------------------------------------------------------
    TZLIBLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TZLIBLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
If fPropagateSeek then
  Result := SeekOut(Offset,Origin)
else
  Result := 0;
end;

//------------------------------------------------------------------------------

Function TZLIBLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
var
  ReadBytes:      LongInt;
  ProcessedBytes: UInt32;
begin
If fProcessing then
  begin
    If Size > 0 then
      begin
        If fUsed < Size then
          repeat
            ReadBytes := ReadOut(BufferMemory(fReadBuffer)^,LongInt(BufferSize(fReadBuffer)));
            ProcessedBytes := fProcessor.Update(BufferMemory(fReadBuffer)^,ReadBytes);
            If Int64(ProcessedBytes) < Int64(ReadBytes) then
              SeekOut(-(Int64(ReadBytes) - Int64(ProcessedBytes)),soCurrent);
          until (ReadBytes < LongInt(BufferSize(fReadBuffer))) or (ProcessedBytes < UInt32(ReadBytes)) or (fUsed >= Size);
        // now process what is in the buffer (if anything)
        If fUsed > 0 then
          begin
            If fUsed >= Size then
              begin
              {
                All requested data are already in the buffer, copy them from there
                and exit.
              }
                Move(BufferMemory(fOutputBuffer)^,Buffer,Size);
                Result := Size;
                If fUsed <> Size then
                  begin
                    // move remaining data down
                    Move(BufferMemory(fOutputBuffer,TMemSize(Size))^,BufferMemory(fOutputBuffer)^,fUsed - Size);
                    fUsed := fUsed - Size;
                  end
                else fUsed := 0;
              end
            else
              begin
              {
                Only part of the requested data is buffered, copy everything and
                exit.
              }
                Move(BufferMemory(fOutputBuffer)^,Buffer,fUsed);
                Result := fUsed;
                fUsed := 0;
              end;
          end
        else Result := 0;
      end
    else Result := 0;
  end
else Result := ReadBuffered(Buffer,Size);
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerReader.Initialize(Params: TSimpleNamedValues);
var
  Temp: Integer;
begin
inherited;
BufferInit(fOutputBuffer);
BufferInit(fReadBuffer);
Temp := LS_READ_READBUFFER_DEFSIZE;
GetNamedValue(Params,'TZLIBLayerReader.ReadBufferSize',Temp);
BufferGet(fReadBuffer,Temp);
fUsed := 0;
fPropagateSeek := True;
GetNamedValue(Params,'TZLIBLayerReader.PropagateSeek',fPropagateSeek);
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerReader.Finalize;
begin
fProcessor.Free;
BufferFinal(fReadBuffer);
BufferFinal(fOutputBuffer);
inherited;
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerReader.OutputHandler(Sender: TObject; const Buffer; Size: TMemSize);
begin
If Size > 0 then
  begin
    while (BufferSize(fOutputBuffer) - TMemSize(fUsed)) < Size do
      begin
        // enlarge buffer
        If BufferSize(fOutputBuffer) > 0 then
          BufferRealloc(fOutputBuffer,BufferSize(fOutputBuffer) * 2)
        else
          BufferRealloc(fOutputBuffer,LS_READ_OUTPUTBUFFER_DELTA);
      end;
    // copy data to buffer
    Move(Buffer,BufferMemory(fOutputBuffer,TMemSize(fUsed))^,Size);
    fUsed := fUsed + LongInt(Size);
  end;
end;

//------------------------------------------------------------------------------

Function TZLIBLayerReader.ReadBuffered(out Buffer; Size: LongInt): LongInt;
begin
If fUsed >= 0 then
  begin
    // some data are still buffered...
    If fUsed >= Size then
      begin
        // there is more or exactly the requested amount of data buffered
        Move(BufferMemory(fOutputBuffer)^,Buffer,Size);
        Move(BufferMemory(fOutputBuffer,TMemSize(fUsed))^,BufferMemory(fOutputBuffer)^,fUsed - Size);
        fUsed := fUsed - Size;
        Result := Size;
      end
    else
      begin
        // less than requested amount of data is buferred
        Move(BufferMemory(fOutputBuffer)^,Buffer,fUsed);
        Result := fUsed + ReadOut(Pointer(PtrUInt(@Buffer) + PtrUInt(fUsed))^,Size - fUsed);
        fUsed := 0;
      end;
  end
else Result := ReadOut(Buffer,Size);
end;

{-------------------------------------------------------------------------------
    TZLIBLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TZLIBLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopNeedsInit,lopNeedsFinal,lopProcessor,lopConsumer,lopGenerator];
end;

//------------------------------------------------------------------------------

class Function TZLIBLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TZLIBLayerReader.PropagateSeek',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TZLIBLayerReader.ReadBufferSize',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerReader.Init(Params: TSimpleNamedValues);
begin
GetNamedValue(Params,'TZLIBLayerReader.PropagateSeek',fPropagateSeek);
If not fProcessing then
  begin
    inherited;
    fUsed := 0;
    fProcessing := True;
    fProcessor.OnOutput := OutputHandler;
    fProcessor.Init;
  end;
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerReader.Update(Params: TSimpleNamedValues);
begin
inherited;
GetNamedValue(Params,'TZLIBLayerReader.PropagateSeek',fPropagateSeek);
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerReader.Final;
begin
If fProcessing then
  begin
    fProcessor.Final;
    fProcessor.OnOutput := nil;
    fProcessing := False;
    inherited;
  end;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TZLIBLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
const
  LS_WRITE_OUTPUTBUFFER_DELTA = 64 * 1024;  // 64KiB

{===============================================================================
    TZLIBLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TZLIBLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TZLIBLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
If fPropagateSeek then
  Result := SeekOut(Offset,Origin)
else
  Result := 0;
end;

//------------------------------------------------------------------------------

Function TZLIBLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
var
  WrittenBytes: LongInt;
begin
If fProcessing then
  begin
    If Size > 0 then
      begin
      {
        compressor should always take everything, so result should be always
        equal to size

        decompressor, on the other hand, will only eat data until the end of
        compression stream, so the result might be smaller than size or even
        zero
      }
        Result := LongInt(fProcessor.Update(Buffer,Size));
        If fUsed <> 0 then
          begin
            WrittenBytes := WriteOut(BufferMemory(fOutputBuffer)^,fUsed);
            If WrittenBytes < fUsed then
              // not all buffered data were written
              Move(BufferMemory(fOutputBuffer,TMemSize(WrittenBytes))^,BufferMemory(fOutputBuffer)^,fUsed - WrittenBytes);
            fUsed := fUsed - WrittenBytes;
          end;
      end
    else Result := 0;
  end
else
  begin
    WriteBuffered;
    Result := WriteOut(Buffer,Size);
  end;
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fProcessing := False;
BufferInit(fOutputBuffer);
fUsed := 0;
fPropagateSeek := True;
GetNamedValue(Params,'TZLIBLayerWriter.PropagateSeek',fPropagateSeek);
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerWriter.Finalize;
begin
fProcessor.Free;
BufferFinal(fOutputBuffer);
inherited;
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerWriter.OutputHandler(Sender: TObject; const Buffer; Size: TMemSize);
begin
If Size > 0 then
  begin
    while (BufferSize(fOutputBuffer) - TMemSize(fUsed)) < Size do
      begin
        // enlarge buffer
        If BufferSize(fOutputBuffer) > 0 then
          BufferRealloc(fOutputBuffer,BufferSize(fOutputBuffer) * 2)
        else
          BufferRealloc(fOutputBuffer,LS_WRITE_OUTPUTBUFFER_DELTA);
      end;
    // copy data to buffer
    Move(Buffer,BufferMemory(fOutputBuffer,TMemSize(fUsed))^,Size);
    fUsed := fUsed + LongInt(Size);
  end;
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerWriter.WriteBuffered;
begin
If fUsed > 0 then
  begin
    If WriteOut(BufferMemory(fOutputBuffer)^,fUsed) = fUsed then
      fUsed := 0
    else
      raise EWriteError.Create('TZLIBLayerWriter.WriteBuffered: Failed to write buffered data.');
  end;
end;

{-------------------------------------------------------------------------------
    TZLIBLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TZLIBLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopNeedsInit,lopNeedsFinal,lopProcessor,lopConsumer,lopGenerator];
end;

//------------------------------------------------------------------------------

class Function TZLIBLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TZLIBLayerWriter.PropagateSeek',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerWriter.Init(Params: TSimpleNamedValues);
begin
GetNamedValue(Params,'TZLIBLayerWriter.PropagateSeek',fPropagateSeek);
If not fProcessing then
  begin
    inherited;
    fUsed := 0;
    fProcessing := True;
    fProcessor.OnOutput := OutputHandler;
    fProcessor.Init;
  end;
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerWriter.Update(Params: TSimpleNamedValues);
begin
inherited;
GetNamedValue(Params,'TZLIBLayerWriter.PropagateSeek',fPropagateSeek);
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerWriter.Flush;
begin
inherited;
WriteBuffered;
end;

//------------------------------------------------------------------------------

procedure TZLIBLayerWriter.Final;
begin
If fProcessing then
  begin
    fProcessor.Final;
    fProcessor.OnOutput := nil;
    fProcessing := False;
    WriteBuffered;
    inherited;
  end;
end;

{===============================================================================
--------------------------------------------------------------------------------
                          TZLIBCompressionLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBCompressionLayerReader - class declaration
===============================================================================}
{-------------------------------------------------------------------------------
    TZLIBCompressionLayerReader - private methods
-------------------------------------------------------------------------------}

Function TZLIBCompressionLayerReader.GetCompressor: TZCompressor;
begin
Result := TZCompressor(fProcessor);
end;

{-------------------------------------------------------------------------------
    TZLIBCompressionLayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TZLIBCompressionLayerReader.Initialize(Params: TSimpleNamedValues);
var
  Temp:       Integer;
  CompLevel:  TZCompressionLevel;
  StreamType: TZStreamType;
begin
inherited;
If GetNamedValue(Params,'TZLIBCompressionLayerReader.CompressionLevel',Temp) then
  CompLevel := ZLibCompLevelFromInteger(Temp)
else
  CompLevel := zclDefault;
If GetNamedValue(Params,'TZLIBCompressionLayerReader.StreamType',Temp) then
  StreamType := ZLibStreamTypeFromInteger(Temp)
else
  StreamType := zstDefault;
fProcessor := TZCompressor.Create(CompLevel,StreamType);
end;

{-------------------------------------------------------------------------------
    TZLIBCompressionLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TZLIBCompressionLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TZLIBCompressionLayerReader.CompressionLevel',nvtInteger,[loprConstructor]);
Result[1] := LayerObjectParam('TZLIBCompressionLayerReader.StreamType',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
--------------------------------------------------------------------------------
                          TZLIBCompressionLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBCompressionLayerWriter - class declaration
===============================================================================}
{-------------------------------------------------------------------------------
    TZLIBCompressionLayerWriter - private methods
-------------------------------------------------------------------------------}

Function TZLIBCompressionLayerWriter.GetCompressor: TZCompressor;
begin
Result := TZCompressor(fProcessor);
end;

{-------------------------------------------------------------------------------
    TZLIBCompressionLayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TZLIBCompressionLayerWriter.Initialize(Params: TSimpleNamedValues);
var
  Temp:       Integer;
  CompLevel:  TZCompressionLevel;
  StreamType: TZStreamType;
begin
inherited;
If GetNamedValue(Params,'TZLIBCompressionLayerWriter.CompressionLevel',Temp) then
  CompLevel := ZLibCompLevelFromInteger(Temp)
else
  CompLevel := zclDefault;
If GetNamedValue(Params,'TZLIBCompressionLayerWriter.StreamType',Temp) then
  StreamType := ZLibStreamTypeFromInteger(Temp)
else
  StreamType := zstDefault;
fProcessor := TZCompressor.Create(CompLevel,StreamType);
end;

{-------------------------------------------------------------------------------
    TZLIBCompressionLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TZLIBCompressionLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TZLIBCompressionLayerWriter.CompressionLevel',nvtInteger,[loprConstructor]);
Result[1] := LayerObjectParam('TZLIBCompressionLayerWriter.StreamType',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
--------------------------------------------------------------------------------
                         TZLIBDecompressionLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBDecompressionLayerReader - class declaration
===============================================================================}
{-------------------------------------------------------------------------------
    TZLIBDecompressionLayerReader - private methods
-------------------------------------------------------------------------------}

Function TZLIBDecompressionLayerReader.GetDecompressor: TZDecompressor;
begin
Result := TZDecompressor(fProcessor);
end;

{-------------------------------------------------------------------------------
    TZLIBDecompressionLayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TZLIBDecompressionLayerReader.Initialize(Params: TSimpleNamedValues);
var
  StreamType: Integer;
begin
inherited;
If GetNamedValue(Params,'TZLIBDecompressionLayerReader.StreamType',StreamType) then
  fProcessor := TZDecompressor.Create(ZLibStreamTypeFromInteger(StreamType))
else
  fProcessor := TZDecompressor.Create;
end;

{-------------------------------------------------------------------------------
    TZLIBDecompressionLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TZLIBDecompressionLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TZLIBDecompressionLayerReader.StreamType',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
--------------------------------------------------------------------------------
                         TZLIBDecompressionLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TZLIBDecompressionLayerWriter - class declaration
===============================================================================}
{-------------------------------------------------------------------------------
    TZLIBDecompressionLayerWriter - private methods
-------------------------------------------------------------------------------}

Function TZLIBDecompressionLayerWriter.GetDecompressor: TZDecompressor;
begin
Result := TZDecompressor(fProcessor);
end;

{-------------------------------------------------------------------------------
    TZLIBDecompressionLayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TZLIBDecompressionLayerWriter.Initialize(Params: TSimpleNamedValues);
var
  StreamType: Integer;
begin
inherited;
If GetNamedValue(Params,'TZLIBDecompressionLayerWriter.StreamType',StreamType) then
  fProcessor := TZDecompressor.Create(ZLibStreamTypeFromInteger(StreamType))
else
  fProcessor := TZDecompressor.Create;
end;

{-------------------------------------------------------------------------------
    TZLIBDecompressionLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TZLIBDecompressionLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TZLIBDecompressionLayerWriter.StreamType',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_ZLIBCompress',TZLIBCompressionLayerReader,TZLIBCompressionLayerWriter);
  RegisterLayer('LSRL_ZLIBDecompress',TZLIBDecompressionLayerReader,TZLIBDecompressionLayerWriter);
  RegisterLayer('LSRL_ZLIBCompressToStream',TZLIBDecompressionLayerReader,TZLIBCompressionLayerWriter);
  RegisterLayer('LSRL_ZLIBCompressFromStream',TZLIBCompressionLayerReader,TZLIBDecompressionLayerWriter);
  RegisterLayer('LSRL_ZLIBDecompressFromStream',TZLIBDecompressionLayerReader,TZLIBCompressionLayerWriter);
  RegisterLayer('LSRL_ZLIBDecompressToStream',TZLIBCompressionLayerReader,TZLIBDecompressionLayerWriter);

end.
