{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - SHA0 layer

    Calculates SHA0 hash of read or written data.

  Version 1.0 beta (2021-02-12)

  Last change 2021-02-12

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
    HashBase           - github.com/TheLazyTomcat/Lib.HashBase
    StrRect            - github.com/TheLazyTomcat/Lib.StrRect
    BitOps             - github.com/TheLazyTomcat/Lib.BitOps
    StaticMemoryStream - github.com/TheLazyTomcat/Lib.StaticMemoryStream
  * SimpleCPUID        - github.com/TheLazyTomcat/Lib.SimpleCPUID
    ZLibUtils          - github.com/TheLazyTomcat/Lib.ZLibUtils
    MemoryBuffer       - github.com/TheLazyTomcat/Lib.MemoryBuffer
    DynLibUtils        - github.com/TheLazyTomcat/Lib.DynLibUtils
    ZLib               - github.com/TheLazyTomcat/Bnd.ZLib

  SimpleCPUID might not be needed, see BitOps and CRC32 libraries for details.

===============================================================================}
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
