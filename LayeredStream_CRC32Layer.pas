{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - CRC32 layer

    Calculates CRC32 checksum of read or written data.

    Several CRC32 variants are provided and can be selected to produce a
    desired checksum. It is also possible to configure custom CRC32 algorithm.

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
unit LayeredStream_CRC32Layer;

{$INCLUDE './LayeredStream_defs.inc'}

interface

uses
  Classes,
  SimpleNamedValues, CRC32,
  LayeredStream_Layers,
  LayeredStream_HashLayer;

{===============================================================================
    Values for parameters passing
===============================================================================}
const
  CRC32_CLASS_PKZIP      = 0;
  CRC32_CLASS_CASTAGNOLI = 1;
  CRC32_CLASS_CUSTOM     = 2;

{===============================================================================
--------------------------------------------------------------------------------
                               TCRC32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCRC32LayerReader - class declaration
===============================================================================}
type
  TCRC32LayerReader = class(TStreamHashLayerReader)
  private
    Function GetCRC32Hasher: TCRC32BaseHash;
    Function GetCRC32: TCRC32;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property CRC32Hasher: TCRC32BaseHash read GetCRC32Hasher;
    property CRC32: TCRC32 read GetCRC32;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                               TCRC32LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCRC32LayerWriter - class declaration
===============================================================================}
type
  TCRC32LayerWriter = class(TStreamHashLayerWriter)
  private
    Function GetCRC32Hasher: TCRC32BaseHash;
    Function GetCRC32: TCRC32;
  protected
    procedure Initialize(Params: TSimpleNamedValues); override;
  public
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    property CRC32Hasher: TCRC32BaseHash read GetCRC32Hasher;
    property CRC32: TCRC32 read GetCRC32;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
    Auxiliary routines
===============================================================================}

Function CreateHasherCommon(const Prefix: String; Params: TSimpleNamedValues): TCRC32BaseHash;
var
  IntTemp:  Integer;
  StrTemp:  String;
  BoolTemp: Boolean;
begin
IntTemp := 0;
StrTemp := '';
BoolTemp := False;
If GetNamedValue(Params,Prefix + '.Class',IntTemp) then
  case IntTemp of
    CRC32_CLASS_PKZIP:
      Result := TCRC32Hash.Create;
    CRC32_CLASS_CASTAGNOLI:
      Result := TCRC32CHash.Create;
    CRC32_CLASS_CUSTOM:
      begin
        Result := TCRC32CustomHash.Create;
        If GetNamedValue(Params,Prefix + '.PresetIndex',IntTemp) then
          TCRC32CustomHash(Result).LoadPreset(IntTemp)
        else If GetNamedValue(Params,Prefix + '.PresetName',StrTemp) then
          TCRC32CustomHash(Result).LoadPreset(StrTemp)
        else
          begin
            If GetNamedValue(Params,Prefix + '.Polynomial',IntTemp) then
              TCRC32CustomHash(Result).CRC32Poly := TCRC32Sys(IntTemp)
            else If GetNamedValue(Params,Prefix + '.PolynomialRef',IntTemp) then
              TCRC32CustomHash(Result).CRC32PolyRef := TCRC32Sys(IntTemp);
            If GetNamedValue(Params,Prefix + '.InitialValue',IntTemp) then
              TCRC32CustomHash(Result).InitialValue := TCRC32(IntTemp);
            If GetNamedValue(Params,Prefix + '.ReflectIn',BoolTemp) then
              TCRC32CustomHash(Result).ReflectIn := BoolTemp;
            If GetNamedValue(Params,Prefix + '.ReflectOut',BoolTemp) then
              TCRC32CustomHash(Result).ReflectOut := BoolTemp;
            If GetNamedValue(Params,Prefix + '.XOROutValue',IntTemp) then
              TCRC32CustomHash(Result).XOROutValue := TCRC32(IntTemp);
          end;
      end;
  else
    Result := TCRC32Hash.Create;
  end
else Result := TCRC32Hash.Create;
end;

{===============================================================================
--------------------------------------------------------------------------------
                               TCRC32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCRC32LayerReader - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCRC32LayerReader - private methods
-------------------------------------------------------------------------------}

Function TCRC32LayerReader.GetCRC32Hasher: TCRC32BaseHash;
begin
Result := TCRC32BaseHash(fHasher);
end;

//------------------------------------------------------------------------------

Function TCRC32LayerReader.GetCRC32: TCRC32;
begin
Result := TCRC32BaseHash(fHasher).CRC32;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerReader - protected methods
-------------------------------------------------------------------------------}

procedure TCRC32LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  fHasher := CreateHasherCommon('TCRC32LayerReader',Params)
else
  fHasher := TCRC32Hash.Create;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerReader - public methods
-------------------------------------------------------------------------------}

class Function TCRC32LayerReader.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,9);
Result[0] := LayerObjectParam('TCRC32LayerReader.Class',nvtInteger,[loprConstructor]);
Result[1] := LayerObjectParam('TCRC32LayerReader.PresetIndex',nvtInteger,[loprConstructor]);
Result[2] := LayerObjectParam('TCRC32LayerReader.PresetName',nvtInteger,[loprConstructor]);
Result[3] := LayerObjectParam('TCRC32LayerReader.Polynomial',nvtInteger,[loprConstructor]);
Result[4] := LayerObjectParam('TCRC32LayerReader.PolynomialRef',nvtInteger,[loprConstructor]);
Result[5] := LayerObjectParam('TCRC32LayerReader.InitialValue',nvtInteger,[loprConstructor]);
Result[6] := LayerObjectParam('TCRC32LayerReader.ReflectIn',nvtBool,[loprConstructor]);
Result[7] := LayerObjectParam('TCRC32LayerReader.ReflectOut',nvtBool,[loprConstructor]);
Result[8] := LayerObjectParam('TCRC32LayerReader.XOROutValue',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
--------------------------------------------------------------------------------
                               TCRC32LayerWriter
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCRC32LayerWriter - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TCRC32LayerWriter - private methods
-------------------------------------------------------------------------------}

Function TCRC32LayerWriter.GetCRC32Hasher: TCRC32BaseHash;
begin
Result := TCRC32BaseHash(fHasher);
end;

//------------------------------------------------------------------------------

Function TCRC32LayerWriter.GetCRC32: TCRC32;
begin
Result := TCRC32BaseHash(fHasher).CRC32;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerWriter - protected methods
-------------------------------------------------------------------------------}

procedure TCRC32LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  fHasher := CreateHasherCommon('TCRC32LayerWriter',Params)
else
  fHasher := TCRC32Hash.Create;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TCRC32LayerWriter.LayerObjectParams: TLSLayerObjectParams;
begin
SetLength(Result,9);
Result[0] := LayerObjectParam('TCRC32LayerWriter.Class',nvtInteger,[loprConstructor]);
Result[1] := LayerObjectParam('TCRC32LayerWriter.PresetIndex',nvtInteger,[loprConstructor]);
Result[2] := LayerObjectParam('TCRC32LayerWriter.PresetName',nvtInteger,[loprConstructor]);
Result[3] := LayerObjectParam('TCRC32LayerWriter.Polynomial',nvtInteger,[loprConstructor]);
Result[4] := LayerObjectParam('TCRC32LayerWriter.PolynomialRef',nvtInteger,[loprConstructor]);
Result[5] := LayerObjectParam('TCRC32LayerWriter.InitialValue',nvtInteger,[loprConstructor]);
Result[6] := LayerObjectParam('TCRC32LayerWriter.ReflectIn',nvtBool,[loprConstructor]);
Result[7] := LayerObjectParam('TCRC32LayerWriter.ReflectOut',nvtBool,[loprConstructor]);
Result[8] := LayerObjectParam('TCRC32LayerWriter.XOROutValue',nvtInteger,[loprConstructor]);
LayerObjectParamsJoin(Result,inherited LayerObjectParams);
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_CRC32',TCRC32LayerReader,TCRC32LayerWriter);

end.
