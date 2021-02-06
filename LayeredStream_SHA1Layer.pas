unit LayeredStream_SHA1Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, SHA1,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA1LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA1LayerReader - class declaration
===============================================================================}
type
  TSHA1LayerReader = class(TBlockHashLayerReader)
  private
    Function GetSHA1Hasher: TSHA1Hash;
    Function GetSHA1: TSHA1;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA1Hasher: TSHA1Hash read GetSHA1Hasher;
    property SHA1: TSHA1 read GetSHA1;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA1LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA1LayerWriter - class declaration
===============================================================================}
type
  TSHA1LayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetSHA1Hasher: TSHA1Hash;
    Function GetSHA1: TSHA1;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA1Hasher: TSHA1Hash read GetSHA1Hasher;
    property SHA1: TSHA1 read GetSHA1;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA1LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA1LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA1LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA1LayerReader.GetSHA1Hasher: TSHA1Hash;
begin
Result := TSHA1Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA1LayerReader.GetSHA1: TSHA1;
begin
Result := TSHA1Hash(fHasher).SHA1;
end;

{-------------------------------------------------------------------------------
    TSHA1LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA1LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA1Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA1LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA1LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA1LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA1LayerWriter.GetSHA1Hasher: TSHA1Hash;
begin
Result := TSHA1Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA1LayerWriter.GetSHA1: TSHA1;
begin
Result := TSHA1Hash(fHasher).SHA1;
end;

{-------------------------------------------------------------------------------
    TSHA1LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA1LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TSHA1Hash.Create;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_SHA1',TSHA1LayerReader,TSHA1LayerWriter);

end.
