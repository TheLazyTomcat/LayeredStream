unit LayeredStream_PassthroughLayer;

{$IFDEF FPC}
  {$MODE ObjFPC}
{$ENDIF}
{$H+}

interface

uses
  Classes,
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                             TPassthroughLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TPassthroughLayerReader - class declaration
===============================================================================}

type
  TPassthroughLayerReader = class(TLSLayerReader)
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TPassthroughLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TPassthroughLayerWriter - class declaration
===============================================================================}
type
  TPassthroughLayerWriter = class(TLSLayerWriter)
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
  end;

implementation

{===============================================================================
--------------------------------------------------------------------------------
                             TPassthroughLayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TPassthroughLayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TPassthroughLayerReader - protected methods
-------------------------------------------------------------------------------}

Function TPassthroughLayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TPassthroughLayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
Result := ReadOut(Buffer,Size);
end;

{-------------------------------------------------------------------------------
    TPassthroughLayerReader - public methods
-------------------------------------------------------------------------------}

class Function TPassthroughLayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopPassthrough];
end;


{===============================================================================
--------------------------------------------------------------------------------
                             TPassthroughLayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TPassthroughLayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TPassthroughLayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TPassthroughLayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TPassthroughLayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
Result := WriteOut(Buffer,Size);
end;

{-------------------------------------------------------------------------------
    TPassthroughLayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TPassthroughLayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopPassthrough];
end;

end.
