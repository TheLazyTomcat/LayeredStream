{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - MD5 layer

    Calculates MD5 hash of read or written data.

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
unit LayeredStream_MD5Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, MD5,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD5LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD5LayerReader - class declaration
===============================================================================}
type
  TMD5LayerReader = class(TBlockHashLayerReader)
  private
    Function GetMD5Hasher: TMD5Hash;
    Function GetMD5: TMD5;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD5Hasher: TMD5Hash read GetMD5Hasher;
    property MD5: TMD5 read GetMD5;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD5LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD5LayerWriter - class declaration
===============================================================================}
type
  TMD5LayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetMD5Hasher: TMD5Hash;
    Function GetMD5: TMD5;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD5Hasher: TMD5Hash read GetMD5Hasher;
    property MD5: TMD5 read GetMD5;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD5LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD5LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD5LayerReader - private methods
-------------------------------------------------------------------------------}

Function TMD5LayerReader.GetMD5Hasher: TMD5Hash;
begin
Result := TMD5Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD5LayerReader.GetMD5: TMD5;
begin
Result := TMD5Hash(fHasher).MD5;
end;

{-------------------------------------------------------------------------------
    TMD5LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TMD5LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TMD5Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD5LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD5LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD5LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TMD5LayerWriter.GetMD5Hasher: TMD5Hash;
begin
Result := TMD5Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD5LayerWriter.GetMD5: TMD5;
begin
Result := TMD5Hash(fHasher).MD5;
end;

{-------------------------------------------------------------------------------
    TMD5LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TMD5LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TMD5Hash.Create;
inherited;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_MD5',TMD5LayerReader,TMD5LayerWriter);

end.

