unit LayeredStream_MD2Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, MD2,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD2LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD2LayerReader - class declaration
===============================================================================}
type
  TMD2LayerReader = class(TBlockHashLayerReader)
  private
    Function GetMD2Hasher: TMD2Hash;
    Function GetMD2: TMD2;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD2Hasher: TMD2Hash read GetMD2Hasher;
    property MD2: TMD2 read GetMD2;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD2LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD2LayerWriter - class declaration
===============================================================================}
type
  TMD2LayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetMD2Hasher: TMD2Hash;
    Function GetMD2: TMD2;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD2Hasher: TMD2Hash read GetMD2Hasher;
    property MD2: TMD2 read GetMD2;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD2LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD2LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD2LayerReader - private methods
-------------------------------------------------------------------------------}

Function TMD2LayerReader.GetMD2Hasher: TMD2Hash;
begin
Result := TMD2Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD2LayerReader.GetMD2: TMD2;
begin
Result := TMD2Hash(fHasher).MD2;
end;

{-------------------------------------------------------------------------------
    TMD2LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TMD2LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TMD2Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD2LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD2LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD2LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TMD2LayerWriter.GetMD2Hasher: TMD2Hash;
begin
Result := TMD2Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD2LayerWriter.GetMD2: TMD2;
begin
Result := TMD2Hash(fHasher).MD2;
end;

{-------------------------------------------------------------------------------
    TMD2LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TMD2LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TMD2Hash.Create;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_MD2',TMD2LayerReader,TMD2LayerWriter);

end.
