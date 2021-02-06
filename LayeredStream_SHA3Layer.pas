unit LayeredStream_SHA3Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, SHA3,
  LayeredStream_Layers,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                               TKeccakLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccakLayerReader - class declaration
===============================================================================}
type
  TKeccakLayerReader = class(TBlockHashLayerReader)
  private
    Function GetKeccakHasher: TKeccakDefHash;
    Function GetKeccak: TKeccak;
  public
    property KeccakHasher: TKeccakDefHash read GetKeccakHasher;
    property Keccak: TKeccak read GetKeccak;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TKeccakLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccakLayerWriter - class declaration
===============================================================================}
type
  TKeccakLayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetKeccakHasher: TKeccakDefHash;
    Function GetKeccak: TKeccak;
  public
    property KeccakHasher: TKeccakDefHash read GetKeccakHasher;
    property Keccak: TKeccak read GetKeccak;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak224LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak224LayerReader - class declaration
===============================================================================}
type
  TKeccak224LayerReader = class(TKeccakLayerReader)
  private
    Function GetKeccak224Hasher: TKeccak224Hash;
    Function GetKeccak224: TKeccak224;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property Keccak224Hasher: TKeccak224Hash read GetKeccak224Hasher;
    property Keccak224: TKeccak224 read GetKeccak224;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak224LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak224LayerWriter - class declaration
===============================================================================}
type
  TKeccak224LayerWriter = class(TKeccakLayerWriter)
  private
    Function GetKeccak224Hasher: TKeccak224Hash;
    Function GetKeccak224: TKeccak224;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property Keccak224Hasher: TKeccak224Hash read GetKeccak224Hasher;
    property Keccak224: TKeccak224 read GetKeccak224;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak256LayerReader - class declaration
===============================================================================}
type
  TKeccak256LayerReader = class(TKeccakLayerReader)
  private
    Function GetKeccak256Hasher: TKeccak256Hash;
    Function GetKeccak256: TKeccak256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property Keccak256Hasher: TKeccak256Hash read GetKeccak256Hasher;
    property Keccak256: TKeccak256 read GetKeccak256;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak256LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak256LayerWriter - class declaration
===============================================================================}
type
  TKeccak256LayerWriter = class(TKeccakLayerWriter)
  private
    Function GetKeccak256Hasher: TKeccak256Hash;
    Function GetKeccak256: TKeccak256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property Keccak256Hasher: TKeccak256Hash read GetKeccak256Hasher;
    property Keccak256: TKeccak256 read GetKeccak256;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak384LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak384LayerReader - class declaration
===============================================================================}
type
  TKeccak384LayerReader = class(TKeccakLayerReader)
  private
    Function GetKeccak384Hasher: TKeccak384Hash;
    Function GetKeccak384: TKeccak384;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property Keccak384Hasher: TKeccak384Hash read GetKeccak384Hasher;
    property Keccak384: TKeccak384 read GetKeccak384;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak384LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak384LayerWriter - class declaration
===============================================================================}
type
  TKeccak384LayerWriter = class(TKeccakLayerWriter)
  private
    Function GetKeccak384Hasher: TKeccak384Hash;
    Function GetKeccak384: TKeccak384;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property Keccak384Hasher: TKeccak384Hash read GetKeccak384Hasher;
    property Keccak384: TKeccak384 read GetKeccak384;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak512LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak512LayerReader - class declaration
===============================================================================}
type
  TKeccak512LayerReader = class(TKeccakLayerReader)
  private
    Function GetKeccak512Hasher: TKeccak512Hash;
    Function GetKeccak512: TKeccak512;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property Keccak512Hasher: TKeccak512Hash read GetKeccak512Hasher;
    property Keccak512: TKeccak512 read GetKeccak512;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak512LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak512LayerWriter - class declaration
===============================================================================}
type
  TKeccak512LayerWriter = class(TKeccakLayerWriter)
  private
    Function GetKeccak512Hasher: TKeccak512Hash;
    Function GetKeccak512: TKeccak512;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property Keccak512Hasher: TKeccak512Hash read GetKeccak512Hasher;
    property Keccak512: TKeccak512 read GetKeccak512;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA3LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3LayerReader - class declaration
===============================================================================}
type
  TSHA3LayerReader = class(TKeccakLayerReader)
  private
    Function GetSHA3Hasher: TSHA3Hash;
    Function GetSHA3: TSHA3;
  public
    property SHA3Hasher: TSHA3Hash read GetSHA3Hasher;
    property SHA3: TSHA3 read GetSHA3;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                 TSHA3LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3LayerWriter - class declaration
===============================================================================}
type
  TSHA3LayerWriter = class(TKeccakLayerWriter)
  private
    Function GetSHA3Hasher: TSHA3Hash;
    Function GetSHA3: TSHA3;
  public
    property SHA3Hasher: TSHA3Hash read GetSHA3Hasher;
    property SHA3: TSHA3 read GetSHA3;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_224LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_224LayerReader - class declaration
===============================================================================}
type
  TSHA3_224LayerReader = class(TSHA3LayerReader)
  private
    Function GetSHA3_224Hasher: TSHA3_224Hash;
    Function GetSHA3_224: TSHA3_224;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA3_224Hasher: TSHA3_224Hash read GetSHA3_224Hasher;
    property SHA3_224: TSHA3_224 read GetSHA3_224;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_224LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_224LayerWriter - class declaration
===============================================================================}
type
  TSHA3_224LayerWriter = class(TSHA3LayerWriter)
  private
    Function GetSHA3_224Hasher: TSHA3_224Hash;
    Function GetSHA3_224: TSHA3_224;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property SHA3_224Hasher: TSHA3_224Hash read GetSHA3_224Hasher;
    property SHA3_224: TSHA3_224 read GetSHA3_224;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_256LayerReader - class declaration
===============================================================================}
type
  TSHA3_256LayerReader = class(TSHA3LayerReader)
  private
    Function GetSHA3_256Hasher: TSHA3_256Hash;
    Function GetSHA3_256: TSHA3_256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA3_256Hasher: TSHA3_256Hash read GetSHA3_256Hasher;
    property SHA3_256: TSHA3_256 read GetSHA3_256;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_256LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_256LayerWriter - class declaration
===============================================================================}
type
  TSHA3_256LayerWriter = class(TSHA3LayerWriter)
  private
    Function GetSHA3_256Hasher: TSHA3_256Hash;
    Function GetSHA3_256: TSHA3_256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property SHA3_256Hasher: TSHA3_256Hash read GetSHA3_256Hasher;
    property SHA3_256: TSHA3_256 read GetSHA3_256;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_384LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_384LayerReader - class declaration
===============================================================================}
type
  TSHA3_384LayerReader = class(TSHA3LayerReader)
  private
    Function GetSHA3_384Hasher: TSHA3_384Hash;
    Function GetSHA3_384: TSHA3_384;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA3_384Hasher: TSHA3_384Hash read GetSHA3_384Hasher;
    property SHA3_384: TSHA3_384 read GetSHA3_384;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_384LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_384LayerWriter - class declaration
===============================================================================}
type
  TSHA3_384LayerWriter = class(TSHA3LayerWriter)
  private
    Function GetSHA3_384Hasher: TSHA3_384Hash;
    Function GetSHA3_384: TSHA3_384;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property SHA3_384Hasher: TSHA3_384Hash read GetSHA3_384Hasher;
    property SHA3_384: TSHA3_384 read GetSHA3_384;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_512LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_512LayerReader - class declaration
===============================================================================}
type
  TSHA3_512LayerReader = class(TSHA3LayerReader)
  private
    Function GetSHA3_512Hasher: TSHA3_512Hash;
    Function GetSHA3_512: TSHA3_512;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA3_512Hasher: TSHA3_512Hash read GetSHA3_512Hasher;
    property SHA3_512: TSHA3_512 read GetSHA3_512;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_512LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_512LayerWriter - class declaration
===============================================================================}
type
  TSHA3_512LayerWriter = class(TSHA3LayerWriter)
  private
    Function GetSHA3_512Hasher: TSHA3_512Hash;
    Function GetSHA3_512: TSHA3_512;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA3_512Hasher: TSHA3_512Hash read GetSHA3_512Hasher;
    property SHA3_512: TSHA3_512 read GetSHA3_512;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TKeccakCLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccakCLayerReader - class declaration
===============================================================================}
type
  TKeccakCLayerReader = class(TKeccakLayerReader)
  private
    Function GetKeccakCHasher: TKeccakCHash;
    Function GetKeccakC: TKeccakC;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    property KeccakCHasher: TKeccakCHash read GetKeccakCHasher;
    property KeccakC: TKeccakC read GetKeccakC;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TKeccakCLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccakCLayerWriter - class declaration
===============================================================================}
type
  TKeccakCLayerWriter = class(TKeccakLayerWriter)
  private
    Function GetKeccakCHasher: TKeccakCHash;
    Function GetKeccakC: TKeccakC;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    property KeccakCHasher: TKeccakCHash read GetKeccakCHasher;
    property KeccakC: TKeccakC read GetKeccakC;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHAKE128LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHAKE128LayerReader - class declaration
===============================================================================}
type
  TSHAKE128LayerReader = class(TKeccakLayerReader)
  private
    Function GetSHAKE128Hasher: TSHAKE128Hash;
    Function GetSHAKE128: TSHAKE128;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    property SHAKE128Hasher: TSHAKE128Hash read GetSHAKE128Hasher;
    property SHAKE128: TSHAKE128 read GetSHAKE128;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHAKE128LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHAKE128LayerWriter - class declaration
===============================================================================}
type
  TSHAKE128LayerWriter = class(TKeccakLayerWriter)
  private
    Function GetSHAKE128Hasher: TSHAKE128Hash;
    Function GetSHAKE128: TSHAKE128;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    property SHAKE128Hasher: TSHAKE128Hash read GetSHAKE128Hasher;
    property SHAKE128: TSHAKE128 read GetSHAKE128;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHAKE256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHAKE256LayerReader - class declaration
===============================================================================}
type
  TSHAKE256LayerReader = class(TKeccakLayerReader)
  private
    Function GetSHAKE256Hasher: TSHAKE256Hash;
    Function GetSHAKE256: TSHAKE256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    property SHAKE256Hasher: TSHAKE256Hash read GetSHAKE256Hasher;
    property SHAKE256: TSHAKE256 read GetSHAKE256;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHAKE256LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHAKE256LayerWriter - class declaration
===============================================================================}
type
  TSHAKE256LayerWriter = class(TKeccakLayerWriter)
  private
    Function GetSHAKE256Hasher: TSHAKE256Hash;
    Function GetSHAKE256: TSHAKE256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    property SHAKE256Hasher: TSHAKE256Hash read GetSHAKE256Hasher;
    property SHAKE256: TSHAKE256 read GetSHAKE256;
  end;

implementation

uses
  AuxTypes,
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                               TKeccakLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccakLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccakLayerReader - private methods
-------------------------------------------------------------------------------}

Function TKeccakLayerReader.GetKeccakHasher: TKeccakDefHash;
begin
Result := TKeccakDefHash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccakLayerReader.GetKeccak: TKeccak;
begin
Result := TKeccakDefHash(fHasher).Keccak;
end;

{===============================================================================
--------------------------------------------------------------------------------
                               TKeccakLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccakLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccakLayerWriter - private methods
-------------------------------------------------------------------------------}

Function TKeccakLayerWriter.GetKeccakHasher: TKeccakDefHash;
begin
Result := TKeccakDefHash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccakLayerWriter.GetKeccak: TKeccak;
begin
Result := TKeccakDefHash(fHasher).Keccak;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak224LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak224LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccak224LayerReader - private methods
-------------------------------------------------------------------------------}

Function TKeccak224LayerReader.GetKeccak224Hasher: TKeccak224Hash;
begin
Result := TKeccak224Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccak224LayerReader.GetKeccak224: TKeccak224;
begin
Result := TKeccak224Hash(fHasher).Keccak224;
end;

{-------------------------------------------------------------------------------
    TKeccak224LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TKeccak224LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TKeccak224Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak224LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak224LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccak224LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TKeccak224LayerWriter.GetKeccak224Hasher: TKeccak224Hash;
begin
Result := TKeccak224Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccak224LayerWriter.GetKeccak224: TKeccak224;
begin
Result := TKeccak224Hash(fHasher).Keccak224;
end;

{-------------------------------------------------------------------------------
    TKeccak224LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TKeccak224LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TKeccak224Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak256LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccak256LayerReader - private methods
-------------------------------------------------------------------------------}

Function TKeccak256LayerReader.GetKeccak256Hasher: TKeccak256Hash;
begin
Result := TKeccak256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccak256LayerReader.GetKeccak256: TKeccak256;
begin
Result := TKeccak256Hash(fHasher).Keccak256;
end;

{-------------------------------------------------------------------------------
    TKeccak256LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TKeccak256LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TKeccak256Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak256LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak256LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccak256LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TKeccak256LayerWriter.GetKeccak256Hasher: TKeccak256Hash;
begin
Result := TKeccak256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccak256LayerWriter.GetKeccak256: TKeccak256;
begin
Result := TKeccak256Hash(fHasher).Keccak256;
end;

{-------------------------------------------------------------------------------
    TKeccak256LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TKeccak256LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TKeccak256Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak384LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak384LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccak384LayerReader - private methods
-------------------------------------------------------------------------------}

Function TKeccak384LayerReader.GetKeccak384Hasher: TKeccak384Hash;
begin
Result := TKeccak384Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccak384LayerReader.GetKeccak384: TKeccak384;
begin
Result := TKeccak384Hash(fHasher).Keccak384;
end;

{-------------------------------------------------------------------------------
    TKeccak384LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TKeccak384LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TKeccak384Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak384LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak384LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccak384LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TKeccak384LayerWriter.GetKeccak384Hasher: TKeccak384Hash;
begin
Result := TKeccak384Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccak384LayerWriter.GetKeccak384: TKeccak384;
begin
Result := TKeccak384Hash(fHasher).Keccak384;
end;

{-------------------------------------------------------------------------------
    TKeccak384LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TKeccak384LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TKeccak384Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak512LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak512LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccak512LayerReader - private methods
-------------------------------------------------------------------------------}

Function TKeccak512LayerReader.GetKeccak512Hasher: TKeccak512Hash;
begin
Result := TKeccak512Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccak512LayerReader.GetKeccak512: TKeccak512;
begin
Result := TKeccak512Hash(fHasher).Keccak512;
end;

{-------------------------------------------------------------------------------
    TKeccak512LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TKeccak512LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TKeccak512Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TKeccak512LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccak512LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccak512LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TKeccak512LayerWriter.GetKeccak512Hasher: TKeccak512Hash;
begin
Result := TKeccak512Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccak512LayerWriter.GetKeccak512: TKeccak512;
begin
Result := TKeccak512Hash(fHasher).Keccak512;
end;

{-------------------------------------------------------------------------------
    TKeccak512LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TKeccak512LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TKeccak512Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA3LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA3LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA3LayerReader.GetSHA3Hasher: TSHA3Hash;
begin
Result := TSHA3Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA3LayerReader.GetSHA3: TSHA3;
begin
Result := TSHA3Hash(fHasher).SHA3;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA3LayerWriter                                
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA3LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA3LayerWriter.GetSHA3Hasher: TSHA3Hash;
begin
Result := TSHA3Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA3LayerWriter.GetSHA3: TSHA3;
begin
Result := TSHA3Hash(fHasher).SHA3;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_224LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_224LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA3_224LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA3_224LayerReader.GetSHA3_224Hasher: TSHA3_224Hash;
begin
Result := TSHA3_224Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA3_224LayerReader.GetSHA3_224: TSHA3_224;
begin
Result := TSHA3_224Hash(fHasher).SHA3_224;
end;

{-------------------------------------------------------------------------------
    TSHA3_224LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA3_224LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA3_224Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_224LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_224LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA3_224LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA3_224LayerWriter.GetSHA3_224Hasher: TSHA3_224Hash;
begin
Result := TSHA3_224Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA3_224LayerWriter.GetSHA3_224: TSHA3_224;
begin
Result := TSHA3_224Hash(fHasher).SHA3_224;
end;

{-------------------------------------------------------------------------------
    TSHA3_224LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA3_224LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA3_224Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_256LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA3_256LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA3_256LayerReader.GetSHA3_256Hasher: TSHA3_256Hash;
begin
Result := TSHA3_256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA3_256LayerReader.GetSHA3_256: TSHA3_256;
begin
Result := TSHA3_256Hash(fHasher).SHA3_256;
end;

{-------------------------------------------------------------------------------
    TSHA3_256LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA3_256LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA3_256Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_256LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_256LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA3_256LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA3_256LayerWriter.GetSHA3_256Hasher: TSHA3_256Hash;
begin
Result := TSHA3_256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA3_256LayerWriter.GetSHA3_256: TSHA3_256;
begin
Result := TSHA3_256Hash(fHasher).SHA3_256;
end;

{-------------------------------------------------------------------------------
    TSHA3_256LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA3_256LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA3_256Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_384LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_384LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA3_384LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA3_384LayerReader.GetSHA3_384Hasher: TSHA3_384Hash;
begin
Result := TSHA3_384Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA3_384LayerReader.GetSHA3_384: TSHA3_384;
begin
Result := TSHA3_384Hash(fHasher).SHA3_384;
end;

{-------------------------------------------------------------------------------
    TSHA3_384LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA3_384LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA3_384Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_384LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_384LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA3_384LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA3_384LayerWriter.GetSHA3_384Hasher: TSHA3_384Hash;
begin
Result := TSHA3_384Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA3_384LayerWriter.GetSHA3_384: TSHA3_384;
begin
Result := TSHA3_384Hash(fHasher).SHA3_384;
end;

{-------------------------------------------------------------------------------
    TSHA3_384LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA3_384LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA3_384Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_512LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_512LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA3_512LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA3_512LayerReader.GetSHA3_512Hasher: TSHA3_512Hash;
begin
Result := TSHA3_512Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA3_512LayerReader.GetSHA3_512: TSHA3_512;
begin
Result := TSHA3_512Hash(fHasher).SHA3_512;
end;

{-------------------------------------------------------------------------------
    TSHA3_512LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA3_512LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA3_512Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA3_512LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA3_512LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA3_512LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA3_512LayerWriter.GetSHA3_512Hasher: TSHA3_512Hash;
begin
Result := TSHA3_512Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA3_512LayerWriter.GetSHA3_512: TSHA3_512;
begin
Result := TSHA3_512Hash(fHasher).SHA3_512;
end;

{-------------------------------------------------------------------------------
    TSHA3_512LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA3_512LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA3_512Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TKeccakCLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccakCLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccakCLayerReader - private methods
-------------------------------------------------------------------------------}

Function TKeccakCLayerReader.GetKeccakCHasher: TKeccakCHash;
begin
Result := TKeccakCHash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccakCLayerReader.GetKeccakC: TKeccakC;
begin
Result := TKeccakCHash(fHasher).KeccakC;
end;

{-------------------------------------------------------------------------------
    TKeccakCLayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TKeccakCLayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TKeccakCHash.Create;
If Assigned(Params) then
  begin
    If Params.Exists('TKeccakCLayerReader.HashBits',nvtInteger) then
      TKeccakCHash(fHasher).HashBits := UInt32(Params.IntegerValue['TKeccakCLayerReader.HashBits']);
    If Params.Exists('TKeccakCLayerReader.Capacity',nvtInteger) then
      TKeccakCHash(fHasher).Capacity := UInt32(Params.IntegerValue['TKeccakCLayerReader.Capacity']);
  end;
end;

{-------------------------------------------------------------------------------
    TKeccakCLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TKeccakCLayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TKeccakCLayerReader.HashBits',nvtInteger,[loprConstructor,loprInitializer]);
Result[1] := LayerObjectParam('TKeccakCLayerReader.Capacity',nvtInteger,[loprConstructor,loprInitializer]);
end;

//------------------------------------------------------------------------------

procedure TKeccakCLayerReader.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TKeccakCLayerReader.HashBits',nvtInteger) then
      TKeccakCHash(fHasher).HashBits := UInt32(Params.IntegerValue['TKeccakCLayerReader.HashBits']);
    If Params.Exists('TKeccakCLayerReader.Capacity',nvtInteger) then
      TKeccakCHash(fHasher).Capacity := UInt32(Params.IntegerValue['TKeccakCLayerReader.Capacity']);
  end;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TKeccakCLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TKeccakCLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TKeccakCLayerWriter - private methods
-------------------------------------------------------------------------------}

Function TKeccakCLayerWriter.GetKeccakCHasher: TKeccakCHash;
begin
Result := TKeccakCHash(fHasher);
end;

//------------------------------------------------------------------------------

Function TKeccakCLayerWriter.GetKeccakC: TKeccakC;
begin
Result := TKeccakCHash(fHasher).KeccakC;
end;

{-------------------------------------------------------------------------------
    TKeccakCLayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TKeccakCLayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TKeccakCHash.Create;
If Assigned(Params) then
  begin
    If Params.Exists('TKeccakCLayerWriter.HashBits',nvtInteger) then
      TKeccakCHash(fHasher).HashBits := UInt32(Params.IntegerValue['TKeccakCLayerWriter.HashBits']);
    If Params.Exists('TKeccakCLayerWriter.Capacity',nvtInteger) then
      TKeccakCHash(fHasher).Capacity := UInt32(Params.IntegerValue['TKeccakCLayerWriter.Capacity']);
  end;
end;

{-------------------------------------------------------------------------------
    TKeccakCLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TKeccakCLayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,2);
Result[0] := LayerObjectParam('TKeccakCLayerWriter.HashBits',nvtInteger,[loprConstructor,loprInitializer]);
Result[1] := LayerObjectParam('TKeccakCLayerWriter.Capacity',nvtInteger,[loprConstructor,loprInitializer]);
end;

//------------------------------------------------------------------------------

procedure TKeccakCLayerWriter.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  begin
    If Params.Exists('TKeccakCLayerWriter.HashBits',nvtInteger) then
      TKeccakCHash(fHasher).HashBits := UInt32(Params.IntegerValue['TKeccakCLayerWriter.HashBits']);
    If Params.Exists('TKeccakCLayerWriter.Capacity',nvtInteger) then
      TKeccakCHash(fHasher).Capacity := UInt32(Params.IntegerValue['TKeccakCLayerWriter.Capacity']);
  end;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHAKE128LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHAKE128LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHAKE128LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHAKE128LayerReader.GetSHAKE128Hasher: TSHAKE128Hash;
begin
Result := TSHAKE128Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHAKE128LayerReader.GetSHAKE128: TSHAKE128;
begin
Result := TSHAKE128Hash(fHasher).SHAKE128;
end;

{-------------------------------------------------------------------------------
    TSHAKE128LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHAKE128LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHAKE128Hash.Create;
If Assigned(Params) then
  If Params.Exists('TSHAKE128LayerReader.HashBits',nvtInteger) then
    TSHAKE128Hash(fHasher).HashBits := UInt32(Params.IntegerValue['TSHAKE128LayerReader.HashBits']);
end;

{-------------------------------------------------------------------------------
    TSHAKE128LayerReader - public methods
-------------------------------------------------------------------------------}

class Function TSHAKE128LayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TSHAKE128LayerReader.HashBits',nvtInteger,[loprConstructor,loprInitializer]);
end;

//------------------------------------------------------------------------------

procedure TSHAKE128LayerReader.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  If Params.Exists('TSHAKE128LayerReader.HashBits',nvtInteger) then
    TSHAKE128Hash(fHasher).HashBits := UInt32(Params.IntegerValue['TSHAKE128LayerReader.HashBits']);
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHAKE128LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHAKE128LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHAKE128LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHAKE128LayerWriter.GetSHAKE128Hasher: TSHAKE128Hash;
begin
Result := TSHAKE128Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHAKE128LayerWriter.GetSHAKE128: TSHAKE128;
begin
Result := TSHAKE128Hash(fHasher).SHAKE128;
end;

{-------------------------------------------------------------------------------
    TSHAKE128LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHAKE128LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHAKE128Hash.Create;
If Assigned(Params) then
  If Params.Exists('TSHAKE128LayerWriter.HashBits',nvtInteger) then
    TSHAKE128Hash(fHasher).HashBits := UInt32(Params.IntegerValue['TSHAKE128LayerWriter.HashBits']);
end;

{-------------------------------------------------------------------------------
    TSHAKE128LayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TSHAKE128LayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TSHAKE128LayerWriter.HashBits',nvtInteger,[loprConstructor,loprInitializer]);
end;

//------------------------------------------------------------------------------

procedure TSHAKE128LayerWriter.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  If Params.Exists('TSHAKE128LayerWriter.HashBits',nvtInteger) then
    TSHAKE128Hash(fHasher).HashBits := UInt32(Params.IntegerValue['TSHAKE128LayerWriter.HashBits']);
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHAKE256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHAKE256LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHAKE256LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHAKE256LayerReader.GetSHAKE256Hasher: TSHAKE256Hash;
begin
Result := TSHAKE256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHAKE256LayerReader.GetSHAKE256: TSHAKE256;
begin
Result := TSHAKE256Hash(fHasher).SHAKE256;
end;

{-------------------------------------------------------------------------------
    TSHAKE256LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHAKE256LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHAKE256Hash.Create;
If Assigned(Params) then
  If Params.Exists('TSHAKE256LayerReader.HashBits',nvtInteger) then
    TSHAKE256Hash(fHasher).HashBits := UInt32(Params.IntegerValue['TSHAKE256LayerReader.HashBits']);
end;

{-------------------------------------------------------------------------------
    TSHAKE256LayerReader - public methods
-------------------------------------------------------------------------------}

class Function TSHAKE256LayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TSHAKE256LayerReader.HashBits',nvtInteger,[loprConstructor,loprInitializer]);
end;

//------------------------------------------------------------------------------

procedure TSHAKE256LayerReader.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  If Params.Exists('TSHAKE256LayerReader.HashBits',nvtInteger) then
    TSHAKE256Hash(fHasher).HashBits := UInt32(Params.IntegerValue['TSHAKE256LayerReader.HashBits']);
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHAKE256LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHAKE256LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHAKE256LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHAKE256LayerWriter.GetSHAKE256Hasher: TSHAKE256Hash;
begin
Result := TSHAKE256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHAKE256LayerWriter.GetSHAKE256: TSHAKE256;
begin
Result := TSHAKE256Hash(fHasher).SHAKE256;
end;

{-------------------------------------------------------------------------------
    TSHAKE256LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHAKE256LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHAKE256Hash.Create;
If Assigned(Params) then
  If Params.Exists('TSHAKE256LayerWriter.HashBits',nvtInteger) then
    TSHAKE256Hash(fHasher).HashBits := UInt32(Params.IntegerValue['TSHAKE256LayerWriter.HashBits']);
end;

{-------------------------------------------------------------------------------
    TSHAKE256LayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TSHAKE256LayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,1);
Result[0] := LayerObjectParam('TSHAKE256LayerWriter.HashBits',nvtInteger,[loprConstructor,loprInitializer]);
end;

//------------------------------------------------------------------------------

procedure TSHAKE256LayerWriter.Init(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  If Params.Exists('TSHAKE256LayerWriter.HashBits',nvtInteger) then
    TSHAKE256Hash(fHasher).HashBits := UInt32(Params.IntegerValue['TSHAKE256LayerWriter.HashBits']);
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_Keccak224',TKeccak224LayerReader,TKeccak224LayerWriter);
  RegisterLayer('LSRL_Keccak256',TKeccak256LayerReader,TKeccak256LayerWriter);
  RegisterLayer('LSRL_Keccak384',TKeccak384LayerReader,TKeccak384LayerWriter);
  RegisterLayer('LSRL_Keccak512',TKeccak512LayerReader,TKeccak512LayerWriter);

  RegisterLayer('LSRL_SHA3_224',TSHA3_224LayerReader,TSHA3_224LayerWriter);
  RegisterLayer('LSRL_SHA3_256',TSHA3_256LayerReader,TSHA3_256LayerWriter);
  RegisterLayer('LSRL_SHA3_384',TSHA3_384LayerReader,TSHA3_384LayerWriter);
  RegisterLayer('LSRL_SHA3_512',TSHA3_512LayerReader,TSHA3_512LayerWriter);

  RegisterLayer('LSRL_KeccakC',TKeccakCLayerReader,TKeccakCLayerWriter);
  RegisterLayer('LSRL_SHAKE128',TSHAKE128LayerReader,TSHAKE128LayerWriter);
  RegisterLayer('LSRL_SHAKE256',TSHAKE256LayerReader,TSHAKE256LayerWriter);    

end.
