{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - SHA1 layer

    Calculates SHA1 hash of read or written data.

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
fHasher := TSHA1Hash.Create;
inherited;
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
fHasher := TSHA1Hash.Create;
inherited;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_SHA1',TSHA1LayerReader,TSHA1LayerWriter);

end.
