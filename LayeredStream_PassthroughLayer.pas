{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - Passthrough layer

    Data are passign through this layer without being touched.

    Intended as a placeholder or to fill a layer pair where one object does
    something but the other is either not used at all or should just pass data.

  Version 1.0 beta 2 (2021-03-14)

  Last change 2021-03-14

  ©2020-2021 František Milt

  Contacts:
    František Milt: frantisek.milt@gmail.com

  Support:
    If you find this code useful, please consider supporting its author(s) by
    making a small donation using the following link(s):

      https://www.paypal.me/FMilt

  Changelog:
    For detailed changelog and history please refer to this git repository:

      github.com/TheLazyTomcat/LayeredStream

  Dependencies:
    AuxTypes          - github.com/TheLazyTomcat/Lib.AuxTypes
    AuxClasses        - github.com/TheLazyTomcat/Lib.AuxClasses
    SimpleNamedValues - github.com/TheLazyTomcat/Lib.SimpleNamedValues

  Dependencies required by implemented layers:
    Adler32            - github.com/TheLazyTomcat/Lib.Adler32
    CRC32              - github.com/TheLazyTomcat/Lib.CRC32
    MD2                - github.com/TheLazyTomcat/Lib.MD2
    MD4                - github.com/TheLazyTomcat/Lib.MD4
    MD5                - github.com/TheLazyTomcat/Lib.MD5
    SHA0               - github.com/TheLazyTomcat/Lib.SHA0
    SHA1               - github.com/TheLazyTomcat/Lib.SHA1
    SHA2               - github.com/TheLazyTomcat/Lib.SHA2
    SHA3               - github.com/TheLazyTomcat/Lib.SHA3
    CityHash           - github.com/TheLazyTomcat/Lib.CityHash
    HashBase           - github.com/TheLazyTomcat/Lib.HashBase
    StrRect            - github.com/TheLazyTomcat/Lib.StrRect
    StaticMemoryStream - github.com/TheLazyTomcat/Lib.StaticMemoryStream
  * SimpleCPUID        - github.com/TheLazyTomcat/Lib.SimpleCPUID
    BitOps             - github.com/TheLazyTomcat/Lib.BitOps
    UInt64Utils        - github.com/TheLazyTomcat/Lib.UInt64Utils
    MemoryBuffer       - github.com/TheLazyTomcat/Lib.MemoryBuffer
    ZLibUtils          - github.com/TheLazyTomcat/Lib.ZLibUtils
    DynLibUtils        - github.com/TheLazyTomcat/Lib.DynLibUtils
    ZLib               - github.com/TheLazyTomcat/Bnd.ZLib

  SimpleCPUID might not be needed, see BitOps and CRC32 libraries for details.

===============================================================================}
unit LayeredStream_PassthroughLayer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  LayeredStream_Layers;

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

uses
  LayeredStream;

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

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_Passthrough',TPassthroughLayerReader,TPassthroughLayerWriter);

end.
