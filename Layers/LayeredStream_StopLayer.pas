unit LayeredStream_StopLayer;

{$IFDEF FPC}
  {$MODE ObjFPC}
{$ENDIF}
{$H+}

interface

uses
  SysUtils, Classes,
  SimpleNamedValues,  
  LayeredStream;

{===============================================================================
    Stop exception
===============================================================================}
type
  TLayerStopException = class(Exception);

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
    fStopSeek:    Boolean;
    fSilentStop:  Boolean;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Update(Params: TSimpleNamedValues); override;
    property StopSeek: Boolean read fStopSeek write fStopSeek;
    property SilentStop: Boolean read fSilentStop write fSilentStop;
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
    fStopSeek:    Boolean;
    fSilentStop:  Boolean;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Update(Params: TSimpleNamedValues); override;
    property StopSeek: Boolean read fStopSeek write fStopSeek;
    property SilentStop: Boolean read fSilentStop write fSilentStop;
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
  begin
    If fSilentStop then
      Result := 0
    else
      raise TLayerStopException.CreateFmt('TStopLayerReader.SeekActive: Stopped seek (%d,%d).',[Offset,Ord(Origin)]);
  end
else Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStopLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
If fSilentStop then
  Result := 0
else
  raise TLayerStopException.CreateFmt('TStopLayerReader.ReadActive: Stopped read (%p,%d).',[@Buffer,Size]);
end;

//------------------------------------------------------------------------------

procedure TStopLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fStopSeek := False;
fSilentStop := True;
If Assigned(Params) then
  begin
    If Params.Exists('TStopLayerReader.StopSeek',nvtBool) then
      fStopSeek := Params.BoolValue['TStopLayerReader.StopSeek'];
    If Params.Exists('TStopLayerReader.SilentStop',nvtBool) then
      fSilentStop := Params.BoolValue['TStopLayerReader.SilentStop'];
  end;
end;

{-------------------------------------------------------------------------------
    TStopLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TStopLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopStopper];
end;

//------------------------------------------------------------------------------

class Function TStopLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TStopLayerReader.StopSeek',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TStopLayerReader.SilentStop',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
end;

//------------------------------------------------------------------------------

procedure TStopLayerReader.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TStopLayerReader.StopSeek',nvtBool) then
      fStopSeek := Params.BoolValue['TStopLayerReader.StopSeek'];
    If Params.Exists('TStopLayerReader.SilentStop',nvtBool) then
      fSilentStop := Params.BoolValue['TStopLayerReader.SilentStop'];
  end;
end;

//------------------------------------------------------------------------------

procedure TStopLayerReader.Update(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TStopLayerReader.StopSeek',nvtBool) then
      fStopSeek := Params.BoolValue['TStopLayerReader.StopSeek'];
    If Params.Exists('TStopLayerReader.SilentStop',nvtBool) then
      fSilentStop := Params.BoolValue['TStopLayerReader.SilentStop'];
  end;
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
  begin
    If fSilentStop then
      Result := 0
    else
      raise TLayerStopException.CreateFmt('TStopLayerWriter.SeekActive: Stopped seek (%d,%d).',[Offset,Ord(Origin)]);
  end
else Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TStopLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
If fSilentStop then
  Result := 0
else
  raise TLayerStopException.CreateFmt('TStopLayerWriter.WriteActive: Stopped write (%p,%d).',[@Buffer,Size]);
end;

//------------------------------------------------------------------------------

procedure TStopLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fStopSeek := False;
fSilentStop := True;
If Assigned(Params) then
  begin
    If Params.Exists('TStopLayerWriter.StopSeek',nvtBool) then
      fStopSeek := Params.BoolValue['TStopLayerWriter.StopSeek'];
    If Params.Exists('TStopLayerWriter.SilentStop',nvtBool) then
      fSilentStop := Params.BoolValue['TStopLayerWriter.SilentStop'];
  end;
end;

{-------------------------------------------------------------------------------
    TStopLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TStopLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopStopper];
end;

//------------------------------------------------------------------------------

class Function TStopLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TStopLayerWriter.StopSeek',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TStopLayerWriter.SilentStop',nvtBool,[loprConstructor,loprInitializer,loprUpdater]);
end;

//------------------------------------------------------------------------------

procedure TStopLayerWriter.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TStopLayerWriter.StopSeek',nvtBool) then
      fStopSeek := Params.BoolValue['TStopLayerWriter.StopSeek'];
    If Params.Exists('TStopLayerWriter.SilentStop',nvtBool) then
      fSilentStop := Params.BoolValue['TStopLayerWriter.SilentStop'];
  end;
end;

//------------------------------------------------------------------------------

procedure TStopLayerWriter.Update(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TStopLayerWriter.StopSeek',nvtBool) then
      fStopSeek := Params.BoolValue['TStopLayerWriter.StopSeek'];
    If Params.Exists('TStopLayerWriter.SilentStop',nvtBool) then
      fSilentStop := Params.BoolValue['TStopLayerWriter.SilentStop'];
  end;
end;

end.
