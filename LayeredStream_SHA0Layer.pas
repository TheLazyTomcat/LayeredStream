unit LayeredStream_SHA0Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, SHA0,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA0LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA0LayerReader - class declaration
===============================================================================}
type
  TSHA0LayerReader = class(TBlockHashLayerReader)
  private
    Function GetSHA0Hasher: TSHA0Hash;
    Function GetSHA0: TSHA0;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA0Hasher: TSHA0Hash read GetSHA0Hasher;
    property SHA0: TSHA0 read GetSHA0;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA0LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA0LayerWriter - class declaration
===============================================================================}
type
  TSHA0LayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetSHA0Hasher: TSHA0Hash;
    Function GetSHA0: TSHA0;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA0Hasher: TSHA0Hash read GetSHA0Hasher;
    property SHA0: TSHA0 read GetSHA0;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA0LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA0LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA0LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA0LayerReader.GetSHA0Hasher: TSHA0Hash;
begin
Result := TSHA0Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA0LayerReader.GetSHA0: TSHA0;
begin
Result := TSHA0Hash(fHasher).SHA0;
end;

{-------------------------------------------------------------------------------
    TSHA0LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA0LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA0Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA0LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA0LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA0LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA0LayerWriter.GetSHA0Hasher: TSHA0Hash;
begin
Result := TSHA0Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA0LayerWriter.GetSHA0: TSHA0;
begin
Result := TSHA0Hash(fHasher).SHA0;
end;

{-------------------------------------------------------------------------------
    TSHA0LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA0LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA0Hash.Create;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_SHA0',TSHA0LayerReader,TSHA0LayerWriter);

end.
