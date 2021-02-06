unit LayeredStream_MD4Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, MD4,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD4LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD4LayerReader - class declaration
===============================================================================}
type
  TMD4LayerReader = class(TBlockHashLayerReader)
  private
    Function GetMD4Hasher: TMD4Hash;
    Function GetMD4: TMD4;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD4Hasher: TMD4Hash read GetMD4Hasher;
    property MD4: TMD4 read GetMD4;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD4LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD4LayerWriter - class declaration
===============================================================================}
type
  TMD4LayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetMD4Hasher: TMD4Hash;
    Function GetMD4: TMD4;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD4Hasher: TMD4Hash read GetMD4Hasher;
    property MD4: TMD4 read GetMD4;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD4LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD4LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD4LayerReader - private methods
-------------------------------------------------------------------------------}

Function TMD4LayerReader.GetMD4Hasher: TMD4Hash;
begin
Result := TMD4Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD4LayerReader.GetMD4: TMD4;
begin
Result := TMD4Hash(fHasher).MD4;
end;

{-------------------------------------------------------------------------------
    TMD4LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TMD4LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TMD4Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD4LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD4LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD4LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TMD4LayerWriter.GetMD4Hasher: TMD4Hash;
begin
Result := TMD4Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD4LayerWriter.GetMD4: TMD4;
begin
Result := TMD4Hash(fHasher).MD4;
end;

{-------------------------------------------------------------------------------
    TMD4LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TMD4LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TMD4Hash.Create;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_MD4',TMD4LayerReader,TMD4LayerWriter);

end.
