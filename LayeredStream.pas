{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream

    WARNING - current implementation requires extensive testing.

    Layered stream (TLayeredStream class) is a descendant of TStream class that
    is intended for situations, where there is a need for some (possibly
    multi-layered) processing of streamed data, and parallel processing is not
    desirable or possible.

    It does not do any writing or reading itself, it merely operates on another
    stream (here called target) provided during construction.

    The processing is done in one or more layers, where each layer is a pair
    of objects - one object for reading and one for writing.
    The layered stream holds an array of layers and when a request for read,
    write or seek is executed, it is passed to the last layer (top-most). This
    layer processes the request and data (possibly changing them) and passses
    them to the next (lower) layer for further processing. Bottom-most layer,
    after processing, then passes the request back to layered stream and it will
    in turn execute it on the target.

  Version 1.0 alpha (2020-11-03)

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

===============================================================================}
unit LayeredStream;

{$IFDEF FPC}
  {$MODE ObjFPC}
  {$MODESWITCH DuplicateLocals}
  {$MODESWITCH ClassicProcVars}
  {$DEFINE FPC_DisableWarns}
  {$MACRO ON}
{$ENDIF}
{$H+}

interface

uses
  SysUtils, Classes,
  AuxClasses,
  SimpleNamedValues;

type
  ELSException = class(Exception);

  ELSIndexOutOfBounds    = class(ELSException);
  ELSInvalidLayer        = class(ELSException);
  ELSInvalidConnection   = class(ELSException);
  ELSLayerIntegrityError = class(ELSException);
  ELSDuplicitLayerName   = class(ELSException);

{===============================================================================
--------------------------------------------------------------------------------
                               TLSLayerObjectBase
--------------------------------------------------------------------------------
===============================================================================}

  TLSLayerObjectType = (lotUndefined,lotReader,lotWriter);

{
  Note that some of the properties exclude others. For example lopPassthrough
  and lopProcessor is a nonsensical combination, since lopPassthrough explicitly
  states the data are not changed, whereas lopProcessor tells the data are
  changed.
  When such combination is returned by any object, it should be treated as an
  error.

  Some small clarification on examples:

    lopStopper reader - 128 bytes are to be read, but the object stops the
                        request and simply returns 0 without even attempting to
                        pass the request to the next layer

                        0 is returned, no data are read

    lopStopper writer - 128 bytes are being written, the object stops the
                        requests and returns 0 with no attempt to pass any data
                        to next layer

                        0 is returned, no data are written

    lopConsumer reader - 128 are to be read, the object passes request to read
                         all 128 bytes, but upon return from next layer it
                         consumes 28 bytes and returns only 100 bytes to
                         previous layer

                         only 100 bytes is indicated (passed through the layer),
                         but in reality 128 bytes were read, of which 28 bytes
                         were consumed

    lopConsumer writer - 128 bytes are being written, the object accepts them,
                         consumes 28 bytes, and passes only 100 bytes for write
                         to next layer, but reports that all 128 bytes were
                         written

                         128 bytes is indicated, but in reality only 100 bytes
                         were written (paased through the layer) and 28 bytes
                         were consumed by the layer

    lopGenerator reader - 128 bytes are to be read, but the object passes
                          request to read only 100 bytes to the next layer,
                          upon return it adds (generates) new 28 bytes and adds
                          them to the returned 100 and passes them all to
                          previous layer

                          128 bytes are returned, but only 100 bytes were read
                          and 28 bytes were generated by the layer

    lopGenerator writer - 128 bytes are being written, the object passes only
                          100 bytes to the next layer along with new 28 bytes
                          it generates

                          only 100 bytes is indicated to be written, but in
                          reality 128 bytes were written (100 passed + 28
                          generated)
}
  TLSLayerObjectProperty = (
    // object properties
    lopNeedsInit,     // layer object requires a call to Init for it to proper function
    lopNeedsFinal,    // layer object requires a call to Final for it to proper function
    // data passing
    lopAccumulator,   // at least part of the data is stored in the layer for later use
    lopDelayer,       // streaming of the data can be delayed (typically buffering)
    lopStopper,       // object stops any request for read, write or even a seek
    // data changing and processing
    lopPassthrough,   // data are passing with no change
    lopObserver,      // data are observed - some processing is done above them, but are not changed (eg. hashing, statistics, ...)
    lopProcessor,     // passing data are changed in some way (eg. compression, encryption, ...)
    lopConsumer,      // at least part of the data is consumed by the layer object (possibly all of them)
    lopGenerator,     // some new data are generated by the layer and added to the stream
    // data branching
    lopSplitter,      // at least part of the data is copied into a side channel
    lopJoiner,        // some data are added to the stream from a side channel
    // special
    lopDebug          // anything is possible, no strict rules
  );

  TLSLayerObjectProperties = set of TLSLayerObjectProperty;

//------------------------------------------------------------------------------

{
  types used to return information about accepted parameters
}
  TLSLayerObjectParamReceiver = (loprConstructor,loprInitializer,loprUpdater);

  TLSLayerObjectParamReceivers = set of TLSLayerObjectParamReceiver;

  TLSLayerObjectParam = record
    Name:       String;
    ValueType:  TSNVNamedValueType;
    Receivers:  TLSLayerObjectParamReceivers;
  end;

  TLSLayerObjectParams = array of TLSLayerObjectParam;

Function LayerObjectParam(const Name: String; ValueType: TSNVNamedValueType; Receivers: TLSLayerObjectParamReceivers): TLSLayerObjectParam;

//------------------------------------------------------------------------------

// connection events, internal stuff
type
  TLSLayerObjectSeekConnection = Function(const Offset: Int64; Origin: TSeekOrigin): Int64 of object;
  TLSLayerObjectReadConnection = Function(out Buffer; Size: LongInt): LongInt of object;
  TLSLayerObjectWriteConnection = Function(const Buffer; Size: LongInt): LongInt of object;

{===============================================================================
    TLSLayerObjectBase - class declaration
===============================================================================}
type
  TLSLayerObjectBase = class(TCustomObject)
  protected
    fCounterpart:     TLSLayerObjectBase; // the other object in layer pair
    fSeekConnection:  TLSLayerObjectSeekConnection;
    fActive:          Boolean;
    procedure SetCounterpart(Value: TLSLayerObjectBase); virtual;
    procedure SetActive(Value: Boolean); virtual;
    Function SeekIn(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;    
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual; abstract;
    Function SeekOut(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
  {
    InternalInit is called by a layered stream just after the object is set up,
    that is after the connections and counterpart are assigned.

    InternalFinal is called by a layered stream before the object is finalized,
    that is before disconnecting it and before the counterpart is set to nil.

    Note that InternalFinal calls Flush.

    Do not call these routines yourself, they are only for internal use!
  }
    procedure InternalInit; virtual;
    procedure InternalFinal; virtual;
    procedure Initialize(Params: TSimpleNamedValues); virtual;
    procedure Finalize; virtual;
    // protected properties
    property SeekConnection: TLSLayerObjectSeekConnection read fSeekConnection write fSeekConnection;
  public
    class Function LayerObjectType: TLSLayerObjectType; virtual;              // reader/writer
    class Function LayerObjectProperties: TLSLayerObjectProperties; virtual;  // what the objects does with data, how it behaves, ...
    class Function LayerObjectParams: TLSLayerObjectParams; virtual;          // list of accepted parameters
    constructor Create(Params: TSimpleNamedValues);
    destructor Destroy; override;
  {
    Note that calling Init or Final is not mandatory, they are here only for
    those layer objects that really do need them (indicated by lopNeedsInit and
    lopNeedsFinal flags in LayerObjectProperties). But calling init and final
    on object that does not need it is not considered to be an error.
  }
    procedure Init(Params: TSimpleNamedValues = nil); virtual;
  {
    Update is to be used only to update parameters during lifetime of the
    object where calling init is not possible or desirable.
    It should not be used as a mean of processing execution.
  }
    procedure Update(Params: TSimpleNamedValues = nil); virtual;
    procedure Flush; virtual;    
    procedure Final; virtual;
    property Counterpart: TLSLayerObjectBase read fCounterpart write SetCounterpart;
    property Active: Boolean read fActive write SetActive;
  end;

  TLSLayerObjectClass = class of TLSLayerObjectBase;

{===============================================================================
--------------------------------------------------------------------------------
                                 TLSLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TLSLayerReader - class declaration
===============================================================================}
type
  TLSLayerReader = class(TLSLayerObjectBase)
  protected
    fReadConnection:  TLSLayerObjectReadConnection;
    Function ReadIn(out Buffer; Size: LongInt): LongInt; virtual;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; virtual; abstract;
    Function ReadOut(out Buffer; Size: LongInt): LongInt; virtual;
    property ReadConnection: TLSLayerObjectReadConnection read fReadConnection write fReadConnection;
  public
    class Function LayerObjectType: TLSLayerObjectType; override;
  end;

  TLSLayerReaderClass = class of TLSLayerReader;

{===============================================================================
--------------------------------------------------------------------------------
                                 TLSLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TLSLayerWriter - class declaration
===============================================================================}
type
  TLSLayerWriter = class(TLSLayerObjectBase)
  protected
    fWriteConnection: TLSLayerObjectWriteConnection;
    Function WriteIn(const Buffer; Size: LongInt): LongInt; virtual;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; virtual; abstract;
    Function WriteOut(const Buffer; Size: LongInt): LongInt; virtual;
    property WriteConnection: TLSLayerObjectWriteConnection read fWriteConnection write fWriteConnection;    
  public
    class Function LayerObjectType: TLSLayerObjectType; override;
  end;

  TLSLayerWriterClass = class of TLSLayerWriter;

{===============================================================================
--------------------------------------------------------------------------------
                                 TLayeredStream
--------------------------------------------------------------------------------
===============================================================================}
type
  TLayeredStreamMode = (lsmUndefined,lsmSeek,lsmRead,lsmWrite);

  TLSLayer = record
    Name:   String;
    Reader: TLSLayerReader;
    Writer: TLSLayerWriter;
  end;

  // for use in constructor...
  TLSLayerConstruct = record
    Name:         String;
    ReaderClass:  TLSLayerReaderClass;
    WriterClass:  TLSLayerWriterClass;
    ReaderParams: TSimpleNamedValues;
    WriterParams: TSimpleNamedValues;
  end;

Function LayerConstruct(const Name: String; ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil): TLSLayerConstruct; overload;
Function LayerConstruct(ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass): TLSLayerConstruct; overload;

{===============================================================================
    TLayeredStream - class declaration
===============================================================================}

type
  TLayeredStream = class(TStream)
  private
    fMode:        TLayeredStreamMode;
    fTarget:      TStream;
    fOwnsTarget:  Boolean;
    fLayers:      array of TLSLayer;
    Function GetLayerCount: Integer;
    Function GetLayer(Index: Integer): TLSLayer;
  protected
    Function ChangeMode(NewMode: TLayeredStreamMode): TLayeredStreamMode; virtual;  // returns previous mode
    Function SeekIn(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
    Function SeekOut(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
    Function ReadIn(out Buffer; Size: LongInt): LongInt; virtual;
    Function ReadOut(out Buffer; Size: LongInt): LongInt; virtual;
    Function WriteIn(const Buffer; Size: LongInt): LongInt; virtual;
    Function WriteOut(const Buffer; Size: LongInt): LongInt; virtual;
    procedure InitializeLayer(Index: Integer); virtual;
    procedure FinalizeLayer(Index: Integer); virtual;
    procedure ConnectLayer(Index: Integer); virtual;
    procedure DisconnectLayer(Index: Integer); virtual;
    procedure Initialize; virtual;
    procedure Finalize; virtual;
  public
    constructor Create(Target: TStream); overload;
    constructor Create(Target: TStream; Layers: array of TLSLayerConstruct); overload;
    destructor Destroy; override;
    // layer list methods
    Function LowIndex: Integer; virtual;
    Function HighIndex: Integer; virtual;
    Function CheckIndex(Index: Integer): Boolean; virtual;
    Function IndexOf(const LayerName: String): Integer; overload; virtual;    // case insensitive
    Function IndexOf(LayerObjectClass: TLSLayerObjectClass): Integer; overload; virtual;
    Function IndexOf(LayerObject: TLSLayerObjectBase): Integer; overload; virtual;
    Function Find(const LayerName: String; out Index: Integer): Boolean; overload; virtual;
    Function Find(LayerObjectClass: TLSLayerObjectClass; out Index: Integer): Boolean; overload; virtual;
    Function Find(LayerObject: TLSLayerObjectBase; out Index: Integer): Boolean; overload; virtual;
    Function Add(const LayerName: String; ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil): Integer; overload; virtual;
    Function Add(ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil): Integer; overload; virtual;
    Function Add(LayerConstruct: TLSLayerConstruct): Integer; overload; virtual;
    procedure Insert(Index: Integer; const LayerName: String; ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure Insert(Index: Integer; ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure Insert(Index: Integer; LayerConstruct: TLSLayerConstruct); overload; virtual;
    Function Remove(const LayerName: String): Integer; overload; virtual;
    Function Remove(LayerObjectClass: TLSLayerObjectClass): Integer; overload; virtual;
    Function Remove(LayerObject: TLSLayerObjectBase): Integer; overload; virtual;   
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    // layers methods
    Function LayerByName(const LayerName: String): TLSLayer; virtual; // to get index from name, use method IndexOf
    procedure Rename(Index: Integer; const NewName: String); overload; virtual;
    procedure Rename(const LayerName: String; const NewName: String); overload; virtual;
  {
    Note that the order of operations should be init - update - flush - final

    When an action is performed on the whole layer, the reader is done first,
    writer second.
  }
    // initialization is done from bottom (first layer, lowest index) to top (last layer, highest index)
    procedure Init(ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil); overload; virtual;  // initilizes all layers
    procedure Init(Index: Integer; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure Init(const LayerName: String; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure InitReaders(Params: TSimpleNamedValues = nil); virtual;
    procedure InitReader(Index: Integer; Params: TSimpleNamedValues = nil); overload; virtual;
    procedure InitReader(const LayerName: String; Params: TSimpleNamedValues = nil); overload; virtual;
    procedure InitWriters(Params: TSimpleNamedValues = nil); virtual;
    procedure InitWriter(Index: Integer; Params: TSimpleNamedValues = nil); overload; virtual;
    procedure InitWriter(const LayerName: String; Params: TSimpleNamedValues = nil); overload; virtual;
    // updating is done from top to bottom
    procedure Update(ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil); overload; virtual;  // updates all layers
    procedure Update(Index: Integer; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure Update(const LayerName: String; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure UpdateReaders(Params: TSimpleNamedValues = nil); virtual;
    procedure UpdateReader(Index: Integer; Params: TSimpleNamedValues = nil); overload; virtual;
    procedure UpdateReader(const LayerName: String; Params: TSimpleNamedValues = nil); overload; virtual;
    procedure UpdateWriters(Params: TSimpleNamedValues = nil); virtual;
    procedure UpdateWriter(Index: Integer; Params: TSimpleNamedValues = nil); overload; virtual;
    procedure UpdateWriter(const LayerName: String; Params: TSimpleNamedValues = nil); overload; virtual;
    // flushing is done from top to bottom
    procedure Flush; overload; virtual; // flushes all layers according to mode (FlushReaders, FlushWriters)
    procedure Flush(Index: Integer); overload; virtual;
    procedure Flush(const LayerName: String); overload; virtual;
    procedure FlushReaders; virtual;
    procedure FlushReader(Index: Integer); overload; virtual;
    procedure FlushReader(const LayerName: String); overload; virtual;
    procedure FlushWriters; virtual;
    procedure FlushWriter(Index: Integer); overload; virtual;
    procedure FlushWriter(const LayerName: String); overload; virtual;
    // finalization is done from top to bottom
    procedure Final; overload; virtual; // finalizes all layers
    procedure Final(Index: Integer); overload; virtual;
    procedure Final(const LayerName: String); overload; virtual;
    procedure FinalReaders; virtual;
    procedure FinalReader(Index: Integer); overload; virtual;
    procedure FinalReader(const LayerName: String); overload; virtual;
    procedure FinalWriters; virtual;
    procedure FinalWriter(Index: Integer); overload; virtual;
    procedure FinalWriter(const LayerName: String); overload; virtual;
    // layer active status - set Active param to true for activation, false for deactivation
    Function IsActive(Index: Integer): Boolean; overload; virtual;
    Function IsActive(const LayerName: String): Boolean; overload; virtual;
    procedure Activate(Active: Boolean); overload; virtual; // (de)activates all layers from top to bottom
    Function Activate(Index: Integer; Active: Boolean): Boolean; overload; virtual; // returns previous state
    Function Activate(const LayerName: String; Active: Boolean): Boolean; overload; virtual;
    // stream methods
    Function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function Read(var Buffer; Count: LongInt): LongInt; override;
    Function Write(const Buffer; Count: LongInt): LongInt; override;
    // properties
    property Mode: TLayeredStreamMode read fMode;
    property Target: TStream read fTarget;
    property OwnsTarget: Boolean read fOwnsTarget write fOwnsTarget;
    property Count: Integer read GetLayerCount;
    property Layers[Index: Integer]: TLSLayer read GetLayer; default;
  end;

implementation

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
  {$DEFINE W5058:={$WARN 5058 OFF}} // Variable "$1" does not seem to be initialized
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                               TLSLayerObjectBase
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TLSLayerObjectBase - Auxiliary functions
===============================================================================}

Function LayerObjectParam(const Name: String; ValueType: TSNVNamedValueType; Receivers: TLSLayerObjectParamReceivers): TLSLayerObjectParam;
begin
Result.Name := Name;
Result.ValueType := ValueType;
Result.Receivers := Receivers;
end;

{===============================================================================
    TLSLayerObjectBase - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TLSLayerObjectBase - protected methods
-------------------------------------------------------------------------------}

procedure TLSLayerObjectBase.SetCounterpart(Value: TLSLayerObjectBase);
begin
fCounterpart := Value;
end;

//------------------------------------------------------------------------------

procedure TLSLayerObjectBase.SetActive(Value: Boolean);
begin
If Value <> fActive then
  begin
    If not Value then // deactivating, do flush
      Flush;
    fActive := Value;
  end;
end;

//------------------------------------------------------------------------------

Function TLSLayerObjectBase.SeekIn(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
If fActive then
  Result := SeekActive(Offset,Origin)
else
  Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TLSLayerObjectBase.SeekOut(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := 0;
If Assigned(fSeekConnection) then
  Result := fSeekConnection(Offset,Origin)
else
  ELSInvalidConnection.Create('TLSLayerObjectBase.SeekOut: Seek connection not assigned.');
end;

//------------------------------------------------------------------------------

procedure TLSLayerObjectBase.InternalInit;
begin
// no action
end;

//------------------------------------------------------------------------------

procedure TLSLayerObjectBase.InternalFinal;
begin
Flush;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TLSLayerObjectBase.Initialize(Params: TSimpleNamedValues);
begin
fCounterpart := nil;
fSeekConnection := nil;
fActive := True;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TLSLayerObjectBase.Finalize;
begin
// no action
end;

{-------------------------------------------------------------------------------
    TLSLayerObjectBase - public methods
-------------------------------------------------------------------------------}

class Function TLSLayerObjectBase.LayerObjectType: TLSLayerObjectType;
begin
Result := lotUndefined;
end;

//------------------------------------------------------------------------------

class Function TLSLayerObjectBase.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [];
end;

//------------------------------------------------------------------------------

class Function TLSLayerObjectBase.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,0);
end;

//------------------------------------------------------------------------------

constructor TLSLayerObjectBase.Create(Params: TSimpleNamedValues);
begin
inherited Create;
Initialize(Params);
end;

//------------------------------------------------------------------------------

destructor TLSLayerObjectBase.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TLSLayerObjectBase.Init(Params: TSimpleNamedValues = nil);
begin
// nothing to do
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TLSLayerObjectBase.Update(Params: TSimpleNamedValues = nil);
begin
// nothing to do
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TLSLayerObjectBase.Flush;
begin
// nothing to do
end;

//------------------------------------------------------------------------------

procedure TLSLayerObjectBase.Final;
begin
// nothing to do
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TLSLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TLSLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TLSLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TLSLayerReader.ReadIn(out Buffer; Size: LongInt): LongInt;
begin
If fActive then
  Result := ReadActive(Buffer,Size)
else
  Result := ReadOut(Buffer,Size);
end;

//------------------------------------------------------------------------------

Function TLSLayerReader.ReadOut(out Buffer; Size: LongInt): LongInt;
begin
Result := 0;
If Assigned(fReadConnection) then
  Result := fReadConnection(Buffer,Size)
else
  ELSInvalidConnection.Create('TLSLayerReader.ReadOut: Read connection not assigned.');
end;

{-------------------------------------------------------------------------------
    TLSLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TLSLayerReader.LayerObjectType: TLSLayerObjectType;
begin
Result := lotReader;
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TLSLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TLSLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TLSLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TLSLayerWriter.WriteIn(const Buffer; Size: LongInt): LongInt;
begin
If fActive then
  Result := WriteActive(Buffer,Size)
else
  Result := WriteOut(Buffer,Size);
end;

//------------------------------------------------------------------------------

Function TLSLayerWriter.WriteOut(const Buffer; Size: LongInt): LongInt;
begin
Result := 0;
If Assigned(fWriteConnection) then
  Result := fWriteConnection(Buffer,Size)
else
  ELSInvalidConnection.Create('TLSLayerWriter.WriteOut: Write connection not assigned.');
end;

{-------------------------------------------------------------------------------
    TLSLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TLSLayerWriter.LayerObjectType: TLSLayerObjectType;
begin
Result := lotWriter;
end;


{===============================================================================
--------------------------------------------------------------------------------
                                 TLayeredStream
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TLayeredStream - Auxiliary functions
===============================================================================}

Function LayerConstruct(const Name: String; ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil): TLSLayerConstruct;
begin
Result.Name := Name;
Result.ReaderClass := ReaderClass;
Result.WriterClass := WriterClass;
Result.ReaderParams := ReaderParams;
Result.WriterParams := WriterParams;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass): TLSLayerConstruct;
begin
Result := LayerConstruct('',ReaderClass,WriterClass);
end;

{===============================================================================
    TLayeredStream - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TLayeredStream - pritave methods
-------------------------------------------------------------------------------}

Function TLayeredStream.GetLayerCount: Integer;
begin
Result := Length(fLayers);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.GetLayer(Index: Integer): TLSLayer;
begin
If CheckIndex(Index) then
  Result := fLayers[Index]
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.GetLayer: Index (%d) out of bounds.',[Index]);
end;

{-------------------------------------------------------------------------------
    TLayeredStream - protected methods
-------------------------------------------------------------------------------}

Function TLayeredStream.ChangeMode(NewMode: TLayeredStreamMode): TLayeredStreamMode;
begin
Result := fMode;
If fMode <> NewMode then
  begin
    Flush;
    fMode := NewMode;
  end;
end;

//------------------------------------------------------------------------------

Function TLayeredStream.SeekIn(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  OldMode:  TLayeredStreamMode;
begin
OldMode := ChangeMode(lsmSeek); // calls Flush if necessary
If Length(fLayers) > 0 then
  begin
    case OldMode of
      lsmRead:  Result := fLayers[HighIndex].Reader.SeekIn(Offset,Origin);
      lsmWrite: Result := fLayers[HighIndex].Writer.SeekIn(Offset,Origin);
    else
     {lsmUndefined,lsmSeek}
      Result := SeekOut(Offset,Origin);
    end;
  end
else Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.SeekOut(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := fTarget.Seek(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.ReadIn(out Buffer; Size: LongInt): LongInt;
begin
ChangeMode(lsmRead);
If Length(fLayers) > 0 then
  Result := fLayers[HighIndex].Reader.ReadIn(Buffer,Size)
else
  Result := ReadOut(Buffer,Size);
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5058{$ENDIF}
Function TLayeredStream.ReadOut(out Buffer; Size: LongInt): LongInt;
begin
Result := fTarget.Read(Buffer,Integer(Size));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

Function TLayeredStream.WriteIn(const Buffer; Size: LongInt): LongInt;
begin
ChangeMode(lsmWrite);
If Length(fLayers) > 0 then
  Result := fLayers[HighIndex].Writer.WriteIn(Buffer,Size)
else
  Result := WriteOut(Buffer,Size);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.WriteOut(const Buffer; Size: LongInt): LongInt;
begin
Result := fTarget.Write(Buffer,Integer(Size));
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.InitializeLayer(Index: Integer);
begin
If CheckIndex(Index) then
  begin
    fLayers[Index].Reader.Counterpart := fLayers[Index].Writer;
    fLayers[Index].Writer.Counterpart := fLayers[Index].Reader;
    ConnectLayer(Index);
    fLayers[Index].Reader.InternalInit;
    fLayers[Index].Writer.InternalInit;
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.InitializeLayer: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.FinalizeLayer(Index: Integer);
begin
If CheckIndex(Index) then
  begin
    fLayers[Index].Reader.InternalFinal;
    fLayers[Index].Writer.InternalFinal;
    DisconnectLayer(Index);
    fLayers[Index].Reader.SetCounterpart(nil);
    fLayers[Index].Writer.SetCounterpart(nil);
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.FinalizeLayer: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.ConnectLayer(Index: Integer);
begin
If CheckIndex(Index) then
  begin
    // connect layer output
    If Index > LowIndex then
      begin
        fLayers[Index].Reader.SeekConnection := fLayers[Pred(Index)].Reader.SeekIn;
        fLayers[Index].Reader.ReadConnection := fLayers[Pred(Index)].Reader.ReadIn;
        fLayers[Index].Writer.SeekConnection := fLayers[Pred(Index)].Writer.SeekIn;
        fLayers[Index].Writer.WriteConnection := fLayers[Pred(Index)].Writer.WriteIn;
      end
    else
      begin
        fLayers[Index].Reader.SeekConnection := Self.SeekOut;
        fLayers[Index].Reader.ReadConnection := Self.ReadOut;
        fLayers[Index].Writer.SeekConnection := Self.SeekOut;
        fLayers[Index].Writer.WriteConnection := Self.WriteOut;
      end;
    // connect layer input
    If Index < HighIndex then
      begin
        fLayers[Succ(Index)].Reader.SeekConnection := fLayers[Index].Reader.SeekIn;
        fLayers[Succ(Index)].Reader.ReadConnection := fLayers[Index].Reader.ReadIn;
        fLayers[Succ(Index)].Writer.SeekConnection := fLayers[Index].Writer.SeekIn;
        fLayers[Succ(Index)].Writer.WriteConnection := fLayers[Index].Writer.WriteIn;
      end;
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.ConnectLayer: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.DisconnectLayer(Index: Integer);
begin
If CheckIndex(Index) then
  begin
    If Index < HighIndex then
      begin
        fLayers[Succ(Index)].Reader.ReadConnection := fLayers[Index].Reader.ReadConnection;
        fLayers[Succ(Index)].Reader.Seekconnection := fLayers[Index].Reader.Seekconnection;
        fLayers[Succ(Index)].Writer.WriteConnection := fLayers[Index].Writer.WriteConnection;
        fLayers[Succ(Index)].Writer.Seekconnection := fLayers[Index].Writer.Seekconnection;
      end;
    fLayers[Index].Reader.SeekConnection := nil;
    fLayers[Index].Reader.ReadConnection := nil;
    fLayers[Index].Writer.SeekConnection := nil;
    fLayers[Index].Writer.WriteConnection := nil;
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.ConnectLayer: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Initialize;
begin
// target is set in constructor
fMode := lsmUndefined;
fOwnsTarget := False;
SetLength(fLayers,0);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Finalize;
begin
Clear;  // also calls flush
If fOwnsTarget then
  fTarget.Free;
end;

{-------------------------------------------------------------------------------
    TLayeredStream - public methods
-------------------------------------------------------------------------------}

constructor TLayeredStream.Create(Target: TStream);
begin
inherited Create;
fTarget := Target;
Initialize;
end;

//------------------------------------------------------------------------------

constructor TLayeredStream.Create(Target: TStream; Layers: array of TLSLayerConstruct);
var
  i:  Integer;
begin
Create(Target);
SetLength(fLayers,Length(Layers));
For i := Low(fLayers) to High(fLayers) do
  begin
    fLayers[i].Name := Layers[i].Name;
    fLayers[i].Reader := Layers[i].ReaderClass.Create(Layers[i].ReaderParams);
    fLayers[i].Writer := Layers[i].WriterClass.Create(Layers[i].WriterParams);
  end;
// InitializeLayer must be called after all objects are created
For i := Low(fLayers) to High(fLayers) do
  InitializeLayer(i);
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

Function TLayeredStream.IndexOf(const LayerName: String): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If AnsiSameText(fLayers[i].Name,LayerName) then
    begin
      Result := i;
      Break{For i};
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.IndexOf(LayerObjectClass: TLSLayerObjectClass): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If (fLayers[i].Reader is LayerObjectClass) or (fLayers[i].Writer is LayerObjectClass) then
    begin
      Result := i;
      Break{For i};
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.IndexOf(LayerObject: TLSLayerObjectBase): Integer;
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

Function TLayeredStream.Find(const LayerName: String; out Index: Integer): Boolean;
begin
Index := IndexOf(LayerName);
Result := CheckIndex(Index);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.Find(LayerObjectClass: TLSLayerObjectClass; out Index: Integer): Boolean;
begin
Index := IndexOf(LayerObjectClass);
Result := CheckIndex(Index);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.Find(LayerObject: TLSLayerObjectBase; out Index: Integer): Boolean;
begin
Index := IndexOf(LayerObject);
Result := CheckIndex(Index);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.Add(const LayerName: String; ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil): Integer;
begin
If not Find(LayerName,Result) then
  begin
    SetLength(fLayers,Length(fLayers) + 1);
    Result := High(fLayers);
    fLayers[Result].Name := LayerName;
    fLayers[Result].Reader := ReaderClass.Create(ReaderParams);
    fLayers[Result].Writer := WriterClass.Create(WriterParams);
    InitializeLayer(Result);
  end
else raise ELSDuplicitLayerName.CreateFmt('TLayeredStream.Add: Layer with the name "%s" already exists.',[LayerName]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.Add(ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil): Integer;
var
  Identifier: TGUID;
begin
CreateGUID(Identifier);
Result := Add(GUIDToString(Identifier),ReaderClass,WriterClass,ReaderParams,WriterParams);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.Add(LayerConstruct: TLSLayerConstruct): Integer;
begin
with LayerConstruct do
  Result := Add(Name,ReaderClass,WriterClass,ReaderParams,WriterParams);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Insert(Index: Integer; const LayerName: String; ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
If not Find(LayerName,i) then
  begin
    If CheckIndex(Index) then
      begin
        SetLength(fLayers,Length(fLayers) + 1);
        For i := High(fLayers) downto Succ(Index) do
          fLayers[i] := fLayers[i - 1];
        fLayers[Index].Name := LayerName;
        fLayers[Index].Reader := ReaderClass.Create(ReaderParams);
        fLayers[Index].Writer := WriterClass.Create(WriterParams);
        InitializeLayer(Index);
      end
    else If Index = Count then
      Add(LayerName,ReaderClass,WriterClass,ReaderParams,WriterParams)
    else
      raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Insert: Index (%d) out of bounds.',[Index]);
  end
else raise ELSDuplicitLayerName.CreateFmt('TLayeredStream.Insert: Layer with the name "%s" already exists.',[LayerName]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Insert(Index: Integer; ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil);
var
  Identifier: TGUID;
begin
CreateGUID(Identifier);
Insert(Index,GUIDToString(Identifier),ReaderClass,WriterClass,ReaderParams,WriterParams);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Insert(Index: Integer; LayerConstruct: TLSLayerConstruct);
begin
with LayerConstruct do
  Insert(Index,Name,ReaderClass,WriterClass,ReaderParams,WriterParams);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.Remove(const LayerName: String): Integer;
begin
Result := IndexOf(LayerName);
If CheckIndex(Result) then
  Delete(Result);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.Remove(LayerObjectClass: TLSLayerObjectClass): Integer;
begin
Result := IndexOf(LayerObjectClass);
If CheckIndex(Result) then
  Delete(Result);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.Remove(LayerObject: TLSLayerObjectBase): Integer;
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
    FinalizeLayer(Index);  // flushes both reader and writer
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
    FinalizeLayer(i);
    fLayers[i].Reader.Free;
    fLayers[i].Writer.Free;
  end;
SetLength(fLayers,0);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.LayerByName(const LayerName: String): TLSLayer;
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  Result := fLayers[Index]
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.LayerByName: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Rename(Index: Integer; const NewName: String);
var
  CollisionIdx: Integer;
begin
If CheckIndex(Index) then
  begin
    CollisionIdx := IndexOf(NewName);
    If not CheckIndex(CollisionIdx) or (CollisionIdx = Index) then
      fLayers[Index].Name := NewName
    else
      raise ELSDuplicitLayerName.CreateFmt('TLayeredStream.Rename: Layer with the name "%s" already exists.',[NewName]);
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Rename: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Rename(const LayerName: String; const NewName: String);
var
  Index:        Integer;
  CollisionIdx: Integer;
begin
If Find(LayerName,Index) then
  begin
    CollisionIdx := IndexOf(NewName);
    If not CheckIndex(CollisionIdx) or (CollisionIdx = Index) then
      fLayers[Index].Name := NewName
    else
      raise ELSDuplicitLayerName.CreateFmt('TLayeredStream.Rename: Layer with the name "%s" already exists.',[NewName]);      
  end
else raise ELSInvalidLayer.CreateFmt('TLayeredStream.Rename: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Init(ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  begin
    fLayers[i].Reader.Init(ReaderParams);
    fLayers[i].Writer.Init(WriterParams);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Init(Index: Integer; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil);
begin
If CheckIndex(Index) then
  begin
    fLayers[Index].Reader.Init(ReaderParams);
    fLayers[Index].Writer.Init(WriterParams);
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Init: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Init(const LayerName: String; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  begin
    fLayers[Index].Reader.Init(ReaderParams);
    fLayers[Index].Writer.Init(WriterParams);
  end
else raise ELSInvalidLayer.CreateFmt('TLayeredStream.Init: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.InitReaders(Params: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fLayers[i].Reader.Init(Params);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.InitReader(Index: Integer; Params: TSimpleNamedValues = nil);
begin
If CheckIndex(Index) then
  fLayers[Index].Reader.Init(Params)
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.InitReader: Index (%d) out of bounds.',[Index]);
end;
 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.InitReader(const LayerName: String; Params: TSimpleNamedValues = nil);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Reader.Init(Params)
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.InitReader: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.InitWriters(Params: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fLayers[i].Writer.Init(Params);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.InitWriter(Index: Integer; Params: TSimpleNamedValues = nil);
begin
If CheckIndex(Index) then
  fLayers[Index].Writer.Init(Params)
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.InitWriter: Index (%d) out of bounds.',[Index]);
end;
  
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.InitWriter(const LayerName: String; Params: TSimpleNamedValues = nil);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Writer.Init(Params)
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.InitWriter: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Update(ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  begin
    fLayers[i].Reader.Update(ReaderParams);
    fLayers[i].Writer.Update(WriterParams);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Update(Index: Integer; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil);
begin
If CheckIndex(Index) then
  begin
    fLayers[Index].Reader.Update(ReaderParams);
    fLayers[Index].Writer.Update(WriterParams);
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Update: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Update(const LayerName: String; ReaderParams: TSimpleNamedValues = nil; WriterParams: TSimpleNamedValues = nil);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  begin
    fLayers[Index].Reader.Update(ReaderParams);
    fLayers[Index].Writer.Update(WriterParams);
  end
else raise ELSInvalidLayer.CreateFmt('TLayeredStream.Update: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.UpdateReaders(Params: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  fLayers[i].Reader.Update(Params);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.UpdateReader(Index: Integer; Params: TSimpleNamedValues = nil);
begin
If CheckIndex(Index) then
  fLayers[Index].Reader.Update(Params)
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.UpdateReader: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.UpdateReader(const LayerName: String; Params: TSimpleNamedValues = nil);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Reader.Update(Params)
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.UpdateReader: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.UpdateWriters(Params: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  fLayers[i].Writer.Update(Params);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.UpdateWriter(Index: Integer; Params: TSimpleNamedValues = nil);
begin
If CheckIndex(Index) then
  fLayers[Index].Writer.Update(Params)
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.UpdateWriter: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.UpdateWriter(const LayerName: String; Params: TSimpleNamedValues = nil);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Writer.Update(Params)
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.UpdateWriter: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Flush;
begin
case fMode of
  lsmRead:  FlushReaders;
  lsmWrite: FlushWriters;
else
 {lsmUndefined,lsmSeek}
  // do nothing
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Flush(Index: Integer);
begin
If CheckIndex(Index) then
  begin
    fLayers[Index].Reader.Flush;
    fLayers[Index].Writer.Flush;
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Flush: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Flush(const LayerName: String);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  begin
    fLayers[Index].Reader.Flush;
    fLayers[Index].Writer.Flush;
  end
else raise ELSInvalidLayer.CreateFmt('TLayeredStream.Flush: Layer "%s" not found.',[LayerName]);
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

procedure TLayeredStream.FlushReader(Index: Integer);
begin
If CheckIndex(Index) then
  fLayers[Index].Reader.Flush
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.FlushReader: Index (%d) out of bounds.',[Index]);
end;
  
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.FlushReader(const LayerName: String);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Reader.Flush
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.FlushReader: Layer "%s" not found.',[LayerName]);
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

procedure TLayeredStream.FlushWriter(Index: Integer);
begin
If CheckIndex(Index) then
  fLayers[Index].Writer.Flush
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.FlushWriter: Index (%d) out of bounds.',[Index]);
end;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.FlushWriter(const LayerName: String);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Writer.Flush
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.FlushWriter: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Final;
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  begin
    fLayers[i].Reader.Final;
    fLayers[i].Writer.Final;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Final(Index: Integer);
begin
If CheckIndex(Index) then
  begin
    fLayers[Index].Reader.Final;
    fLayers[Index].Writer.Final;
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Final: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Final(const LayerName: String);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  begin
    fLayers[Index].Reader.Final;
    fLayers[Index].Writer.Final;
  end
else raise ELSInvalidLayer.CreateFmt('TLayeredStream.Final: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.FinalReaders;
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  fLayers[i].Reader.Final;
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.FinalReader(Index: Integer);
begin
If CheckIndex(Index) then
  fLayers[Index].Reader.Final
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.FinalReader: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.FinalReader(const LayerName: String);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Reader.Final
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.FinalReader: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.FinalWriters;
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  fLayers[i].Writer.Final;
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.FinalWriter(Index: Integer);
begin
If CheckIndex(Index) then
  fLayers[Index].Writer.Final
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.FinalWriter: Index (%d) out of bounds.',[Index]);
end;
 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.FinalWriter(const LayerName: String);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Writer.Final
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.FinalWriter: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.IsActive(Index: Integer): Boolean;
begin
If CheckIndex(Index) then
  begin
    If fLayers[Index].Reader.Active = fLayers[Index].Writer.Active then
      Result := fLayers[Index].Reader.Active
    else
      raise ELSLayerIntegrityError.CreateFmt('TLayeredStream.IsActive: Layer #%d active state mismatch.',[Index]);
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.IsActive: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.IsActive(const LayerName: String): Boolean;
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  Result := IsActive(Index)
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.IsActive: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Activate(Active: Boolean);
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  begin
    If fLayers[i].Reader.Active = fLayers[i].Writer.Active then
      begin
        fLayers[i].Reader.Active := Active;
        fLayers[i].Writer.Active := Active;
      end
    else raise ELSLayerIntegrityError.CreateFmt('TLayeredStream.Activate: Layer #%d active state mismatch.',[i]);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.Activate(Index: Integer; Active: Boolean): Boolean;
begin
If CheckIndex(Index) then
  begin
    If fLayers[Index].Reader.Active = fLayers[Index].Writer.Active then
      begin
        Result := fLayers[Index].Reader.Active;
        fLayers[Index].Reader.Active := Active;
        fLayers[Index].Writer.Active := Active;        
      end
    else raise ELSLayerIntegrityError.CreateFmt('TLayeredStream.Activate: Layer #%d active state mismatch.',[Index]);
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Activate: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TLayeredStream.Activate(const LayerName: String; Active: Boolean): Boolean;
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  Result := Activate(Index,Active)
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.Activate: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekIn(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.Read(var Buffer; Count: LongInt): LongInt;
begin
Result := ReadIn(Buffer,Count);
end;

//------------------------------------------------------------------------------

Function TLayeredStream.Write(const Buffer; Count: LongInt): LongInt;
begin
Result := WriteIn(Buffer,Count);
end;

end.

