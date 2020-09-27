unit LSCRC32Layer;

interface

uses
  Classes,
  SimpleNamedValues, CRC32,
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                               TCRC32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCRC32LayerReader - class declaration
===============================================================================}
type
  TCRC32LayerReader = class(TLSLayerReader)
  private
    fHasher:  TCRC32BaseHash;
    Function GetCRC32: TCRC32;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectKind: TLSLayerObjectKind; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); overload; override;
    procedure Final; override;
    property Hasher: TCRC32BaseHash read fHasher;
    property CRC32: TCRC32 read GetCRC32;
  end;

implementation

{===============================================================================
--------------------------------------------------------------------------------
                               TCRC32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCRC32LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCRC32LayerReader - private methods
-------------------------------------------------------------------------------}

Function TCRC32LayerReader.GetCRC32: TCRC32;
begin
Result := fHasher.CRC32;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerReader - protected methods
-------------------------------------------------------------------------------}

Function TCRC32LayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TCRC32LayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
Result := ReadOut(Buffer,Size);
fHasher.Update(Buffer,Result);
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TCRC32LayerReader.Class',nvtInteger) then
      case Params.IntegerValue['TCRC32LayerReader.Class'] of
        0:  fHasher := TCRC32Hash.Create;
        1:  fHasher := TCRC32CHash.Create;
        2:  begin
              fHasher := TCRC32CustomHash.Create;
              If Params.Exists('TCRC32LayerReader.PresetIndex',nvtInteger) then
                TCRC32CustomHash(fHasher).LoadPreset(Params.IntegerValue['TCRC32LayerReader.PresetIndex'])
              else If Params.Exists('TCRC32LayerReader.PresetName',nvtString) then
                TCRC32CustomHash(fHasher).LoadPreset(Params.StringValue['TCRC32LayerReader.PresetName'])
              else
                begin
                  If Params.Exists('TCRC32LayerReader.Polynomial',nvtInteger) then
                    TCRC32CustomHash(fHasher).CRC32Poly := TCRC32Sys(Params.IntegerValue['TCRC32LayerReader.Polynomial'])
                  else If Params.Exists('TCRC32LayerReader.PolynomialRef',nvtInteger) then
                    TCRC32CustomHash(fHasher).CRC32PolyRef := TCRC32Sys(Params.IntegerValue['TCRC32LayerReader.PolynomialRef']);
                  If Params.Exists('TCRC32LayerReader.InitialValue',nvtInteger) then
                    TCRC32CustomHash(fHasher).InitialValue := TCRC32(Params.IntegerValue['TCRC32LayerReader.InitialValue']);
                  If Params.Exists('TCRC32LayerReader.ReflectIn',nvtBool) then
                    TCRC32CustomHash(fHasher).ReflectIn := Params.BoolValue['TCRC32LayerReader.ReflectIn'];
                  If Params.Exists('TCRC32LayerReader.ReflectOut',nvtBool) then
                    TCRC32CustomHash(fHasher).ReflectOut := Params.BoolValue['TCRC32LayerReader.ReflectOut'];
                  If Params.Exists('TCRC32LayerReader.XOROutValue',nvtInteger) then
                    TCRC32CustomHash(fHasher).XOROutValue := TCRC32(Params.IntegerValue['TCRC32LayerReader.XOROutValue']);
                end;
            end;
      else
        fHasher := TCRC32Hash.Create;
      end
    else fHasher := TCRC32Hash.Create;
  end
else fHasher := TCRC32Hash.Create;
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerReader.Finalize;
begin
fHasher.Free;
inherited;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerReader - public methods
-------------------------------------------------------------------------------}

class Function TCRC32LayerReader.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobPassthrough,lobObserver,lobNeedsInit,lobNeedsFinal];
end;

//------------------------------------------------------------------------------

class Function TCRC32LayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,9);
Result[0] := LayerObjectParam('TCRC32LayerReader.Class',nvtInteger,[loprConstructor],'');
Result[1] := LayerObjectParam('TCRC32LayerReader.PresetIndex',nvtInteger,[loprConstructor],'');
Result[2] := LayerObjectParam('TCRC32LayerReader.PresetName',nvtInteger,[loprConstructor],'');
Result[3] := LayerObjectParam('TCRC32LayerReader.Polynomial',nvtInteger,[loprConstructor],'');
Result[4] := LayerObjectParam('TCRC32LayerReader.PolynomialRef',nvtInteger,[loprConstructor],'');
Result[5] := LayerObjectParam('TCRC32LayerReader.InitialValue',nvtInteger,[loprConstructor],'');
Result[6] := LayerObjectParam('TCRC32LayerReader.ReflectIn',nvtBool,[loprConstructor],'');
Result[7] := LayerObjectParam('TCRC32LayerReader.ReflectOut',nvtBool,[loprConstructor],'');
Result[8] := LayerObjectParam('TCRC32LayerReader.XOROutValue',nvtInteger,[loprConstructor],'');
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerReader.Init(Params: TSimpleNamedValues);
begin
inherited;
fHasher.Init;
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerReader.Final;
begin
fHasher.Final;
inherited;
end;

end.
