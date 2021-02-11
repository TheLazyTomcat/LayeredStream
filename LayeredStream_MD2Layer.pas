{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - MD2 layer

    Calculates MD2 hash of read or written data.

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
unit LayeredStream_MD2Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, MD2,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD2LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD2LayerReader - class declaration
===============================================================================}
type
  TMD2LayerReader = class(TBlockHashLayerReader)
  private
    Function GetMD2Hasher: TMD2Hash;
    Function GetMD2: TMD2;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD2Hasher: TMD2Hash read GetMD2Hasher;
    property MD2: TMD2 read GetMD2;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD2LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD2LayerWriter - class declaration
===============================================================================}
type
  TMD2LayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetMD2Hasher: TMD2Hash;
    Function GetMD2: TMD2;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property MD2Hasher: TMD2Hash read GetMD2Hasher;
    property MD2: TMD2 read GetMD2;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD2LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD2LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD2LayerReader - private methods
-------------------------------------------------------------------------------}

Function TMD2LayerReader.GetMD2Hasher: TMD2Hash;
begin
Result := TMD2Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD2LayerReader.GetMD2: TMD2;
begin
Result := TMD2Hash(fHasher).MD2;
end;

{-------------------------------------------------------------------------------
    TMD2LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TMD2LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TMD2Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TMD2LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMD2LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMD2LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TMD2LayerWriter.GetMD2Hasher: TMD2Hash;
begin
Result := TMD2Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TMD2LayerWriter.GetMD2: TMD2;
begin
Result := TMD2Hash(fHasher).MD2;
end;

{-------------------------------------------------------------------------------
    TMD2LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TMD2LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TMD2Hash.Create;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_MD2',TMD2LayerReader,TMD2LayerWriter);

end.
