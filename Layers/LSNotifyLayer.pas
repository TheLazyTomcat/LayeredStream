unit LSNotifyLayer;

interface

uses
  Classes,
  AuxClasses,
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                               TNotifyLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TNotifyLayerReader - class declaration
===============================================================================}

type
  TNotifyLayerReader = class(TLSLayerReader)
  private
    fBeforeSeekEvent:     TNotifyEvent;
    fBeforeSeekCallback:  TNotifyCallback;
    fAfterSeekEvent:      TNotifyEvent;
    fAfterSeekCallback:   TNotifyCallback;
    fBeforeReadEvent:     TNotifyEvent;
    fBeforeReadCallback:  TNotifyCallback;
    fAfterReadEvent:      TNotifyEvent;
    fAfterReadCallback:   TNotifyCallback;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure DoBeforeSeek; virtual;
    procedure DoAfterSeek; virtual;
    procedure DoBeforeRead; virtual;
    procedure DoAfterRead; virtual;
  public
    class Function LayerObjectKind: TLSLayerObjectKind; override;
    property OnBeforeSeekEvent: TNotifyEvent read fBeforeSeekEvent write fBeforeSeekEvent;
    property OnBeforeSeekCallback: TNotifyCallback read fBeforeSeekCallback write fBeforeSeekCallback;
    property OnBeforeSeek: TNotifyEvent read fBeforeSeekEvent write fBeforeSeekEvent;
    property OnAfterSeekEvent: TNotifyEvent read fAfterSeekEvent write fAfterSeekEvent;
    property OnAfterSeekCallback: TNotifyCallback read fAfterSeekCallback write fAfterSeekCallback;
    property OnAfterSeek: TNotifyEvent read fAfterSeekEvent write fAfterSeekEvent;
    property OnSeekEvent: TNotifyEvent read fBeforeSeekEvent write fBeforeSeekEvent;
    property OnSeekCallback: TNotifyCallback read fBeforeSeekCallback write fBeforeSeekCallback;
    property OnSeek: TNotifyEvent read fBeforeSeekEvent write fBeforeSeekEvent;
    property OnBeforeReadEvent: TNotifyEvent read fBeforeReadEvent write fBeforeReadEvent;
    property OnBeforeReadCallback: TNotifyCallback read fBeforeReadCallback write fBeforeReadCallback;
    property OnBeforeRead: TNotifyEvent read fBeforeReadEvent write fBeforeReadEvent;
    property OnAfterReadEvent: TNotifyEvent read fAfterReadEvent write fAfterReadEvent;
    property OnAfterReadCallback: TNotifyCallback read fAfterReadCallback write fAfterReadCallback;
    property OnAfterRead: TNotifyEvent read fAfterReadEvent write fAfterReadEvent;
    property OnReadEvent: TNotifyEvent read fAfterReadEvent write fAfterReadEvent;
    property OnReadCallback: TNotifyCallback read fAfterReadCallback write fAfterReadCallback;
    property OnRead: TNotifyEvent read fAfterReadEvent write fAfterReadEvent;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TNotifyLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TNotifyLayerWriter - class declaration
===============================================================================}
type
  TNotifyLayerWriter = class(TLSLayerWriter)
  private
    fBeforeSeekEvent:     TNotifyEvent;
    fBeforeSeekCallback:  TNotifyCallback;
    fAfterSeekEvent:      TNotifyEvent;
    fAfterSeekCallback:   TNotifyCallback;
    fBeforeWriteEvent:    TNotifyEvent;
    fBeforeWriteCallback: TNotifyCallback;
    fAfterWriteEvent:     TNotifyEvent;
    fAfterWriteCallback:  TNotifyCallback;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure DoBeforeSeek; virtual;
    procedure DoAfterSeek; virtual;
    procedure DoBeforeWrite; virtual;
    procedure DoAfterWrite; virtual;
  public
    class Function LayerObjectKind: TLSLayerObjectKind; override;
    property OnBeforeSeekEvent: TNotifyEvent read fBeforeSeekEvent write fBeforeSeekEvent;
    property OnBeforeSeekCallback: TNotifyCallback read fBeforeSeekCallback write fBeforeSeekCallback;
    property OnBeforeSeek: TNotifyEvent read fBeforeSeekEvent write fBeforeSeekEvent;
    property OnAfterSeekEvent: TNotifyEvent read fAfterSeekEvent write fAfterSeekEvent;
    property OnAfterSeekCallback: TNotifyCallback read fAfterSeekCallback write fAfterSeekCallback;
    property OnAfterSeek: TNotifyEvent read fAfterSeekEvent write fAfterSeekEvent;
    property OnSeekEvent: TNotifyEvent read fBeforeSeekEvent write fBeforeSeekEvent;
    property OnSeekCallback: TNotifyCallback read fBeforeSeekCallback write fBeforeSeekCallback;
    property OnSeek: TNotifyEvent read fBeforeSeekEvent write fBeforeSeekEvent;
    property OnBeforeWriteEvent: TNotifyEvent read fBeforeWriteEvent write fBeforeWriteEvent;
    property OnBeforeWriteCallback: TNotifyCallback read fBeforeWriteCallback write fBeforeWriteCallback;
    property OnBeforeWrite: TNotifyEvent read fBeforeWriteEvent write fBeforeWriteEvent;
    property OnAfterWriteEvent: TNotifyEvent read fAfterWriteEvent write fAfterWriteEvent;
    property OnAfterWriteCallback: TNotifyCallback read fAfterWriteCallback write fAfterWriteCallback;
    property OnAfterWrite: TNotifyEvent read fAfterWriteEvent write fAfterWriteEvent;
    property OnWriteEvent: TNotifyEvent read fBeforeWriteEvent write fBeforeWriteEvent;
    property OnWriteCallback: TNotifyCallback read fBeforeWriteCallback write fBeforeWriteCallback;
    property OnWrite: TNotifyEvent read fBeforeWriteEvent write fBeforeWriteEvent;
  end;

implementation

{===============================================================================
--------------------------------------------------------------------------------
                               TNotifyLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TNotifyLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TNotifyLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TNotifyLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
DoBeforeSeek;
Result := SeekOut(Offset,Origin);
DoAfterSeek;
end;

//------------------------------------------------------------------------------

Function TNotifyLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
DoBeforeRead;
Result := ReadOut(Buffer,Size);
DoAfterRead;
end;

//------------------------------------------------------------------------------

procedure TNotifyLayerReader.DoBeforeSeek;
begin
If Assigned(fBeforeSeekEvent) then
  fBeforeSeekEvent(Self);
If Assigned(fBeforeSeekCallback) then
  fBeforeSeekCallback(Self);
end;

//------------------------------------------------------------------------------

procedure TNotifyLayerReader.DoAfterSeek;
begin
If Assigned(fAfterSeekEvent) then
  fAfterSeekEvent(Self);
If Assigned(fAfterSeekCallback) then
  fAfterSeekCallback(Self);
end;

//------------------------------------------------------------------------------

procedure TNotifyLayerReader.DoBeforeRead;
begin
If Assigned(fBeforeReadEvent) then
  fBeforeReadEvent(Self);
If Assigned(fBeforeReadCallback) then
  fBeforeReadCallback(Self);
end;

//------------------------------------------------------------------------------

procedure TNotifyLayerReader.DoAfterRead;
begin
If Assigned(fAfterReadEvent) then
  fAfterReadEvent(Self);
If Assigned(fAfterReadCallback) then
  fAfterReadCallback(Self);
end;

{-------------------------------------------------------------------------------
    TNotifyLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TNotifyLayerReader.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobPassthrough,lobObserver];
end;


{===============================================================================
--------------------------------------------------------------------------------
                               TNotifyLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TNotifyLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TNotifyLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TNotifyLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
DoBeforeSeek;
Result := SeekOut(Offset,Origin);
DoAfterSeek;
end;

//------------------------------------------------------------------------------

Function TNotifyLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
DoBeforeWrite;
Result := WriteOut(Buffer,Size);
DoAfterWrite;
end;

//------------------------------------------------------------------------------

procedure TNotifyLayerWriter.DoBeforeSeek;
begin
If Assigned(fBeforeSeekEvent) then
  fBeforeSeekEvent(Self);
If Assigned(fBeforeSeekCallback) then
  fBeforeSeekCallback(Self);
end;

//------------------------------------------------------------------------------

procedure TNotifyLayerWriter.DoAfterSeek;
begin
If Assigned(fAfterSeekEvent) then
  fAfterSeekEvent(Self);
If Assigned(fAfterSeekCallback) then
  fAfterSeekCallback(Self);
end;

//------------------------------------------------------------------------------

procedure TNotifyLayerWriter.DoBeforeWrite;
begin
If Assigned(fBeforeWriteEvent) then
  fBeforeWriteEvent(Self);
If Assigned(fBeforeWriteCallback) then
  fBeforeWriteCallback(Self);
end;

//------------------------------------------------------------------------------

procedure TNotifyLayerWriter.DoAfterWrite;
begin
If Assigned(fAfterWriteEvent) then
  fAfterWriteEvent(Self);
If Assigned(fAfterWriteCallback) then
  fAfterWriteCallback(Self);
end;

{-------------------------------------------------------------------------------
    TNotifyLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TNotifyLayerWriter.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobPassthrough,lobObserver];
end;

end.
