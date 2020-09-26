unit LSStopLayer;

interface

uses
  Classes,
  SimpleNamedValues,  
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                TStopLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStopLayerReader - class declaration
===============================================================================}

type
  TStopLayerReader = class(TLSLayerReader)
  private
    fStopSeek:  Boolean;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectKind: TLSLayerObjectKind; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); overload; override;
    property StopSeek: Boolean read fStopSeek write fStopSeek;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TStopLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStopLayerWriter - class declaration
===============================================================================}
type
  TStopLayerWriter = class(TLSLayerWriter)
  private
    fStopSeek:  Boolean;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectKind: TLSLayerObjectKind; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); overload; override;
    property StopSeek: Boolean read fStopSeek write fStopSeek;
  end;

implementation

{===============================================================================
--------------------------------------------------------------------------------
                                TStopLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStopLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TStopLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TStopLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
If fStopSeek then
  Result := 0
else
  Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStopLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
Result := 0;
end;

//------------------------------------------------------------------------------

procedure TStopLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fStopSeek := False;
If Assigned(Params) then
  If Params.Exists('TStopLayerReader.StopSeek',nvtBool) then
    fStopSeek := Params.BoolValue['TStopLayerReader.StopSeek'];
end;

{-------------------------------------------------------------------------------
    TStopLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TStopLayerReader.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobConsumer];
end;

//------------------------------------------------------------------------------

class Function TStopLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TStopLayerReader.StopSeek',nvtBool,[loprConstructor,loprInitializer],'Stop seeking requests');
end;

//------------------------------------------------------------------------------

procedure TStopLayerReader.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  If Params.Exists('TStopLayerReader.StopSeek',nvtBool) then
    fStopSeek := Params.BoolValue['TStopLayerReader.StopSeek'];
end;


{===============================================================================
--------------------------------------------------------------------------------
                                TStopLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TStopLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TStopLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TStopLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
If fStopSeek then
  Result := 0
else
  Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStopLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
Result := 0;
end;

//------------------------------------------------------------------------------

procedure TStopLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fStopSeek := False;
If Assigned(Params) then
  If Params.Exists('TStopLayerWriter.StopSeek',nvtBool) then
    fStopSeek := Params.BoolValue['TStopLayerWriter.StopSeek'];
end;

{-------------------------------------------------------------------------------
    TStopLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TStopLayerWriter.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobConsumer];
end;

//------------------------------------------------------------------------------

class Function TStopLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TStopLayerWriter.StopSeek',nvtBool,[loprConstructor,loprInitializer],'Stop seeking requests');
end;

//------------------------------------------------------------------------------

procedure TStopLayerWriter.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  If Params.Exists('TStopLayerWriter.StopSeek',nvtBool) then
    fStopSeek := Params.BoolValue['TStopLayerWriter.StopSeek'];
end;

end.
