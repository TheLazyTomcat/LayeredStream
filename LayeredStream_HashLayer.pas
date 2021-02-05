unit LayeredStream_HashLayer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, HashBase,
  LayeredStream_Layers;

{===============================================================================
--------------------------------------------------------------------------------
                                THashLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    THashLayerReader - class declaration
===============================================================================}
type
  THashLayerReader = class(TLSLayerReader)
  protected
    fHasher:  THashBase;
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Final; override;
    property Hasher: THashBase read fHasher;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                THashLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    THashLayerWriter - class declaration
===============================================================================}
type
  THashLayerWriter = class(TLSLayerWriter)
  protected
    fHasher:  THashBase;
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Final; override;
    property Hasher: THashBase read fHasher;
  end;

implementation

{===============================================================================
--------------------------------------------------------------------------------
                                THashLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    THashLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    THashLayerReader - protected methods
-------------------------------------------------------------------------------}

Function THashLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function THashLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
Result := ReadOut(Buffer,Size);
fHasher.Update(Buffer,Result);
end;

//------------------------------------------------------------------------------

procedure THashLayerReader.Finalize;
begin
fHasher.Free;
inherited;
end;

{-------------------------------------------------------------------------------
    THashLayerReader - public methods
-------------------------------------------------------------------------------}

class Function THashLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopNeedsInit,lopNeedsFinal,lopPassthrough,lopObserver];
end;

//------------------------------------------------------------------------------

procedure THashLayerReader.Init(Params: TSimpleNamedValues);
begin
inherited;
fHasher.Init;
end;

//------------------------------------------------------------------------------

procedure THashLayerReader.Final;
begin
fHasher.Final;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                THashLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    THashLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    THashLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function THashLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function THashLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
Result := WriteOut(Buffer,Size);
fHasher.Update(Buffer,Result);
end;

//------------------------------------------------------------------------------

procedure THashLayerWriter.Finalize;
begin
fHasher.Free;
inherited;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerWriter - public methods
-------------------------------------------------------------------------------}

class Function THashLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopNeedsInit,lopNeedsFinal,lopPassthrough,lopObserver];
end;

//------------------------------------------------------------------------------

procedure THashLayerWriter.Init(Params: TSimpleNamedValues);
begin
inherited;
fHasher.Init;
end;

//------------------------------------------------------------------------------

procedure THashLayerWriter.Final;
begin
fHasher.Final;
inherited;
end;

end.
