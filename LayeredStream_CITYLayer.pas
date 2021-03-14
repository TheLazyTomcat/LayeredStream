unit LayeredStream_CITYLayer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, HashBase, CITY, CITY_Common,
  LayeredStream_Layers,
  LayeredStream_HashLayer;

{===============================================================================
    Values and helpers for parameters passing
===============================================================================}
const
  CITY_VERSION_Default = 0;
  CITY_VERSION_Latest  = 1;
  CITY_VERSION_1_0_0   = 2;
  CITY_VERSION_1_0_1   = 3;
  CITY_VERSION_1_0_2   = 4;
  CITY_VERSION_1_0_3   = 5;
  CITY_VERSION_1_1_0   = 6;
  CITY_VERSION_1_1_1   = 7;

  CITY_VARIANT_Plain = 0;
  CITY_VARIANT_Seed  = 1;
  CITY_VARIANT_Seeds = 2;

Function CITYVersionToInteger(CityVersion: TCITYVersion): Integer;
Function CITYVersionFromInteger(Value: Integer): TCITYVersion;

Function CITYVariantToInteger(CityVariant: TCITYVariant): Integer;
Function CITYVariantFromInteger(Value: Integer): TCITYVariant;

{===============================================================================
--------------------------------------------------------------------------------
                                TCITYLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYLayerReader - class declaration
===============================================================================}
type
  TCITYLayerReader = class(TBlockHashLayerReader)
  private
    Function GetCITYHasher: TCITYHash;
  protected
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property CITYHasher: TCITYHash read GetCITYHasher;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TCITYLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYLayerWriter - class declaration
===============================================================================}
type
  TCITYLayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetCITYHasher: TCITYHash;
  protected
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property CITYHasher: TCITYHash read GetCITYHasher;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TCITY32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY32LayerReader - class declaration
===============================================================================}
type
  TCITY32LayerReader = class(TCITYLayerReader)
  private
    Function GetCITY32Hasher: TCITY32Hash;
    Function GetCITY32: TCITY32;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property CITY32Hasher: TCITY32Hash read GetCITY32Hasher;
    property CITY32: TCITY32 read GetCITY32;
    property CITY: TCITY32 read GetCITY32;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TCITY32LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY32LayerWriter - class declaration
===============================================================================}
type
  TCITY32LayerWriter = class(TCITYLayerWriter)
  private
    Function GetCITY32Hasher: TCITY32Hash;
    Function GetCITY32: TCITY32;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property CITY32Hasher: TCITY32Hash read GetCITY32Hasher;
    property CITY32: TCITY32 read GetCITY32;
    property CITY: TCITY32 read GetCITY32;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TCITY64LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY64LayerReader - class declaration
===============================================================================}
type
  TCITY64LayerReader = class(TCITYLayerReader)
  private
    Function GetCITY64Hasher: TCITY64Hash;
    Function GetCITY64: TCITY64;
  protected
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property CITY64Hasher: TCITY64Hash read GetCITY64Hasher;
    property CITY64: TCITY64 read GetCITY64;
    property CITY: TCITY64 read GetCITY64;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TCITY64LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY64LayerWriter - class declaration
===============================================================================}
type
  TCITY64LayerWriter = class(TCITYLayerWriter)
  private
    Function GetCITY64Hasher: TCITY64Hash;
    Function GetCITY64: TCITY64;
  protected
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property CITY64Hasher: TCITY64Hash read GetCITY64Hasher;
    property CITY64: TCITY64 read GetCITY64;
    property CITY: TCITY64 read GetCITY64;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TCITY128LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY128LayerReader - class declaration
===============================================================================}
type
  TCITY128LayerReader = class(TCITYLayerReader)
  private
    Function GetCITY128Hasher: TCITY128Hash;
    Function GetCITY128: TCITY128;
  protected
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
    class Function HasherClass: THashClass; virtual;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property CITY128Hasher: TCITY128Hash read GetCITY128Hasher;
    property CITY128: TCITY128 read GetCITY128;
    property CITY: TCITY128 read GetCITY128;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TCITY128LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY128LayerWriter - class declaration
===============================================================================}
type
  TCITY128LayerWriter = class(TCITYLayerWriter)
  private
    Function GetCITY128Hasher: TCITY128Hash;
    Function GetCITY128: TCITY128;
  protected
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
    class Function HasherClass: THashClass; virtual;
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property CITY128Hasher: TCITY128Hash read GetCITY128Hasher;
    property CITY128: TCITY128 read GetCITY128;
    property CITY: TCITY128 read GetCITY128;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCITYCRC256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYCRC256LayerReader - class declaration
===============================================================================}
type
  TCITYCRC256LayerReader = class(TCITYLayerReader)
  private
    Function GetCITYCRC256Hasher: TCITYCRC256Hash;
    Function GetCITY256: TCITY256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property CITYCRC256Hasher: TCITYCRC256Hash read GetCITYCRC256Hasher;
    property CITY256: TCITY256 read GetCITY256;
    property CITY: TCITY256 read GetCITY256;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCITYCRC256LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYCRC256LayerWriter - class declaration
===============================================================================}
type
  TCITYCRC256LayerWriter = class(TCITYLayerWriter)
  private
    Function GetCITYCRC256Hasher: TCITYCRC256Hash;
    Function GetCITY256: TCITY256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property CITYCRC256Hasher: TCITYCRC256Hash read GetCITYCRC256Hasher;
    property CITY256: TCITY256 read GetCITY256;
    property CITY: TCITY256 read GetCITY256;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCITYCRC128LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYCRC128LayerReader - class declaration
===============================================================================}
type
  TCITYCRC128LayerReader = class(TCITY128LayerReader)
  private
    Function GetCITYCRC128Hasher: TCITYCRC128Hash;
  protected
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
    class Function HasherClass: THashClass; override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property CITYCRC128Hasher: TCITYCRC128Hash read GetCITYCRC128Hasher;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCITYCRC128LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYCRC128LayerWriter - class declaration
===============================================================================}
type
  TCITYCRC128LayerWriter = class(TCITY128LayerWriter)
  private
    Function GetCITYCRC128Hasher: TCITYCRC128Hash;
  protected
    procedure ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver); override;
    class Function HasherClass: THashClass; override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property CITYCRC128Hasher: TCITYCRC128Hash read GetCITYCRC128Hasher;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
    Values and helpers for parameters passing
===============================================================================}

Function CITYVersionToInteger(CityVersion: TCITYVersion): Integer;
begin
case CityVersion of
  verDefault: Result := CITY_VERSION_Default;
  verLatest:  Result := CITY_VERSION_Latest;
  verCITY100: Result := CITY_VERSION_1_0_0;
  verCITY101: Result := CITY_VERSION_1_0_1;
  verCITY102: Result := CITY_VERSION_1_0_2;
  verCITY103: Result := CITY_VERSION_1_0_3;
  verCITY110: Result := CITY_VERSION_1_1_0;
  verCITY111: Result := CITY_VERSION_1_1_1;
else
  raise ELSInvalidValue.CreateFmt('CITYVersionToInteger: Invalid CITY version (%d).',[Ord(CityVersion)]);
end;
end;

//------------------------------------------------------------------------------

Function CITYVersionFromInteger(Value: Integer): TCITYVersion;
begin
case Value of
  CITY_VERSION_Default: Result := verDefault;
  CITY_VERSION_Latest:  Result := verLatest;
  CITY_VERSION_1_0_0:   Result := verCITY100;
  CITY_VERSION_1_0_1:   Result := verCITY101;
  CITY_VERSION_1_0_2:   Result := verCITY102;
  CITY_VERSION_1_0_3:   Result := verCITY103;
  CITY_VERSION_1_1_0:   Result := verCITY110;
  CITY_VERSION_1_1_1:   Result := verCITY111;
else
  raise ELSInvalidValue.CreateFmt('CITYVersionFromInteger: Invalid CITY version (%d).',[Value]);
end;
end;

//------------------------------------------------------------------------------

Function CITYVariantToInteger(CityVariant: TCITYVariant): Integer;
begin
case CityVariant of
  varPlain: Result := CITY_VARIANT_Plain;
  varSeed:  Result := CITY_VARIANT_Seed;
  varSeeds: Result := CITY_VARIANT_Seeds;
else
  raise ELSInvalidValue.CreateFmt('CITYVariantToInteger: Invalid CITY variant (%d).',[Ord(CityVariant)]);
end;
end;

//------------------------------------------------------------------------------

Function CITYVariantFromInteger(Value: Integer): TCITYVariant;
begin
case Value of
  CITY_VARIANT_Plain: Result := varPlain;
  CITY_VARIANT_Seed:  Result := varSeed;
  CITY_VARIANT_Seeds: Result := varSeeds;
else
  raise ELSInvalidValue.CreateFmt('CITYVariantFromInteger: Invalid CITY variant (%d).',[Value]);
end;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TCITYLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCITYLayerReader - private methods
-------------------------------------------------------------------------------}

Function TCITYLayerReader.GetCITYHasher: TCITYHash;
begin
Result := TCITYHash(fHasher);
end;

{-------------------------------------------------------------------------------
    TCITYLayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TCITYLayerReader.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
var
  Temp: Integer;
begin
inherited;
Temp := 0;
If GetIntegerNamedValue(Params,'TCITYLayerReader.CityVersion',Temp) then
  TCITYHash(fHasher).CityVersion := CITYVersionFromInteger(Temp);
If GetIntegerNamedValue(Params,'TCITYLayerReader.CityVariant',Temp) then
  TCITYHash(fHasher).CityVariant := CITYVariantFromInteger(Temp);
end;

{-------------------------------------------------------------------------------
    TCITYLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TCITYLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TCITYLayerReader.CityVersion',nvtInteger,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TCITYLayerReader.CityVariant',nvtInteger,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TCITYLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCITYLayerWriter - private methods
-------------------------------------------------------------------------------}

Function TCITYLayerWriter.GetCITYHasher: TCITYHash;
begin
Result := TCITYHash(fHasher);
end;

{-------------------------------------------------------------------------------
    TCITYLayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TCITYLayerWriter.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
var
  Temp: Integer;
begin
inherited;
Temp := 0;
If GetIntegerNamedValue(Params,'TCITYLayerWriter.CityVersion',Temp) then
  TCITYHash(fHasher).CityVersion := CITYVersionFromInteger(Temp);
If GetIntegerNamedValue(Params,'TCITYLayerWriter.CityVariant',Temp) then
  TCITYHash(fHasher).CityVariant := CITYVariantFromInteger(Temp);
end;

{-------------------------------------------------------------------------------
    TCITYLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TCITYLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TCITYLayerWriter.CityVersion',nvtInteger,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TCITYLayerWriter.CityVariant',nvtInteger,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;          

{===============================================================================
--------------------------------------------------------------------------------
                               TCITY32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY32LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCITY32LayerReader - private methods
-------------------------------------------------------------------------------}

Function TCITY32LayerReader.GetCITY32Hasher: TCITY32Hash;
begin
Result := TCITY32Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TCITY32LayerReader.GetCITY32: TCITY32;
begin
Result := TCITY32Hash(fHasher).City32;
end;

{-------------------------------------------------------------------------------
    TCITY32LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TCITY32LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TCITY32Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                               TCITY32LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY32LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCITY32LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TCITY32LayerWriter.GetCITY32Hasher: TCITY32Hash;
begin
Result := TCITY32Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TCITY32LayerWriter.GetCITY32: TCITY32;
begin
Result := TCITY32Hash(fHasher).City32;
end;

{-------------------------------------------------------------------------------
    TCITY32LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TCITY32LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TCITY32Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                               TCITY64LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY64LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCITY64LayerReader - private methods
-------------------------------------------------------------------------------}

Function TCITY64LayerReader.GetCITY64Hasher: TCITY64Hash;
begin
Result := TCITY64Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TCITY64LayerReader.GetCITY64: TCITY64;
begin
Result := TCITY64Hash(fHasher).City64;
end;

{-------------------------------------------------------------------------------
    TCITY64LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TCITY64LayerReader.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
var
  Temp: Int64;
begin
inherited;
Temp := 0;
If GetIntegerNamedValue(Params,'TCITY64LayerReader.Seed',Temp) then
  TCITY64Hash(fHasher).Seed := UInt64(Temp);
If GetIntegerNamedValue(Params,'TCITY64LayerReader.Seed0',Temp) then
  TCITY64Hash(fHasher).Seed0 := UInt64(Temp);
If GetIntegerNamedValue(Params,'TCITY64LayerReader.Seed1',Temp) then
  TCITY64Hash(fHasher).Seed1 := UInt64(Temp);
end;

//------------------------------------------------------------------------------

procedure TCITY64LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TCITY64Hash.Create;
inherited;
end;

{-------------------------------------------------------------------------------
    TCITY64LayerReader - public methods
-------------------------------------------------------------------------------}

class Function TCITY64LayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,3);
Result[0] := LayerObjectParam('TCITY64LayerReader.Seed',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TCITY64LayerReader.Seed0',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
Result[2] := LayerObjectParam('TCITY64LayerReader.Seed1',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
--------------------------------------------------------------------------------
                               TCITY64LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY64LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCITY64LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TCITY64LayerWriter.GetCITY64Hasher: TCITY64Hash;
begin
Result := TCITY64Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TCITY64LayerWriter.GetCITY64: TCITY64;
begin
Result := TCITY64Hash(fHasher).City64;
end;

{-------------------------------------------------------------------------------
    TCITY64LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TCITY64LayerWriter.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
var
  Temp: Int64;
begin
inherited;
Temp := 0;
If GetIntegerNamedValue(Params,'TCITY64LayerWriter.Seed',Temp) then
  TCITY64Hash(fHasher).Seed := UInt64(Temp);
If GetIntegerNamedValue(Params,'TCITY64LayerWriter.Seed0',Temp) then
  TCITY64Hash(fHasher).Seed0 := UInt64(Temp);
If GetIntegerNamedValue(Params,'TCITY64LayerWriter.Seed1',Temp) then
  TCITY64Hash(fHasher).Seed1 := UInt64(Temp);
end;

//------------------------------------------------------------------------------

procedure TCITY64LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TCITY64Hash.Create;
inherited;
end;

{-------------------------------------------------------------------------------
    TCITY64LayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TCITY64LayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,3);
Result[0] := LayerObjectParam('TCITY64LayerWriter.Seed',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TCITY64LayerWriter.Seed0',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
Result[2] := LayerObjectParam('TCITY64LayerWriter.Seed1',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TCITY128LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY128LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCITY128LayerReader - private methods
-------------------------------------------------------------------------------}

Function TCITY128LayerReader.GetCITY128Hasher: TCITY128Hash;
begin
Result := TCITY128Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TCITY128LayerReader.GetCITY128: TCITY128;
begin
Result := TCITY128Hash(fHasher).City128;
end;

{-------------------------------------------------------------------------------
    TCITY128LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TCITY128LayerReader.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
var
  SeedPtr:  Pointer;
  SeedTemp: UInt128;
begin
inherited;
SeedPtr := nil;
FillChar(Addr(SeedTemp)^,SizeOf(UInt128),0);
If not GetNamedValue(Params,'TCITY128LayerReader.Seed',SeedPtr) then
  begin
    If GetIntegerNamedValue(Params,'TCITY128LayerReader.SeedLow',SeedTemp.Low) and
       GetIntegerNamedValue(Params,'TCITY128LayerReader.SeedHigh',SeedTemp.High) then
      TCITY128Hash(fHasher).Seed := SeedTemp;
  end
else TCITY128Hash(fHasher).Seed := UInt128(SeedPtr^);
end;

//------------------------------------------------------------------------------

class Function TCITY128LayerReader.HasherClass: THashClass;
begin
Result := TCITY128Hash;
end;

//------------------------------------------------------------------------------

procedure TCITY128LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := HasherClass.Create;
inherited;
end;

{-------------------------------------------------------------------------------
    TCITY128LayerReader - public methods
-------------------------------------------------------------------------------}

class Function TCITY128LayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,3);
Result[0] := LayerObjectParam('TCITY128LayerReader.Seed',nvtPointer,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TCITY128LayerReader.SeedLow',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
Result[2] := LayerObjectParam('TCITY128LayerReader.SeedHigh',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TCITY128LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITY128LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCITY128LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TCITY128LayerWriter.GetCITY128Hasher: TCITY128Hash;
begin
Result := TCITY128Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TCITY128LayerWriter.GetCITY128: TCITY128;
begin
Result := TCITY128Hash(fHasher).City128;
end;

{-------------------------------------------------------------------------------
    TCITY128LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TCITY128LayerWriter.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
var
  SeedPtr:  Pointer;
  SeedTemp: UInt128;
begin
inherited;
SeedPtr := nil;
FillChar(Addr(SeedTemp)^,SizeOf(UInt128),0);
If not GetNamedValue(Params,'TCITY128LayerWriter.Seed',SeedPtr) then
  begin
    If GetIntegerNamedValue(Params,'TCITY128LayerWriter.SeedLow',SeedTemp.Low) and
       GetIntegerNamedValue(Params,'TCITY128LayerWriter.SeedHigh',SeedTemp.High) then
      TCITY128Hash(fHasher).Seed := SeedTemp;
  end
else TCITY128Hash(fHasher).Seed := UInt128(SeedPtr^);
end;

//------------------------------------------------------------------------------

class Function TCITY128LayerWriter.HasherClass: THashClass;
begin
Result := TCITY128Hash;
end;

//------------------------------------------------------------------------------

procedure TCITY128LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := HasherClass.Create;
inherited;
end;

{-------------------------------------------------------------------------------
    TCITY128LayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TCITY128LayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,3);
Result[0] := LayerObjectParam('TCITY128LayerWriter.Seed',nvtPointer,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TCITY128LayerWriter.SeedLow',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
Result[2] := LayerObjectParam('TCITY128LayerWriter.SeedHigh',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCITYCRC256LayerReader                             
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYCRC256LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCITYCRC256LayerReader - private methods
-------------------------------------------------------------------------------}

Function TCITYCRC256LayerReader.GetCITYCRC256Hasher: TCITYCRC256Hash;
begin
Result := TCITYCRC256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TCITYCRC256LayerReader.GetCITY256: TCITY256;
begin
Result := TCITYCRC256Hash(fHasher).City256;
end;

{-------------------------------------------------------------------------------
    TCITY256LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TCITYCRC256LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TCITYCRC256Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCITYCRC256LayerWriter                             
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYCRC256LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCITYCRC256LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TCITYCRC256LayerWriter.GetCITYCRC256Hasher: TCITYCRC256Hash;
begin
Result := TCITYCRC256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TCITYCRC256LayerWriter.GetCITY256: TCITY256;
begin
Result := TCITYCRC256Hash(fHasher).City256;
end;

{-------------------------------------------------------------------------------
    TCITY256LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TCITYCRC256LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TCITYCRC256Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCITYCRC128LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYCRC128LayerReader - class declaration
===============================================================================}
{-------------------------------------------------------------------------------
    TCITYCRC128LayerReader - private methods
-------------------------------------------------------------------------------}

Function TCITYCRC128LayerReader.GetCITYCRC128Hasher: TCITYCRC128Hash;
begin
Result := TCITYCRC128Hash(fHasher);
end;

{-------------------------------------------------------------------------------
    TCITYCRC128LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TCITYCRC128LayerReader.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
var
  SeedPtr:  Pointer;
  SeedTemp: UInt128;
begin
inherited;
SeedPtr := nil;
FillChar(Addr(SeedTemp)^,SizeOf(UInt128),0);
If not GetNamedValue(Params,'TCITYCRC128LayerReader.Seed',SeedPtr) then
  begin
    If GetIntegerNamedValue(Params,'TCITYCRC128LayerReader.SeedLow',SeedTemp.Low) and
       GetIntegerNamedValue(Params,'TCITYCRC128LayerReader.SeedHigh',SeedTemp.High) then
      TCITYCRC128Hash(fHasher).Seed := SeedTemp;
  end
else TCITYCRC128Hash(fHasher).Seed := UInt128(SeedPtr^);
end;

//------------------------------------------------------------------------------

class Function TCITYCRC128LayerReader.HasherClass: THashClass;
begin
Result := TCITYCRC128Hash;
end;

{-------------------------------------------------------------------------------
    TCITYCRC128LayerReader - public methods
-------------------------------------------------------------------------------}

class Function TCITYCRC128LayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,3);
Result[0] := LayerObjectParam('TCITYCRC128LayerReader.Seed',nvtPointer,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TCITYCRC128LayerReader.SeedLow',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
Result[2] := LayerObjectParam('TCITYCRC128LayerReader.SeedHigh',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TCITYCRC128LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCITYCRC128LayerWriter - class declaration
===============================================================================}
{-------------------------------------------------------------------------------
    TCITYCRC128LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TCITYCRC128LayerWriter.GetCITYCRC128Hasher: TCITYCRC128Hash;
begin
Result := TCITYCRC128Hash(fHasher);
end;

{-------------------------------------------------------------------------------
    TCITYCRC128LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TCITYCRC128LayerWriter.ParamsCommon(Params: TSimpleNamedValues; Caller: TLSLayerObjectParamReceiver);
var
  SeedPtr:  Pointer;
  SeedTemp: UInt128;
begin
inherited;
SeedPtr := nil;
FillChar(Addr(SeedTemp)^,SizeOf(UInt128),0);
If not GetNamedValue(Params,'TCITYCRC128LayerWriter.Seed',SeedPtr) then
  begin
    If GetIntegerNamedValue(Params,'TCITYCRC128LayerWriter.SeedLow',SeedTemp.Low) and
       GetIntegerNamedValue(Params,'TCITYCRC128LayerWriter.SeedHigh',SeedTemp.High) then
      TCITYCRC128Hash(fHasher).Seed := SeedTemp;
  end
else TCITYCRC128Hash(fHasher).Seed := UInt128(SeedPtr^);
end;

//------------------------------------------------------------------------------

class Function TCITYCRC128LayerWriter.HasherClass: THashClass;
begin
Result := TCITYCRC128Hash;
end;

{-------------------------------------------------------------------------------
    TCITYCRC128LayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TCITYCRC128LayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,3);
Result[0] := LayerObjectParam('TCITYCRC128LayerWriter.Seed',nvtPointer,[loprConstructor,loprInitializer,loprUpdater]);
Result[1] := LayerObjectParam('TCITYCRC128LayerWriter.SeedLow',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
Result[2] := LayerObjectParam('TCITYCRC128LayerWriter.SeedHigh',nvtInt64,[loprConstructor,loprInitializer,loprUpdater]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_CITY32',TCITY32LayerReader,TCITY32LayerWriter);
  RegisterLayer('LSRL_CITY64',TCITY64LayerReader,TCITY64LayerWriter);
  RegisterLayer('LSRL_CITY128',TCITY128LayerReader,TCITY128LayerWriter);
  RegisterLayer('LSRL_CITYCRC256',TCITYCRC256LayerReader,TCITYCRC256LayerWriter);
  RegisterLayer('LSRL_CITYCRC128',TCITYCRC128LayerReader,TCITYCRC128LayerWriter);

end.
