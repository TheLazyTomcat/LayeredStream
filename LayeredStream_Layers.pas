{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - Layers

    This unit provides parent classes for all layers along with some utility
    functions that can be used to simplify implementation of new layers.

  Version 1.0 beta (2021-02-11)

  Last change 2021-02-11

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
    HashBase           - github.com/TheLazyTomcat/Lib.HashBase
    StrRect            - github.com/TheLazyTomcat/Lib.StrRect
    BitOps             - github.com/TheLazyTomcat/Lib.BitOps
    StaticMemoryStream - github.com/TheLazyTomcat/Lib.StaticMemoryStream
  * SimpleCPUID        - github.com/TheLazyTomcat/Lib.SimpleCPUID
    ZLibUtils          - github.com/TheLazyTomcat/Lib.ZLibUtils
    MemoryBuffer       - github.com/TheLazyTomcat/Lib.MemoryBuffer
    DynLibUtils        - github.com/TheLazyTomcat/Lib.DynLibUtils
    ZLib               - github.com/TheLazyTomcat/Bnd.ZLib

  SimpleCPUID might not be needed, see BitOps and CRC32 libraries for details.

===============================================================================}
unit LayeredStream_Layers;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  SysUtils, Classes,
  AuxClasses, SimpleNamedValues;

{===============================================================================
    Framework-specific exceptions
===============================================================================}
type
{
  ELSException is used as an exception superclass throughout the entire
  LayeredStream framework.
}
  ELSException = class(Exception);

{
  ELSInvalidConnection is raised when a layer does not have any output
  connected. This usually means some serious internal error, since these
  connections are managed automatically and should not be touched anywhere
  else.
}
  ELSInvalidConnection = class(ELSException);

{===============================================================================
--------------------------------------------------------------------------------
                               TLSLayerObjectBase
--------------------------------------------------------------------------------
===============================================================================}
type
{
  TLSLayerObjectType is used to identify what kind of layer object is worked
  on (class method LayerObjectType).
}
  TLSLayerObjectType = (lotUndefined,lotReader,lotWriter);

{
  TLSLayerObjectProperty/TLSLayerObjectProperties types are used by layer
  objects to return information about themselves (via a class method
  LayerObjectProperties) - what they do with data, how they operate or what
  they need for a proper function.

    WARNING - new properties might be added in the future as needed.  

  Note that some of the properties exclude others. For example lopPassthrough
  and lopProcessor is a nonsensical combination, since lopPassthrough explicitly
  states the data are not changed, whereas lopProcessor tells the data are
  changed.
  When such combination is returned by any object, it should be treated as an
  error.

  It might not be entirely clear what these properties mean, so let's clarify...

    lopNeedsInit

        The layer object needs a call to Init to start its intended function.
        It should be able to accept data without it, but only in a modified
        passthrough mode.
        Typical example would be hash initialization, compression setup,
        encryption setup and so on.
        Calling Init on already initialized object should do nothing before it
        is finalized. If the finalization is not needed, the re-initialization
        is possible but should be carefully managed.

    lopNeedsFlush

        A call to Flush is needed for proper function of the layer. This is
        usually because of some kind of buffering, where the flush will empty
        the buffer.
        Flush is usually needed to be called only when other layers needs all
        the data and cannot work around buffering.
        Typically, if the Flush is needed, it is also automatically done in a
        call to Final (be it needed or not).

    lopNeedsFinal

        Layer object needs a call to Final to proper end its operation, eg.
        to final calculation of hash or to provide footer for a compression
        stream.
        When an object is finalized, it should be still able to accept data in
        a modified passthrough mode.
        Calling final on finalized object should do nothing.

    lopPartialReads

        A partial read (read where indicated read size is smaller than size of
        read buffer) can occur during normal workings of the layer object.
        Partial reads can normally occur at the end of stream, where no more
        data can be read, but this quirk means the partial read can happen
        anywhere.
        Typically a partial read will end a reading cycle, so you have to
        carefully check for this quirk and act accordingly.

    lopPartialWrites

        A partial write (write inidicating that not the entire passed buffer
        was written) can occur during normal operation of the layer object.
        Partial writes are extremely rare and in most cases never happen, maybe
        within invariant-size or limited-size streams and similar cases.
        If the object have this quirk and a partial write occurs, you should
        carefully asses the situation, as there might be a need to write the
        unwritten data again.

    lopUnusualOp

        The object acts in a strange or unusual way during reading, writing or
        even seeking.
        An example would be a buffered data after finalization, buffured data
        before any IO is performed, or pretty much any other weirdness.
        You should consult source or documentation for details.

    lopAccumulator

        During a read or write, the object creates a copy of passing data and
        stores it in an internal buffer.
        It says nothing about whether the data are altered, delayed, and so on.
        An example would be one-shot hashing, where the entire message must be
        known before a processing can take place.

    lopDelayer

        Passing data are delayed in the object, typically they are buffered.
        It says nothing about whether the data are altered or not.

    lopStopper

        The object stops all requests for read, write or, depending on settings,
        even seek. The requests and data are stopped at this layer and are not
        passed to the next layer.
        Reader, when asked to read some data, will, depending on settings,
        return 0 ot the buffer size - in which case the buffer is filled with
        zeroes.
        Writer will, depending on settings, return 0 or buffer size. Data
        passed in the buffer are completely ignored.

    lopPassthrough

        Data are passing through this object with no change.
        This property does not tell anything about whether the data are delayed
        or not, only that they are not changed.

    lopObserver

        The layer object is somehow processing the passing data without changing
        them.
        It does not indicate whether the data are delayed or even stopped.
        Typical example is hashing object or creation of data statistics.

    lopProcessor

        Passing data are changed in some way. This property indicates some
        deeper processing than just adding or subtracting part of the data.
        Not only the atual data can be changed, their amount can change too.
        It does not say anything about data delaying.
        Examples would be (de)compression or encryption/decryption.

    lopConsumer

        At least part of the passing data, possibly all of them, are consumed
        by this object.
        Reader, when asked to read eg. 100 bytes, will request next layer to
        read more (let's say 120 bytes), upon return it consumes those
        additional 20 bytes and returns only the requested 100 bytes to a
        previous layer.
        When passing eg. 100 bytes to writer, it accepts them, consumes 15
        bytes and passes only remaining 85 bytes to the next layer, while
        indicating that all 100 bytes were written.

    lopGenerator

        The layer object will add (generate) new data to the stream.
        Reader, when asked to read let's say 100 bytes, will pass a request to
        read fewer bytes, eg. 80, to a next layer, and the missing 20 bytes are
        genereted and added so that all 100 bytes are returned.
        Writer, on the other end, when asked to write 100 bytes, takes them and
        simply adds newly generated data (20 bytes for example) and passes
        all 120 bytes to the next layer for writing, while indicating only the
        initial 100 bytes to be written.

    lopSplitter

        The layer object copies part of the passing data into some kind of side
        channel. It does not accumulate these copied data, they must be
        consumed somehow (eg. through an event call).
        An example would be some kind of listener that watches the stream, and
        when wanted data are found, copies them out.

    lopJoiner

        The object adds some new data into the reads or writes from a side
        channel. It differs from lopGenerator in the detail that the new data
        are NOT generated within the object, they are added from an external
        source.

    lopCustom

        Complete behavior cannot be known at compile time, usually because it
        changes depending on object settings.

    lopDebug

        An extreme case where everything is possible. To see what is going on
        in such an object, you must refer to implementation details or
        documentation.
}
  TLSLayerObjectProperty = (
    // object properties
    lopNeedsInit,     // layer object requires a call to Init for it to proper function
    lopNeedsFlush,    // layer object requires a call to Flush for it to proper function
    lopNeedsFinal,    // layer object requires a call to Final for it to proper function
    // behavioral quirks
    lopPartialReads,  // layer can co a partial or zero reads even when not at the end of data
    lopPartialWrites, // layer can potentially do a partial or zero write
    lopUnusualOp,     // layer is operation unusually in some area, refer to source or documentation of that layer for details
    // data flow
    lopAccumulator,   // a copy of at least part of the data is stored in the layer for later use
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
    lopCustom,        // real properties depend on creation parameters
    lopDebug          // anything is possible, no strict rules, refer to source or documentation for details
  );

  TLSLayerObjectProperties = set of TLSLayerObjectProperty;

//------------------------------------------------------------------------------
{
  All layer objects should return information about what parameters they accept
  via a class method LayerObjectParams, following types are used for this
  purpose.

  This info is returned in a form of an array, where each entry contains data
  about one accepted parameter (its name, type and by which method it is
  observed).
}
type
{
  TLSLayerObjectParamReceiver/TLSLayerObjectParamReceivers type is used to
  pass information about which method is observing a specific parameter.
}
  TLSLayerObjectParamReceiver = (loprConstructor,loprInitializer,loprUpdater);

  TLSLayerObjectParamReceivers = set of TLSLayerObjectParamReceiver;

{
  TLSLayerObjectParam type stores information about one accepted parameter.
}
  TLSLayerObjectParam = record
    Name:       String;
    ValueType:  TSNVNamedValueType;
    Receivers:  TLSLayerObjectParamReceivers;
  end;

{
  TLSLayerObjectParams type is used by a method LayerObjectParams to return
  information about all accepted parameters.

    NOTE - the returned array CAN be empty.
}
  TLSLayerObjectParams = array of TLSLayerObjectParam;

{
  LayerObjectParam function is intended to be used internally when constructing
  the array of accepted parameters.
}
Function LayerObjectParam(const Name: String; ValueType: TSNVNamedValueType; Receivers: TLSLayerObjectParamReceivers): TLSLayerObjectParam;

{
  Function LayerObjectParamsJoin should be always used to add new parameters to
  params inherited from descendants.
  Parameters from B are added at the end of A.
}
procedure LayerObjectParamsJoin(var A: TLSLayerObjectParams; const B: TLSLayerObjectParams);

//------------------------------------------------------------------------------
{
  connection events

  they are used internally when connecting individual layers
}
type
  TLSLayerObjectSeekConnection = Function(const Offset: Int64; Origin: TSeekOrigin): Int64 of object;
  TLSLayerObjectReadConnection = Function(out Buffer; Size: LongInt): LongInt of object;
  TLSLayerObjectWriteConnection = Function(const Buffer; Size: LongInt): LongInt of object;

{===============================================================================
    TLSLayerObjectBase - class declaration
===============================================================================}
{
  When implementing new layer object class...

    - do not create direct descendant of TLSLayerObjectBase, always use
      TLSLayerReader or TLSLayerReader
    - do not assume anything about counterpart object
    - do not assume where the layer is located in relation to other layers
    - all layer objects must be created as active
    - always return valid information about all accepted parameters
    - always append inherited parameters to current parameter list
    - expect methods init, update, flush and final to be called even when not
      needed, expect them to be called at any time, any number of times, in any
      order (when realy needed, wrong order is allowed produce an exception)
    - be aware of the order in which methods init, update, flush and final are
      called within the layer stack
    - properly override methods Initialize and Finalize (they are called from
      the constructor and destructor respectively) when needed
    - take care when overriding methods InternalInit and InternalFinal, be aware
      when they are called and how
    - be aware that seeking might go through the counterpart object and
      circumvent current instance
    - readers must always do everthing they can to read the full requested
      amount of data, partial or zero reads should happen only at the end of
      stream
    - writers must always write all passed data, partial writes should happen
      only when really necessary
}
type
  TLSLayerObjectBase = class(TCustomObject)
  protected
    fCounterpart:     TLSLayerObjectBase; // the other object in layer pair
    fSeekConnection:  TLSLayerObjectSeekConnection;
    fActive:          Boolean;
    procedure SetCounterpart(Value: TLSLayerObjectBase); virtual;
    procedure SetActive(Value: Boolean); virtual;
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual; abstract;
    Function SeekOut(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
    procedure Initialize(Params: TSimpleNamedValues); virtual;
    procedure Finalize; virtual;
  public
    class Function LayerObjectType: TLSLayerObjectType; virtual;              // reader/writer
    class Function LayerObjectProperties: TLSLayerObjectProperties; virtual;  // what the objects does with data, how it behaves, ...
    class Function LayerObjectParams: TLSLayerObjectParams; virtual;          // list of accepted parameters
    constructor Create(Params: TSimpleNamedValues = nil); overload;
    constructor Create(Params: ITransientSimpleNamedValues); overload;
    destructor Destroy; override;
  {
    InternalInit is called by a layered stream just after the object is set up,
    that is after the connections and counterpart are assigned.

    InternalFinal is called by a layered stream before the object is finalized,
    that is before disconnecting it and before the counterpart is set to nil.

    Do not explicitly call these routines, they are only for internal use!
  }
    procedure InternalInit; virtual;
    procedure InternalFinal; virtual;    
  {
    Note that calling Init or Final is not mandatory, they are here only for
    those layer objects that really do need them (indicated by lopNeedsInit and
    lopNeedsFinal flags in LayerObjectProperties). But calling init and final
    on object that does not need it is not considered to be an error and should
    be expected by implementations to happen.
  }
    procedure Init(Params: TSimpleNamedValues = nil); overload; virtual;
    procedure Init(Params: ITransientSimpleNamedValues); overload; virtual;
  {
    Update is to be used only to update parameters during lifetime of the
    object where calling init is not possible or desirable.
    It should not be used as a mean of processing execution.
  }
    procedure Update(Params: TSimpleNamedValues = nil); overload; virtual;
    procedure Update(Params: ITransientSimpleNamedValues); overload; virtual;
    procedure Flush; virtual;
    procedure Final; virtual;
    Function SeekIn(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
    property Counterpart: TLSLayerObjectBase read fCounterpart write SetCounterpart;
    property Active: Boolean read fActive write SetActive;
    property SeekConnection: TLSLayerObjectSeekConnection read fSeekConnection write fSeekConnection;
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
    Function ReadActive(out Buffer; Size: LongInt): LongInt; virtual; abstract;
    Function ReadOut(out Buffer; Size: LongInt): LongInt; virtual;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectType: TLSLayerObjectType; override;
    Function ReadIn(out Buffer; Size: LongInt): LongInt; virtual;
    property ReadConnection: TLSLayerObjectReadConnection read fReadConnection write fReadConnection;
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
    Function WriteActive(const Buffer; Size: LongInt): LongInt; virtual; abstract;
    Function WriteOut(const Buffer; Size: LongInt): LongInt; virtual;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectType: TLSLayerObjectType; override;
    Function WriteIn(const Buffer; Size: LongInt): LongInt; virtual;
    property WriteConnection: TLSLayerObjectWriteConnection read fWriteConnection write fWriteConnection;
  end;

  TLSLayerWriterClass = class of TLSLayerWriter;

implementation

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
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

//------------------------------------------------------------------------------

procedure LayerObjectParamsJoin(var A: TLSLayerObjectParams; const B: TLSLayerObjectParams);
var
  AOldLen:  Integer;
  i:        Integer;
begin
If Length(B) > 0 then
  begin
    AOldLen := Length(A);
    SetLength(A,AOldLen + Length(B));
    For i := Low(B) to High(B) do
      A[AOldLen + i] := B[i];
  end;
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

Function TLSLayerObjectBase.SeekOut(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := 0;
If Assigned(fSeekConnection) then
  Result := fSeekConnection(Offset,Origin)
else
  ELSInvalidConnection.Create('TLSLayerObjectBase.SeekOut: Seek connection not assigned.');
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

constructor TLSLayerObjectBase.Create(Params: TSimpleNamedValues = nil);
begin
inherited Create;
Initialize(Params);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TLSLayerObjectBase.Create(Params: ITransientSimpleNamedValues);
begin
Create(Params.Implementor);
end;

//------------------------------------------------------------------------------

destructor TLSLayerObjectBase.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

procedure TLSLayerObjectBase.InternalInit;
begin
// no action
end;

//------------------------------------------------------------------------------

procedure TLSLayerObjectBase.InternalFinal;
begin
// no action
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TLSLayerObjectBase.Init(Params: TSimpleNamedValues = nil);
begin
// nothing to do
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLSLayerObjectBase.Init(Params: ITransientSimpleNamedValues);
begin
Init(Params.Implementor);
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TLSLayerObjectBase.Update(Params: TSimpleNamedValues = nil);
begin
// nothing to do
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLSLayerObjectBase.Update(Params: ITransientSimpleNamedValues);
begin
Update(Params.Implementor);
end;

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

//------------------------------------------------------------------------------

Function TLSLayerObjectBase.SeekIn(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
If fActive then
  Result := SeekActive(Offset,Origin)
else
  Result := SeekOut(Offset,Origin);
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

Function TLSLayerReader.ReadOut(out Buffer; Size: LongInt): LongInt;
begin
Result := 0;
If Assigned(fReadConnection) then
  Result := fReadConnection(Buffer,Size)
else
  ELSInvalidConnection.Create('TLSLayerReader.ReadOut: Read connection not assigned.');
end;

//------------------------------------------------------------------------------

procedure TLSLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fReadConnection := nil;
end;

{-------------------------------------------------------------------------------
    TLSLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TLSLayerReader.LayerObjectType: TLSLayerObjectType;
begin
Result := lotReader;
end;

//------------------------------------------------------------------------------

Function TLSLayerReader.ReadIn(out Buffer; Size: LongInt): LongInt;
begin
If fActive then
  Result := ReadActive(Buffer,Size)
else
  Result := ReadOut(Buffer,Size);
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

Function TLSLayerWriter.WriteOut(const Buffer; Size: LongInt): LongInt;
begin
Result := 0;
If Assigned(fWriteConnection) then
  Result := fWriteConnection(Buffer,Size)
else
  ELSInvalidConnection.Create('TLSLayerWriter.WriteOut: Write connection not assigned.');
end;

//------------------------------------------------------------------------------

procedure TLSLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fWriteConnection := nil;
end;

{-------------------------------------------------------------------------------
    TLSLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TLSLayerWriter.LayerObjectType: TLSLayerObjectType;
begin
Result := lotWriter;
end;

//------------------------------------------------------------------------------

Function TLSLayerWriter.WriteIn(const Buffer; Size: LongInt): LongInt;
begin
If fActive then
  Result := WriteActive(Buffer,Size)
else
  Result := WriteOut(Buffer,Size);
end;


end.
