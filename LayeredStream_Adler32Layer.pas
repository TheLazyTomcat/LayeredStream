{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - Adler32 layer

    Calculates Adler2 checksum of read or written data.

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
unit LayeredStream_Adler32Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, Adler32,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                              TAdler32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TAdler32LayerReader - class declaration
===============================================================================}
type
  TAdler32LayerReader = class(TStreamHashLayerReader)
  private
    Function GetAdler32Hasher: TAdler32Hash;
    Function GetAdler32: TAdler32;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property Adler32Hasher: TAdler32Hash read GetAdler32Hasher;
    property Adler32: TAdler32 read GetAdler32;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TAdler32LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TAdler32LayerWriter - class declaration
===============================================================================}
type
  TAdler32LayerWriter = class(TStreamHashLayerWriter)
  private
    Function GetAdler32Hasher: TAdler32Hash;
    Function GetAdler32: TAdler32;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property Adler32Hasher: TAdler32Hash read GetAdler32Hasher;
    property Adler32: TAdler32 read GetAdler32;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                              TAdler32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TAdler32LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TAdler32LayerReader - private methods
-------------------------------------------------------------------------------}

Function TAdler32LayerReader.GetAdler32Hasher: TAdler32Hash;
begin
Result := TAdler32Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TAdler32LayerReader.GetAdler32: TAdler32;
begin
Result := TAdler32Hash(fHasher).Adler32;
end;

{-------------------------------------------------------------------------------
    TAdler32LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TAdler32LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TAdler32Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TAdler32LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TAdler32LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TAdler32LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TAdler32LayerWriter.GetAdler32Hasher: TAdler32Hash;
begin
Result := TAdler32Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TAdler32LayerWriter.GetAdler32: TAdler32;
begin
Result := TAdler32Hash(fHasher).Adler32;
end;

{-------------------------------------------------------------------------------
    TAdler32LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TAdler32LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
fHasher := TAdler32Hash.Create;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_Adler32',TAdler32LayerReader,TAdler32LayerWriter); 

end.
