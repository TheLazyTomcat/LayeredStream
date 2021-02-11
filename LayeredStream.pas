{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream

    NOTE - current implementation requires extensive testing.

    Layered stream (TLayeredStream class) is a descendant of TStream class that
    is intended for situations, where there is a need for some (possibly
    multi-layered) processing of streamed data, and parallel processing is not
    desirable or possible.

    It does not do any writing or reading itself, it merely operates on another
    stream (here called target) provided during construction.

    The processing is done in one or more layers, where each layer is a pair
    of objects - one object for reading and one for writing.
    The layered stream holds an array of layers and, when a request for read,
    write or seek is executed, it is passed to the last layer (top-most). This
    layer processes the request and data (possibly changing them) and passses
    them to the next (lower) layer for further processing. Bottom-most layer,
    after processing, then passes the request back to layered stream and it
    will in turn execute it on the target.

    Several layers are already implemented and distributed with LayeredStream.
    For a complete list, use funtion EnumRegisteredLayers.

  Version 1.0 beta (2021-02-12)

  Last change 2021-02-12

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
unit LayeredStream;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  SysUtils, Classes,
  AuxClasses,
  SimpleNamedValues,
  LayeredStream_Layers;

{
  Type ELSException is declared in unit LayeredStream_Layers
}
type
{
  ELSInvalidConnection is raised when accessing item in list or array using
  index that is outside of allowed bounds.
}
  ELSIndexOutOfBounds = class(ELSException);

{
  ELSDuplicitLayerName is raised when adding or registering a layer with a name
  or ID that is already present.
}
  ELSDuplicitLayer = class(ELSException);

{
  ELSInvalidLayer is raised when requesting non-existent layer.
}
  ELSInvalidLayer = class(ELSException);

{
  ELSLayerIntegrityError is raised when there is an error in layer objects
  integrity (eg. both objects are supposed to have the same value of some
  parameted but they differ).
}
  ELSLayerIntegrityError = class(ELSException);

{
  ELSInvalidValue is used when an invalid or unusable value is encountered.
}
  ELSInvalidValue = class(ELSException);

{===============================================================================
--------------------------------------------------------------------------------
                                 TLayeredStream
--------------------------------------------------------------------------------
===============================================================================}
type
  TLayeredStreamMode = (lsmUndefined,lsmSeek,lsmRead,lsmWrite);

{
  Type TLSLayer is used internally for layers management and storage. It is
  also returned when accessing Layers property of the layered stream.
}
  TLSLayer = record
    Name:   String;
    Reader: TLSLayerReader;
    Writer: TLSLayerWriter;
  end;

{===============================================================================
    TLayeredStream - layer construct
===============================================================================}
{
  Type TLSLayerConstruct and following inline constructor functions are used to
  pass information needed for creation and initialization of new layers in the
  layered stream object.
}
type
  TLSLayerConstruct = record
    Name:         String;
    ReaderClass:  TLSLayerReaderClass;
    WriterClass:  TLSLayerWriterClass;
    ReaderParams: TSimpleNamedValues;
    WriterParams: TSimpleNamedValues;
  end;

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  ReaderParams, WriterParams: TSimpleNamedValues): TLSLayerConstruct; overload;

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  ReaderParams, WriterParams: ITransientSimpleNamedValues): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  ReaderParams: TSimpleNamedValues; WriterParams: ITransientSimpleNamedValues): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  ReaderParams: ITransientSimpleNamedValues; WriterParams: TSimpleNamedValues): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  Params: TSimpleNamedValues): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  Params: ITransientSimpleNamedValues): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

{
  Following inline constructors are taking layer object classes from a given
  registered layer.
}

Function LayerConstruct(const Name: String;
  const RegisteredLayerID: String;
  ReaderParams, WriterParams: TSimpleNamedValues): TLSLayerConstruct; overload;

Function LayerConstruct(const Name: String;
  const RegisteredLayerID: String;
  ReaderParams, WriterParams: ITransientSimpleNamedValues): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(const Name: String;
  const RegisteredLayerID: String;
  ReaderParams: TSimpleNamedValues; WriterParams: ITransientSimpleNamedValues): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(const Name: String;
  const RegisteredLayerID: String;
  ReaderParams: ITransientSimpleNamedValues; WriterParams: TSimpleNamedValues): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(const Name: String;
  const RegisteredLayerID: String;
  Params: TSimpleNamedValues): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(const Name: String;
  const RegisteredLayerID: String;
  Params: ITransientSimpleNamedValues): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(const Name: String;
  const RegisteredLayerID: String): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function LayerConstruct(
  const RegisteredLayerID: String): TLSLayerConstruct; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
    TLayeredStream - params passing
===============================================================================}
{
  Following type and functions are to be used when passing parameters (named
  values) to a layer object(s).
}
type
  TLSLayerParams = record
    ReaderParams: TSimpleNamedValues;
    WriterParams: TSimpleNamedValues;
  end;

Function LayerParams(ReaderParams, WriterParams: TSimpleNamedValues): TLSLayerParams; overload;
Function LayerParams(ReaderParams, WriterParams: ITransientSimpleNamedValues): TLSLayerParams; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function LayerParams(ReaderParams: TSimpleNamedValues; WriterParams: ITransientSimpleNamedValues): TLSLayerParams; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function LayerParams(ReaderParams: ITransientSimpleNamedValues; WriterParams: TSimpleNamedValues): TLSLayerParams; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function LayerParams(Params: TSimpleNamedValues): TLSLayerParams; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function LayerParams(Params: ITransientSimpleNamedValues): TLSLayerParams; overload;{$IFDEF CanInline} inline;{$ENDIF}

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
    constructor Create(Target: TStream; LayerConstructs: array of TLSLayerConstruct); overload;
    destructor Destroy; override;
    // layer list methods
    Function LowIndex: Integer; virtual;
    Function HighIndex: Integer; virtual;
    Function CheckIndex(Index: Integer): Boolean; virtual;
    Function IndexOf(const LayerName: String): Integer; overload; virtual;  // case insensitive
    Function IndexOf(LayerObjectClass: TLSLayerObjectClass): Integer; overload; virtual;
    Function IndexOf(LayerObject: TLSLayerObjectBase): Integer; overload; virtual;
    Function Find(const LayerName: String; out Index: Integer): Boolean; overload; virtual;
    Function Find(LayerObjectClass: TLSLayerObjectClass; out Index: Integer): Boolean; overload; virtual;
    Function Find(LayerObject: TLSLayerObjectBase; out Index: Integer): Boolean; overload; virtual;
    Function Add(LayerConstruct: TLSLayerConstruct): Integer; virtual;  // use function LayerConstruct to fill the argument
    procedure Insert(Index: Integer; LayerConstruct: TLSLayerConstruct); virtual;
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
    // initialization is done from bottom (last layer, lowest index) to top (first layer, highest index)
    procedure Init(Params: TLSLayerParams); overload; virtual;  // initilizes all layers
    procedure Init; overload; virtual;
    procedure Init(Index: Integer; Params: TLSLayerParams); overload; virtual;
    procedure Init(Index: Integer); overload; virtual;
    procedure Init(const LayerName: String; Params: TLSLayerParams); overload; virtual;
    procedure Init(const LayerName: String); overload; virtual;
    procedure InitReaders(ReaderParams: TSimpleNamedValues = nil); overload; virtual;
    procedure InitReaders(ReaderParams: ITransientSimpleNamedValues); overload; virtual;
    procedure InitReader(Index: Integer; ReaderParams: TSimpleNamedValues = nil); overload; virtual;
    procedure InitReader(Index: Integer; ReaderParams: ITransientSimpleNamedValues); overload; virtual;
    procedure InitReader(const LayerName: String; ReaderParams: TSimpleNamedValues = nil); overload; virtual;
    procedure InitReader(const LayerName: String; ReaderParams: ITransientSimpleNamedValues); overload; virtual;
    procedure InitWriters(WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure InitWriters(WriterParams: ITransientSimpleNamedValues); overload; virtual;
    procedure InitWriter(Index: Integer; WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure InitWriter(Index: Integer; WriterParams: ITransientSimpleNamedValues); overload; virtual;
    procedure InitWriter(const LayerName: String; WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure InitWriter(const LayerName: String; WriterParams: ITransientSimpleNamedValues); overload; virtual;
    // updating is done from top to bottom
    procedure Update(Params: TLSLayerParams); overload; virtual;  // updates all layers
    procedure Update; overload; virtual;
    procedure Update(Index: Integer; Params: TLSLayerParams); overload; virtual;
    procedure Update(Index: Integer); overload; virtual;
    procedure Update(const LayerName: String; Params: TLSLayerParams); overload; virtual;
    procedure Update(const LayerName: String); overload; virtual;
    procedure UpdateReaders(ReaderParams: TSimpleNamedValues = nil); overload; virtual;
    procedure UpdateReaders(ReaderParams: ITransientSimpleNamedValues); overload; virtual;
    procedure UpdateReader(Index: Integer; ReaderParams: TSimpleNamedValues = nil); overload; virtual;
    procedure UpdateReader(Index: Integer; ReaderParams: ITransientSimpleNamedValues); overload; virtual;
    procedure UpdateReader(const LayerName: String; ReaderParams: TSimpleNamedValues = nil); overload; virtual;
    procedure UpdateReader(const LayerName: String; ReaderParams: ITransientSimpleNamedValues); overload; virtual;  
    procedure UpdateWriters(WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure UpdateWriters(WriterParams: ITransientSimpleNamedValues); overload; virtual;
    procedure UpdateWriter(Index: Integer; WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure UpdateWriter(Index: Integer; WriterParams: ITransientSimpleNamedValues); overload; virtual;
    procedure UpdateWriter(const LayerName: String; WriterParams: TSimpleNamedValues = nil); overload; virtual;
    procedure UpdateWriter(const LayerName: String; WriterParams: ITransientSimpleNamedValues); overload; virtual;
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

{===============================================================================
--------------------------------------------------------------------------------
                               TLSRegisteredLayers                              
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TLSRegisteredLayers - public interface
===============================================================================}
{
  Adds new layer to a list of registered layers.

  If a layer with the same ID is already registered, it will raise an
  ELSDuplicitLayer exception.

  Resturns true when the registration went successfully, false otherwise.
}
Function RegisterLayer(const ID: String; LayerReaderClass: TLSLayerReaderClass; LayerWriterClass: TLSLayerWriterClass): Boolean;

{
  Returns reader class of a requested registered layer.

  If the requested layer is not found, it will raise an ELSInvalidLayer
  exception.
}
Function GetRegisteredLayerReader(const ID: String): TLSLayerReaderClass;

{
  Returns writer class of a requested registered layer.

  If the requested layer is not found, it will raise an ELSInvalidLayer
  exception.
}
Function GetRegisteredLayerWriter(const ID: String): TLSLayerWriterClass;

{
  Fills output parameteres with reader and writer class of the requested
  registered layer.

  Returns true when the layer is found and the output params are filled.
  Returns false when the layer is not found, in which case the value of both
  output parameteres is undefined.
}
Function GetRegisteredLayer(const ID: String; out LayerReaderClass: TLSLayerReaderClass; out LayerWriterClass: TLSLayerWriterClass): Boolean;

// registered layers enumeration
type
  TLSRegisteredLayer = record
    ID:               String;
    LayerReaderClass: TLSLayerReaderClass;
    LayerWriterClass: TLSLayerWriterClass;
  end;

  TLSRegisteredLayersEnumFunc = Function(const RegLayer: TLSRegisteredLayer): Boolean;

{
  Calls given callback function for each registered layer, passing info about
  this layer to the callback.
}
procedure EnumRegisteredLayers(EnumFunc: TLSRegisteredLayersEnumFunc);

implementation

uses
  SyncObjs,
{
  Following units are here to ensure the layers they implement are always
  registered.
}
  LayeredStream_PassthroughLayer,
  LayeredStream_NotifyLayer,
  LayeredStream_StatLayer,
  LayeredStream_StopLayer,
  LayeredStream_BufferLayer,
  // hashing layers
  LayeredStream_HashLayer,
  LayeredStream_CRC32Layer,
  LayeredStream_Adler32Layer,
  LayeredStream_MD2Layer,
  LayeredStream_MD4Layer,
  LayeredStream_MD5Layer,
  LayeredStream_SHA0Layer,
  LayeredStream_SHA1Layer,
  LayeredStream_SHA2Layer,
  LayeredStream_SHA3Layer,
  // compression layers
  LayeredStream_ZLIBLayer;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
  {$DEFINE W5058:={$WARN 5058 OFF}} // Variable "$1" does not seem to be initialized
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                 TLayeredStream
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TLayeredStream - layer construct
===============================================================================}

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  ReaderParams, WriterParams: TSimpleNamedValues): TLSLayerConstruct;
begin
Result.Name := Name;
Result.ReaderClass := ReaderClass;
Result.WriterClass := WriterClass;
Result.ReaderParams := ReaderParams;
Result.WriterParams := WriterParams;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  ReaderParams, WriterParams: ITransientSimpleNamedValues): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,ReaderClass,WriterClass,ReaderParams.Implementor,WriterParams.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  ReaderParams: TSimpleNamedValues; WriterParams: ITransientSimpleNamedValues): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,ReaderClass,WriterClass,ReaderParams,WriterParams.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  ReaderParams: ITransientSimpleNamedValues; WriterParams: TSimpleNamedValues): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,ReaderClass,WriterClass,ReaderParams.Implementor,WriterParams);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  Params: TSimpleNamedValues): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,ReaderClass,WriterClass,Params,Params);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass;
  Params: ITransientSimpleNamedValues): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,ReaderClass,WriterClass,Params.Implementor,Params.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String;
  ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,ReaderClass,WriterClass,TSimpleNamedValues(nil),TSimpleNamedValues(nil));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(ReaderClass: TLSLayerReaderClass; WriterClass: TLSLayerWriterClass): TLSLayerConstruct;
begin
Result := LayerConstruct('',ReaderClass,WriterClass,TSimpleNamedValues(nil),TSimpleNamedValues(nil));
end;

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

Function LayerConstruct(const Name: String; const RegisteredLayerID: String;
  ReaderParams, WriterParams: TSimpleNamedValues): TLSLayerConstruct;
var
  ReaderClass: TLSLayerReaderClass;
  WriterClass: TLSLayerWriterClass;
begin
If GetRegisteredLayer(RegisteredLayerID,ReaderClass,WriterClass) then
  Result := LayerConstruct(NAme,ReaderClass,WriterClass,ReaderParams,WriterParams)
else
  raise ELSInvalidLayer.CreateFmt('LayerConstruct: Invalid registered layer ID "%s".',[RegisteredLayerID]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String; const RegisteredLayerID: String;
  ReaderParams, WriterParams: ITransientSimpleNamedValues): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,RegisteredLayerID,ReaderParams.Implementor,WriterParams.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String; const RegisteredLayerID: String;
  ReaderParams: TSimpleNamedValues; WriterParams: ITransientSimpleNamedValues): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,RegisteredLayerID,ReaderParams,WriterParams.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String; const RegisteredLayerID: String;
  ReaderParams: ITransientSimpleNamedValues; WriterParams: TSimpleNamedValues): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,RegisteredLayerID,ReaderParams.Implementor,WriterParams);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String; const RegisteredLayerID: String; Params: TSimpleNamedValues): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,RegisteredLayerID,Params,Params);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String; const RegisteredLayerID: String; Params: ITransientSimpleNamedValues): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,RegisteredLayerID,Params.Implementor,Params.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const Name: String; const RegisteredLayerID: String): TLSLayerConstruct;
begin
Result := LayerConstruct(Name,RegisteredLayerID,TSimpleNamedValues(nil),TSimpleNamedValues(nil));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerConstruct(const RegisteredLayerID: String): TLSLayerConstruct;
begin
Result := LayerConstruct('',RegisteredLayerID,TSimpleNamedValues(nil),TSimpleNamedValues(nil));
end;

{===============================================================================
    TLayeredStream - params passing
===============================================================================}

Function LayerParams(ReaderParams, WriterParams: TSimpleNamedValues): TLSLayerParams;
begin
Result.ReaderParams := ReaderParams;
Result.WriterParams := WriterParams;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerParams(ReaderParams, WriterParams: ITransientSimpleNamedValues): TLSLayerParams;
begin
Result := LayerParams(ReaderParams.Implementor,WriterParams.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerParams(ReaderParams: TSimpleNamedValues; WriterParams: ITransientSimpleNamedValues): TLSLayerParams;
begin
Result := LayerParams(ReaderParams,WriterParams.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerParams(ReaderParams: ITransientSimpleNamedValues; WriterParams: TSimpleNamedValues): TLSLayerParams;
begin
Result := LayerParams(ReaderParams.Implementor,WriterParams);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerParams(Params: TSimpleNamedValues): TLSLayerParams;
begin
Result := LayerParams(Params,Params);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function LayerParams(Params: ITransientSimpleNamedValues): TLSLayerParams;
begin
Result := LayerParams(Params.Implementor,Params.Implementor);
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
    fLayers[Index].Reader.Counterpart := nil;
    fLayers[Index].Writer.Counterpart := nil;
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
Clear; 
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

constructor TLayeredStream.Create(Target: TStream; LayerConstructs: array of TLSLayerConstruct);
var
  i:  Integer;
begin
Create(Target);
SetLength(fLayers,Length(LayerConstructs));
For i := Low(fLayers) to High(fLayers) do
  begin
    fLayers[i].Name := LayerConstructs[i].Name;
    fLayers[i].Reader := LayerConstructs[i].ReaderClass.Create(LayerConstructs[i].ReaderParams);
    fLayers[i].Writer := LayerConstructs[i].WriterClass.Create(LayerConstructs[i].WriterParams);
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

Function TLayeredStream.Add(LayerConstruct: TLSLayerConstruct): Integer;
var
  Identifier: TGUID;
begin
If not Find(LayerConstruct.Name,Result) then
  begin
    SetLength(fLayers,Length(fLayers) + 1);
    Result := High(fLayers);
    If Length(LayerConstruct.Name) <= 0 then
      begin
        CreateGUID(Identifier);
        fLayers[Result].Name := GUIDToString(Identifier);
      end
    else fLayers[Result].Name := LayerConstruct.Name;
    fLayers[Result].Reader := LayerConstruct.ReaderClass.Create(LayerConstruct.ReaderParams);
    fLayers[Result].Writer := LayerConstruct.WriterClass.Create(LayerConstruct.WriterParams);
    InitializeLayer(Result);
  end
else raise ELSDuplicitLayer.CreateFmt('TLayeredStream.Add: Layer with the name "%s" already exists.',[LayerConstruct.Name]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Insert(Index: Integer; LayerConstruct: TLSLayerConstruct);
var
  i:          Integer;
  Identifier: TGUID;
begin
If not Find(LayerConstruct.Name,i) then
  begin
    If CheckIndex(Index) then
      begin
        SetLength(fLayers,Length(fLayers) + 1);
        For i := High(fLayers) downto Succ(Index) do
          fLayers[i] := fLayers[i - 1]; 
        If Length(LayerConstruct.Name) <= 0 then
          begin
            CreateGUID(Identifier);
            fLayers[Index].Name := GUIDToString(Identifier);
          end
        else fLayers[Index].Name := LayerConstruct.Name;
        fLayers[Index].Reader := LayerConstruct.ReaderClass.Create(LayerConstruct.ReaderParams);
        fLayers[Index].Writer := LayerConstruct.WriterClass.Create(LayerConstruct.WriterParams);
        InitializeLayer(Index);
      end
    else If Index = Count then
      Add(LayerConstruct)
    else
      raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Insert: Index (%d) out of bounds.',[Index]);
  end
else raise ELSDuplicitLayer.CreateFmt('TLayeredStream.Insert: Layer with the name "%s" already exists.',[LayerConstruct.Name]);
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
    FinalizeLayer(Index);
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
      raise ELSDuplicitLayer.CreateFmt('TLayeredStream.Rename: Layer with the name "%s" already exists.',[NewName]);
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
      raise ELSDuplicitLayer.CreateFmt('TLayeredStream.Rename: Layer with the name "%s" already exists.',[NewName]);      
  end
else raise ELSInvalidLayer.CreateFmt('TLayeredStream.Rename: Layer "%s" not found.',[LayerName]);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Init(Params: TLSLayerParams);
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  begin
    fLayers[i].Reader.Init(Params.ReaderParams);
    fLayers[i].Writer.Init(Params.WriterParams);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Init;
begin
Init(LayerParams(TSimpleNamedValues(nil),TSimpleNamedValues(nil)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Init(Index: Integer; Params: TLSLayerParams);
begin
If CheckIndex(Index) then
  begin
    fLayers[Index].Reader.Init(Params.ReaderParams);
    fLayers[Index].Writer.Init(Params.WriterParams);
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Init: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Init(Index: Integer);
begin
Init(Index,LayerParams(TSimpleNamedValues(nil),TSimpleNamedValues(nil)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Init(const LayerName: String; Params: TLSLayerParams);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  begin
    fLayers[Index].Reader.Init(Params.ReaderParams);
    fLayers[Index].Writer.Init(Params.WriterParams);
  end
else raise ELSInvalidLayer.CreateFmt('TLayeredStream.Init: Layer "%s" not found.',[LayerName]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Init(const LayerName: String);
begin
Init(LayerName,LayerParams(TSimpleNamedValues(nil),TSimpleNamedValues(nil)));
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.InitReaders(ReaderParams: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fLayers[i].Reader.Init(ReaderParams);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.InitReaders(ReaderParams: ITransientSimpleNamedValues);
begin
InitReaders(ReaderParams.Implementor);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.InitReader(Index: Integer; ReaderParams: TSimpleNamedValues = nil);
begin
If CheckIndex(Index) then
  fLayers[Index].Reader.Init(ReaderParams)
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.InitReader: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.InitReader(Index: Integer; ReaderParams: ITransientSimpleNamedValues);
begin
InitReader(Index,ReaderParams.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.InitReader(const LayerName: String; ReaderParams: TSimpleNamedValues = nil);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Reader.Init(ReaderParams)
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.InitReader: Layer "%s" not found.',[LayerName]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.InitReader(const LayerName: String; ReaderParams: ITransientSimpleNamedValues);
begin
InitReader(LayerName,ReaderParams.Implementor);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.InitWriters(WriterParams: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fLayers[i].Writer.Init(WriterParams);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.InitWriters(WriterParams: ITransientSimpleNamedValues);
begin
InitWriters(WriterParams.Implementor);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.InitWriter(Index: Integer; WriterParams: TSimpleNamedValues = nil);
begin
If CheckIndex(Index) then
  fLayers[Index].Writer.Init(WriterParams)
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.InitWriter: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.InitWriter(Index: Integer; WriterParams: ITransientSimpleNamedValues);
begin
InitWriter(Index,WriterParams.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.InitWriter(const LayerName: String; WriterParams: TSimpleNamedValues = nil);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Writer.Init(WriterParams)
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.InitWriter: Layer "%s" not found.',[LayerName]);
end;
  
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.InitWriter(const LayerName: String; WriterParams: ITransientSimpleNamedValues);
begin
InitWriter(LayerName,WriterParams.Implementor);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.Update(Params: TLSLayerParams);
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  begin
    fLayers[i].Reader.Update(Params.ReaderParams);
    fLayers[i].Writer.Update(Params.WriterParams);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Update;
begin
Update(LayerParams(TSimpleNamedValues(nil),TSimpleNamedValues(nil)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Update(Index: Integer; Params: TLSLayerParams);
begin
If CheckIndex(Index) then
  begin
    fLayers[Index].Reader.Update(Params.ReaderParams);
    fLayers[Index].Writer.Update(Params.WriterParams);
  end
else raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.Update: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Update(Index: Integer);
begin
Update(Index,LayerParams(TSimpleNamedValues(nil),TSimpleNamedValues(nil)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Update(const LayerName: String; Params: TLSLayerParams);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  begin
    fLayers[Index].Reader.Update(Params.ReaderParams);
    fLayers[Index].Writer.Update(Params.WriterParams);
  end
else raise ELSInvalidLayer.CreateFmt('TLayeredStream.Update: Layer "%s" not found.',[LayerName]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.Update(const LayerName: String);
begin
Update(LayerName,LayerParams(TSimpleNamedValues(nil),TSimpleNamedValues(nil)));
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.UpdateReaders(ReaderParams: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  fLayers[i].Reader.Update(ReaderParams);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.UpdateReaders(ReaderParams: ITransientSimpleNamedValues);
begin
UpdateReaders(ReaderParams.Implementor);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.UpdateReader(Index: Integer; ReaderParams: TSimpleNamedValues = nil);
begin
If CheckIndex(Index) then
  fLayers[Index].Reader.Update(ReaderParams)
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.UpdateReader: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.UpdateReader(Index: Integer; ReaderParams: ITransientSimpleNamedValues);
begin
UpdateReader(Index,ReaderParams.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.UpdateReader(const LayerName: String; ReaderParams: TSimpleNamedValues = nil);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Reader.Update(ReaderParams)
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.UpdateReader: Layer "%s" not found.',[LayerName]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.UpdateReader(const LayerName: String; ReaderParams: ITransientSimpleNamedValues);
begin
UpdateReader(LayerName,ReaderParams.Implementor);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.UpdateWriters(WriterParams: TSimpleNamedValues = nil);
var
  i:  Integer;
begin
For i := HighIndex downto LowIndex do
  fLayers[i].Writer.Update(WriterParams);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.UpdateWriters(WriterParams: ITransientSimpleNamedValues);
begin
UpdateWriters(WriterParams.Implementor);
end;

//------------------------------------------------------------------------------

procedure TLayeredStream.UpdateWriter(Index: Integer; WriterParams: TSimpleNamedValues = nil);
begin
If CheckIndex(Index) then
  fLayers[Index].Writer.Update(WriterParams)
else
  raise ELSIndexOutOfBounds.CreateFmt('TLayeredStream.UpdateWriter: Index (%d) out of bounds.',[Index]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.UpdateWriter(Index: Integer; WriterParams: ITransientSimpleNamedValues);
begin
UpdateWriter(Index,WriterParams.Implementor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.UpdateWriter(const LayerName: String; WriterParams: TSimpleNamedValues = nil);
var
  Index:  Integer;
begin
If Find(LayerName,Index) then
  fLayers[Index].Writer.Update(WriterParams)
else
  raise ELSInvalidLayer.CreateFmt('TLayeredStream.UpdateWriter: Layer "%s" not found.',[LayerName]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TLayeredStream.UpdateWriter(const LayerName: String; WriterParams: ITransientSimpleNamedValues);
begin
UpdateWriter(LayerName,WriterParams.Implementor);
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


{===============================================================================
--------------------------------------------------------------------------------
                               TLSRegisteredLayers                              
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TLSRegisteredLayers - class declaration
===============================================================================}
type
  TLSRegisteredLayers = class(TCustomListObject)
  private 
    fRegisteredLayers:  array of TLSRegisteredLayer;
    fCount:             Integer;
    Function GetRegLayer(Index: Integer): TLSRegisteredLayer;
  protected
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    Function GetCount: Integer; override;
    procedure SetCount(Value: Integer); override;
  public
    constructor Create;
    destructor Destroy; override;
    Function LowIndex: Integer; override;
    Function HighIndex: Integer; override;
    Function IndexOf(const ID: String): Integer; virtual;
    Function Add(const ID: String; LayerReaderClass: TLSLayerReaderClass; LayerWriterClass: TLSLayerWriterClass): Integer; virtual;
    Function Remove(const ID: String): Integer; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    property RegisteredLayers[Index: Integer]: TLSRegisteredLayer read GetRegLayer; default;
  end;

{===============================================================================
    TLSRegisteredLayers - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TLSRegisteredLayers - private methods
-------------------------------------------------------------------------------}

Function TLSRegisteredLayers.GetRegLayer(Index: Integer): TLSRegisteredLayer;
begin
If CheckIndex(Index) then
  Result := fRegisteredLayers[Index]
else
  raise ELSIndexOutOfBounds.CreateFmt('TLSRegisteredLayers.GetRegLayer: Index (%d) out of bounds.',[Index]);
end;

{-------------------------------------------------------------------------------
    TLSRegisteredLayers - protected methods
-------------------------------------------------------------------------------}

Function TLSRegisteredLayers.GetCapacity: Integer;
begin
Result := Length(fRegisteredLayers);
end;

//------------------------------------------------------------------------------

procedure TLSRegisteredLayers.SetCapacity(Value: Integer);
begin
If Value >= 0 then
  begin
    SetLength(fRegisteredLayers,Value);
    If Value < fCount then
      fCount := Value;
  end
else raise ELSInvalidValue.CreateFmt('TLSRegisteredLayers.SetCapacity: Invalid capacity (%d).',[Value]);
end;

//------------------------------------------------------------------------------

Function TLSRegisteredLayers.GetCount: Integer;
begin
Result := fCount;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TLSRegisteredLayers.SetCount(Value: Integer);
begin
// do nothing
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

{-------------------------------------------------------------------------------
    TLSRegisteredLayers - public methods
-------------------------------------------------------------------------------}

constructor TLSRegisteredLayers.Create;
begin
inherited Create;
SetLength(fRegisteredLayers,0);
fCount := 0;
end;

//------------------------------------------------------------------------------

destructor TLSRegisteredLayers.Destroy;
begin
Clear;
inherited;
end;

//------------------------------------------------------------------------------

Function TLSRegisteredLayers.LowIndex: Integer;
begin
Result := Low(fRegisteredLayers);
end;

//------------------------------------------------------------------------------

Function TLSRegisteredLayers.HighIndex: Integer;
begin
Result := Pred(fCount);
end;

//------------------------------------------------------------------------------

Function TLSRegisteredLayers.IndexOf(const ID: String): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If AnsiSametext(ID,fRegisteredLayers[i].ID) then
    begin
      Result := i;
      Break;
    end;
end;

//------------------------------------------------------------------------------

Function TLSRegisteredLayers.Add(const ID: String; LayerReaderClass: TLSLayerReaderClass; LayerWriterClass: TLSLayerWriterClass): Integer;
begin
If not CheckIndex(IndexOf(ID)) then
  begin
    Grow;
    Result := fCount;
    fRegisteredLayers[Result].ID := ID;
    fRegisteredLayers[Result].LayerReaderClass := LayerReaderClass;
    fRegisteredLayers[Result].LayerWriterClass := LayerWriterClass;
    Inc(fCount);
  end
else raise ELSDuplicitLayer.CreateFmt('TLSRegisteredLayers.Add: Layer with ID of "%s" is already registered.',[ID]);
end;

//------------------------------------------------------------------------------

Function TLSRegisteredLayers.Remove(const ID: String): Integer;
begin
Result := IndexOf(ID);
If CheckIndex(Result) then
  Delete(Result);
end;

//------------------------------------------------------------------------------

procedure TLSRegisteredLayers.Delete(Index: Integer);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    For i := Index to Pred(HighIndex) do
      fRegisteredLayers[i] := fRegisteredLayers[i + 1];
    Dec(fCount);
    Shrink;
  end
else ELSIndexOutOfBounds.CreateFmt('TLSRegisteredLayers.Delete: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TLSRegisteredLayers.Clear;
begin
SetLength(fRegisteredLayers,0);
fCount := 0;
end;

{===============================================================================
    TLSRegisteredLayers - public interface
===============================================================================}
{-------------------------------------------------------------------------------
    TLSRegisteredLayers - public interface internals
-------------------------------------------------------------------------------}

var
  RegisteredLayersInit: Boolean = False;
  RegisteredLayersLock: TCriticalSection;
  RegisteredLayers:     TLSRegisteredLayers;

//------------------------------------------------------------------------------

procedure RegisteredLayersInitialize;
begin
{
  Note that this code is first called during units initialization, at which
  point the initialization is executed and objects are created.
  Any subsequent call, including from other threads, will just read the
  RegisteredLayersInit variable and, since it never changes after the first
  call, exits immediately because it is set to true.
  Therefore, this code should be thread-safe even with no protection.
}
If not RegisteredLayersInit then
  begin
    RegisteredLayersInit := True;
    RegisteredLayersLock := TCriticalSection.Create;
    RegisteredLayers := TLSRegisteredLayers.Create;
  end;
end;

//------------------------------------------------------------------------------

procedure RegisteredLayersFinalize;
begin
FreeAndNil(RegisteredLayers);
FreeAndNil(RegisteredLayersLock);
end;

{-------------------------------------------------------------------------------
    TLSRegisteredLayers - public interface externals
-------------------------------------------------------------------------------}

Function RegisterLayer(const ID: String; LayerReaderClass: TLSLayerReaderClass; LayerWriterClass: TLSLayerWriterClass): Boolean;
var
  LocalID:  String;
begin
RegisteredLayersInitialize;
RegisteredLayersLock.Acquire;
try
  LocalID := ID;
  UniqueString(LocalID);
  Result := RegisteredLayers.CheckIndex(RegisteredLayers.Add(LocalID,LayerReaderClass,LayerWriterClass));
finally
  RegisteredLayersLock.Release;
end;
end;

//------------------------------------------------------------------------------

Function GetRegisteredLayerReader(const ID: String): TLSLayerReaderClass;
var
  Index:  Integer;
begin
RegisteredLayersInitialize;
RegisteredLayersLock.Acquire;
try
  Index := RegisteredLayers.IndexOf(ID);
  If RegisteredLayers.CheckIndex(Index) then
    Result := RegisteredLayers[Index].LayerReaderClass
  else
    raise ELSInvalidLayer.CreateFmt('GetRegisteredLayerReader: Invalid registered layer ID "%s".',[ID]);
finally
  RegisteredLayersLock.Release;
end;
end;

//------------------------------------------------------------------------------

Function GetRegisteredLayerWriter(const ID: String): TLSLayerWriterClass;
var
  Index:  Integer;
begin
RegisteredLayersInitialize;
RegisteredLayersLock.Acquire;
try
  Index := RegisteredLayers.IndexOf(ID);
  If RegisteredLayers.CheckIndex(Index) then
    Result := RegisteredLayers[Index].LayerWriterClass
  else
    raise ELSInvalidLayer.CreateFmt('GetRegisteredLayerWriter: Invalid registered layer ID "%s".',[ID]);
finally
  RegisteredLayersLock.Release;
end;
end;

//------------------------------------------------------------------------------

Function GetRegisteredLayer(const ID: String; out LayerReaderClass: TLSLayerReaderClass; out LayerWriterClass: TLSLayerWriterClass): Boolean;
var
  Index:  Integer;
begin
RegisteredLayersInitialize;
RegisteredLayersLock.Acquire;
try
  Index := RegisteredLayers.IndexOf(ID);
  If RegisteredLayers.CheckIndex(Index) then
    begin
      LayerReaderClass := RegisteredLayers[Index].LayerReaderClass;
      LayerWriterClass := RegisteredLayers[Index].LayerWriterClass;
      Result := True;
    end
  else Result := False;
finally
  RegisteredLayersLock.Release;
end;
end;

//------------------------------------------------------------------------------

procedure EnumRegisteredLayers(EnumFunc: TLSRegisteredLayersEnumFunc);
var
  i:  Integer;
begin
RegisteredLayersInitialize;
RegisteredLayersLock.Acquire;
try
  For i := RegisteredLayers.LowIndex to RegisteredLayers.HighIndex do
    If not EnumFunc(RegisteredLayers[i]) then
      Break{For i};
finally
  RegisteredLayersLock.Release;
end;
end;

{===============================================================================
    Unit initialization/finalization
===============================================================================}

initialization
  RegisteredLayersInitialize;

finalization
  RegisteredLayersFinalize;

end.

