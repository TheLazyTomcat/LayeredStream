{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - Passthrough Layer

    Data are passign through this layer without being touched.

    Intended as a placeholder or to fill a layer pair where one object does
    something but the other is either not used at all or should just pass data.

  Version 1.0 (2020-11-03)

  Last change 2020-11-03

  ©2020 František Milt

  Contacts:
    František Milt: frantisek.milt@gmail.com

  Support:
    If you find this code useful, please consider supporting its author(s) by
    making a small donation using the following link(s):

      https://www.paypal.me/FMilt

  Changelog:
    For detailed changelog and history please refer to this git repository:

      github.com/TheLazyTomcat/Lib.LayeredStream

  Dependencies:
    AuxTypes          - github.com/TheLazyTomcat/Lib.AuxTypes
    AuxClasses        - github.com/TheLazyTomcat/Lib.AuxClasses
    SimpleNamedValues - github.com/TheLazyTomcat/Lib.SimpleNamedValues
    LayeredStream     - github.com/TheLazyTomcat/Lib.LayeredStream

===============================================================================}
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
