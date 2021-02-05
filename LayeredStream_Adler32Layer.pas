unit LayeredStream_Adler32Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, Adler32,
  LayeredStream_Layers,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                              TAdler32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TAdler32LayerReader - class declaration
===============================================================================}
type
  TAdler32LayerReader = class(THashLayerReader)
  private
    Function GetAdler32Hasher: TAdler32Hash;
    Function GetAdler32: TAdler32;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property Adler32Hasher: TAdler32Hash read GetAdler32Hasher;
    property Adler32: TAdler32 read GetAdler32;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TAdler32LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TAdler32LayerWriter - class declaration
===============================================================================}
type
  TAdler32LayerWriter = class(THashLayerWriter)
  private
    Function GetAdler32Hasher: TAdler32Hash;
    Function GetAdler32: TAdler32;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property Adler32Hasher: TAdler32Hash read GetAdler32Hasher;
    property Adler32: TAdler32 read GetAdler32;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                              TAdler32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TAdler32LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TAdler32LayerReader - private methods
-------------------------------------------------------------------------------}

Function TAdler32LayerReader.GetAdler32Hasher: TAdler32Hash;
begin
Result := TAdler32Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TAdler32LayerReader.GetAdler32: TAdler32;
begin
Result := TAdler32Hash(fHasher).Adler32;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TAdler32LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TAdler32Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TAdler32LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TAdler32LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TAdler32LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TAdler32LayerWriter.GetAdler32Hasher: TAdler32Hash;
begin
Result := TAdler32Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TAdler32LayerWriter.GetAdler32: TAdler32;
begin
Result := TAdler32Hash(fHasher).Adler32;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TAdler32LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TAdler32Hash.Create;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_Adler32',TAdler32LayerReader,TAdler32LayerWriter); 

end.
