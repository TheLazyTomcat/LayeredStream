unit LayeredStream_PassthroughLayer;

interface

uses
  Classes,
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                               TPassthroughReader                                                             
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TPassthroughReader - class declaration
===============================================================================}

type
  TPassthroughReader = class(TLSLayerReader)
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
  public
    class Function LayerObjectKind: TLSLayerObjectKind; override;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TPassthroughWriter                                                             
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TPassthroughWriter - class declaration
===============================================================================}
type
  TPassthroughWriter = class(TLSLayerWriter)
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
  public
    class Function LayerObjectKind: TLSLayerObjectKind; override;
  end;

implementation

{===============================================================================
--------------------------------------------------------------------------------
                               TPassthroughReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TPassthroughReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TPassthroughReader - protected methods
-------------------------------------------------------------------------------}

Function TPassthroughReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TPassthroughReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
Result := ReadOut(Buffer,Size);
end;

{-------------------------------------------------------------------------------
    TPassthroughReader - public methods
-------------------------------------------------------------------------------}

class Function TPassthroughReader.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobPassthrough];
end;


{===============================================================================
--------------------------------------------------------------------------------
                               TPassthroughWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TPassthroughWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TPassthroughWriter - protected methods
-------------------------------------------------------------------------------}

Function TPassthroughWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TPassthroughWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
Result := WriteOut(Buffer,Size);
end;

{-------------------------------------------------------------------------------
    TPassthroughWriter - public methods
-------------------------------------------------------------------------------}

class Function TPassthroughWriter.LayerObjectKind: TLSLayerObjectKind;
begin
Result := [lobPassthrough];
end;

end.
