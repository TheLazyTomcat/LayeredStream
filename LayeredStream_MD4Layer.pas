{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - MD4 layer

    Calculates MD4 hash of read or written data.

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
unit LayeredStream_MD4Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, MD4,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD4LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD4LayerReader - class declaration
===============================================================================}
type
  TMD4LayerReader = class(TBlockHashLayerReader)
  private
    Function GetMD4Hasher: TMD4Hash;
    Function GetMD4: TMD4;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD4Hasher: TMD4Hash read GetMD4Hasher;
    property MD4: TMD4 read GetMD4;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD4LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD4LayerWriter - class declaration
===============================================================================}
type
  TMD4LayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetMD4Hasher: TMD4Hash;
    Function GetMD4: TMD4;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD4Hasher: TMD4Hash read GetMD4Hasher;
    property MD4: TMD4 read GetMD4;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD4LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD4LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD4LayerReader - private methods
-------------------------------------------------------------------------------}

Function TMD4LayerReader.GetMD4Hasher: TMD4Hash;
begin
Result := TMD4Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD4LayerReader.GetMD4: TMD4;
begin
Result := TMD4Hash(fHasher).MD4;
end;

{-------------------------------------------------------------------------------
    TMD4LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TMD4LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TMD4Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD4LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD4LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD4LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TMD4LayerWriter.GetMD4Hasher: TMD4Hash;
begin
Result := TMD4Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD4LayerWriter.GetMD4: TMD4;
begin
Result := TMD4Hash(fHasher).MD4;
end;

{-------------------------------------------------------------------------------
    TMD4LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TMD4LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TMD4Hash.Create;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_MD4',TMD4LayerReader,TMD4LayerWriter);

end.
