{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - SHA2 layer

    Calculates SHA2 hash of read or written data.

    All SHA2 variants are implemented, that is the following (each variant is
    implemented in a separate class):

        SHA-224
        SHA-256
        SHA-384
        SHA-512
        SHA-512/224
        SHA-512/256    

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
unit LayeredStream_SHA2Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, SHA2,
  LayeredStream_HashLayer;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA2LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA2LayerReader - class declaration
===============================================================================}
type
  TSHA2LayerReader = class(TBlockHashLayerReader)
  private
    Function GetSHA2Hasher: TSHA2Hash;
    Function GetSHA2: TSHA2;
  public
    property SHA2Hasher: TSHA2Hash read GetSHA2Hasher;
    property SHA2: TSHA2 read GetSHA2;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA2LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA2LayerWriter - class declaration
===============================================================================}
type
  TSHA2LayerWriter = class(TBlockHashLayerWriter)
  private
    Function GetSHA2Hasher: TSHA2Hash;
    Function GetSHA2: TSHA2;
  public
    property SHA2Hasher: TSHA2Hash read GetSHA2Hasher;
    property SHA2: TSHA2 read GetSHA2;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA224LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA224LayerReader - class declaration
===============================================================================}
type
  TSHA224LayerReader = class(TSHA2LayerReader)
  private
    Function GetSHA224Hasher: TSHA224Hash;
    Function GetSHA224: TSHA224;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA224Hasher: TSHA224Hash read GetSHA224Hasher;
    property SHA224: TSHA224 read GetSHA224;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA224LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA224LayerWriter - class declaration
===============================================================================}
type
  TSHA224LayerWriter = class(TSHA2LayerWriter)
  private
    Function GetSHA224Hasher: TSHA224Hash;
    Function GetSHA224: TSHA224;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property SHA224Hasher: TSHA224Hash read GetSHA224Hasher;
    property SHA224: TSHA224 read GetSHA224;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA256LayerReader - class declaration
===============================================================================}
type
  TSHA256LayerReader = class(TSHA2LayerReader)
  private
    Function GetSHA256Hasher: TSHA256Hash;
    Function GetSHA256: TSHA256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA256Hasher: TSHA256Hash read GetSHA256Hasher;
    property SHA256: TSHA256 read GetSHA256;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA256LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA256LayerWriter - class declaration
===============================================================================}
type
  TSHA256LayerWriter = class(TSHA2LayerWriter)
  private
    Function GetSHA256Hasher: TSHA256Hash;
    Function GetSHA256: TSHA256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property SHA256Hasher: TSHA256Hash read GetSHA256Hasher;
    property SHA256: TSHA256 read GetSHA256;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA384LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA384LayerReader - class declaration
===============================================================================}
type
  TSHA384LayerReader = class(TSHA2LayerReader)
  private
    Function GetSHA384Hasher: TSHA384Hash;
    Function GetSHA384: TSHA384;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA384Hasher: TSHA384Hash read GetSHA384Hasher;
    property SHA384: TSHA384 read GetSHA384;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA384LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA384LayerWriter - class declaration
===============================================================================}
type
  TSHA384LayerWriter = class(TSHA2LayerWriter)
  private
    Function GetSHA384Hasher: TSHA384Hash;
    Function GetSHA384: TSHA384;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property SHA384Hasher: TSHA384Hash read GetSHA384Hasher;
    property SHA384: TSHA384 read GetSHA384;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA512LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512LayerReader - class declaration
===============================================================================}
type
  TSHA512LayerReader = class(TSHA2LayerReader)
  private
    Function GetSHA512Hasher: TSHA512Hash;
    Function GetSHA512: TSHA512;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA512Hasher: TSHA512Hash read GetSHA512Hasher;
    property SHA512: TSHA512 read GetSHA512;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA512LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512LayerWriter - class declaration
===============================================================================}
type
  TSHA512LayerWriter = class(TSHA2LayerWriter)
  private
    Function GetSHA512Hasher: TSHA512Hash;
    Function GetSHA512: TSHA512;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property SHA512Hasher: TSHA512Hash read GetSHA512Hasher;
    property SHA512: TSHA512 read GetSHA512;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TSHA512_224LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512_224LayerReader - class declaration
===============================================================================}
type
  TSHA512_224LayerReader = class(TSHA2LayerReader)
  private
    Function GetSHA512_224Hasher: TSHA512_224Hash;
    Function GetSHA512_224: TSHA512_224;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA512_224Hasher: TSHA512_224Hash read GetSHA512_224Hasher;
    property SHA512_224: TSHA512_224 read GetSHA512_224;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TSHA512_224LayerWriter                             
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512_224LayerWriter - class declaration
===============================================================================}
type
  TSHA512_224LayerWriter = class(TSHA2LayerWriter)
  private
    Function GetSHA512_224Hasher: TSHA512_224Hash;
    Function GetSHA512_224: TSHA512_224;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property SHA512_224Hasher: TSHA512_224Hash read GetSHA512_224Hasher;
    property SHA512_224: TSHA512_224 read GetSHA512_224;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TSHA512_256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512_256LayerReader - class declaration
===============================================================================}
type
  TSHA512_256LayerReader = class(TSHA2LayerReader)
  private
    Function GetSHA512_256Hasher: TSHA512_256Hash;
    Function GetSHA512_256: TSHA512_256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    property SHA512_256Hasher: TSHA512_256Hash read GetSHA512_256Hasher;
    property SHA512_256: TSHA512_256 read GetSHA512_256;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TSHA512_256LayerWriter                             
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512_256LayerWriter - class declaration
===============================================================================}
type
  TSHA512_256LayerWriter = class(TSHA2LayerWriter)
  private
    Function GetSHA512_256Hasher: TSHA512_256Hash;
    Function GetSHA512_256: TSHA512_256;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;    
  public
    property SHA512_256Hasher: TSHA512_256Hash read GetSHA512_256Hasher;
    property SHA512_256: TSHA512_256 read GetSHA512_256;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA2LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA2LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA2LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA2LayerReader.GetSHA2Hasher: TSHA2Hash;
begin
Result := TSHA2Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA2LayerReader.GetSHA2: TSHA2;
begin
Result := TSHA2Hash(fHasher).SHA2;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA2LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA2LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA2LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA2LayerWriter.GetSHA2Hasher: TSHA2Hash;
begin
Result := TSHA2Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA2LayerWriter.GetSHA2: TSHA2;
begin
Result := TSHA2Hash(fHasher).SHA2;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA224LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA224LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA224LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA224LayerReader.GetSHA224Hasher: TSHA224Hash;
begin
Result := TSHA224Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA224LayerReader.GetSHA224: TSHA224;
begin
Result := TSHA224Hash(fHasher).SHA224;
end;

{-------------------------------------------------------------------------------
    TSHA224LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA224LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA224Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA224LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA224LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA224LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA224LayerWriter.GetSHA224Hasher: TSHA224Hash;
begin
Result := TSHA224Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA224LayerWriter.GetSHA224: TSHA224;
begin
Result := TSHA224Hash(fHasher).SHA224;
end;

{-------------------------------------------------------------------------------
    TSHA224LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA224LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA224Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA256LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA256LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA256LayerReader.GetSHA256Hasher: TSHA256Hash;
begin
Result := TSHA256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA256LayerReader.GetSHA256: TSHA256;
begin
Result := TSHA256Hash(fHasher).SHA256;
end;

{-------------------------------------------------------------------------------
    TSHA256LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA256LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA256Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA256LayerWriter                               
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA256LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA256LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA256LayerWriter.GetSHA256Hasher: TSHA256Hash;
begin
Result := TSHA256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA256LayerWriter.GetSHA256: TSHA256;
begin
Result := TSHA256Hash(fHasher).SHA256;
end;

{-------------------------------------------------------------------------------
    TSHA256LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA256LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA256Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA384LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA384LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA384LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA384LayerReader.GetSHA384Hasher: TSHA384Hash;
begin
Result := TSHA384Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA384LayerReader.GetSHA384: TSHA384;
begin
Result := TSHA384Hash(fHasher).SHA384;
end;

{-------------------------------------------------------------------------------
    TSHA384LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA384LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA384Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA384LayerWriter                               
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA384LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA384LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA384LayerWriter.GetSHA384Hasher: TSHA384Hash;
begin
Result := TSHA384Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA384LayerWriter.GetSHA384: TSHA384;
begin
Result := TSHA384Hash(fHasher).SHA384;
end;

{-------------------------------------------------------------------------------
    TSHA384LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA384LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA384Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                TSHA512LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA512LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA512LayerReader.GetSHA512Hasher: TSHA512Hash;
begin
Result := TSHA512Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA512LayerReader.GetSHA512: TSHA512;
begin
Result := TSHA512Hash(fHasher).SHA512;
end;

{-------------------------------------------------------------------------------
    TSHA512LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA512LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA512Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                               TSHA512LayerWriter                               
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA512LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA512LayerWriter.GetSHA512Hasher: TSHA512Hash;
begin
Result := TSHA512Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA512LayerWriter.GetSHA512: TSHA512;
begin
Result := TSHA512Hash(fHasher).SHA512;
end;

{-------------------------------------------------------------------------------
    TSHA512LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA512LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA512Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA512_224LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512_224LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA512_224LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA512_224LayerReader.GetSHA512_224Hasher: TSHA512_224Hash;
begin
Result := TSHA512_224Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA512_224LayerReader.GetSHA512_224: TSHA512_224;
begin
Result := TSHA512_224Hash(fHasher).SHA512_224;
end;

{-------------------------------------------------------------------------------
    TSHA512_224LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA512_224LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA512_224Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TSHA512_224LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512_224LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA512_224LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA512_224LayerWriter.GetSHA512_224Hasher: TSHA512_224Hash;
begin
Result := TSHA512_224Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA512_224LayerWriter.GetSHA512_224: TSHA512_224;
begin
Result := TSHA512_224Hash(fHasher).SHA512_224;
end;

{-------------------------------------------------------------------------------
    TSHA512_224LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA512_224LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA512_224Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TSHA512_256LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512_256LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA512_256LayerReader - private methods
-------------------------------------------------------------------------------}

Function TSHA512_256LayerReader.GetSHA512_256Hasher: TSHA512_256Hash;
begin
Result := TSHA512_256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA512_256LayerReader.GetSHA512_256: TSHA512_256;
begin
Result := TSHA512_256Hash(fHasher).SHA512_256;
end;

{-------------------------------------------------------------------------------
    TSHA512_256LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TSHA512_256LayerReader.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA512_256Hash.Create;
inherited;
end;

{===============================================================================
--------------------------------------------------------------------------------
                             TSHA512_256LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSHA512_256LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSHA512_256LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TSHA512_256LayerWriter.GetSHA512_256Hasher: TSHA512_256Hash;
begin
Result := TSHA512_256Hash(fHasher);
end;

//------------------------------------------------------------------------------

Function TSHA512_256LayerWriter.GetSHA512_256: TSHA512_256;
begin
Result := TSHA512_256Hash(fHasher).SHA512_256;
end;

{-------------------------------------------------------------------------------
    TSHA512_256LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TSHA512_256LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
fHasher := TSHA512_256Hash.Create;
inherited;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_SHA224',TSHA224LayerReader,TSHA224LayerWriter);
  RegisterLayer('LSRL_SHA256',TSHA256LayerReader,TSHA256LayerWriter);
  RegisterLayer('LSRL_SHA384',TSHA384LayerReader,TSHA384LayerWriter);
  RegisterLayer('LSRL_SHA512',TSHA512LayerReader,TSHA512LayerWriter);
  RegisterLayer('LSRL_SHA512_224',TSHA512_224LayerReader,TSHA512_224LayerWriter);
  RegisterLayer('LSRL_SHA512_256',TSHA512_256LayerReader,TSHA512_256LayerWriter);

end.
