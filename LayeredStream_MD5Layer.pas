unit LayeredStream_MD5Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, MD5,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD5LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD5LayerReader - class declaration
===============================================================================}
type
  TMD5LayerReader = class(TBlockHashLayerReader)
  private
    Function GetMD5Hasher: TMD5Hash;
    Function GetMD5: TMD5;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD5Hasher: TMD5Hash read GetMD5Hasher;
    property MD5: TMD5 read GetMD5;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD5LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD5LayerWriter - class declaration
===============================================================================}
type
  TMD5LayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetMD5Hasher: TMD5Hash;
    Function GetMD5: TMD5;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD5Hasher: TMD5Hash read GetMD5Hasher;
    property MD5: TMD5 read GetMD5;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD5LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD5LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD5LayerReader - private methods
-------------------------------------------------------------------------------}

Function TMD5LayerReader.GetMD5Hasher: TMD5Hash;
begin
Result := TMD5Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD5LayerReader.GetMD5: TMD5;
begin
Result := TMD5Hash(fHasher).MD5;
end;

{-------------------------------------------------------------------------------
    TMD5LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TMD5LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TMD5Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD5LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD5LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD5LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TMD5LayerWriter.GetMD5Hasher: TMD5Hash;
begin
Result := TMD5Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD5LayerWriter.GetMD5: TMD5;
begin
Result := TMD5Hash(fHasher).MD5;
end;

{-------------------------------------------------------------------------------
    TMD5LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TMD5LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TMD5Hash.Create;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_MD5',TMD5LayerReader,TMD5LayerWriter);

end.

