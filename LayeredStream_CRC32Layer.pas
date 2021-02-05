{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Layered Stream - CRC32 Layer

    Calculates CRC32 checksum of read or written data.

    Several CRC32 variants are provided and can be selected to produce a
    desired checksum. It is also possible to configure custom CRC32 algorithm.

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
    AuxTypes           - github.com/TheLazyTomcat/Lib.AuxTypes
    AuxClasses         - github.com/TheLazyTomcat/Lib.AuxClasses
    SimpleNamedValues  - github.com/TheLazyTomcat/Lib.SimpleNamedValues
    LayeredStream      - github.com/TheLazyTomcat/Lib.LayeredStream
    CRC32              - github.com/TheLazyTomcat/Lib.CRC32
    HashBase           - github.com/TheLazyTomcat/Lib.HashBase
    StrRect            - github.com/TheLazyTomcat/Lib.StrRect
    StaticMemoryStream - github.com/TheLazyTomcat/Lib.StaticMemoryStream
  * SimpleCPUID        - github.com/TheLazyTomcat/Lib.SimpleCPUID

    SimpleCPUID might not be needed, refer to CRC32 library for details.

===============================================================================}
unit LayeredStream_CRC32Layer;

{$INCLUDE './LayeredStream_defs.inc'}
{$message 'later create superclasses HashingLayerReader/Writer'}

interface

uses
  Classes,
  SimpleNamedValues, CRC32,
  LayeredStream_Layers;

const
  CRC32CLASS_PKZIP      = 0;
  CRC32CLASS_CASTAGNOLI = 1;
  CRC32CLASS_CUSTOM     = 2;

{===============================================================================
--------------------------------------------------------------------------------
                               TCRC32LayerReader
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TCRC32LayerReader - class declaration
===============================================================================}
type
  TCRC32LayerReader = class(TLSLayerReader)
  private
    fHasher:  TCRC32BaseHash;
    Function GetCRC32: TCRC32;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function ReadActive(out Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Final; override;
    property Hasher: TCRC32BaseHash read fHasher;
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
  TCRC32LayerWriter = class(TLSLayerWriter)
  private
    fHasher:  TCRC32BaseHash;
    Function GetCRC32: TCRC32;
  protected
    Function SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function WriteActive(const Buffer; Size: LongInt): LongInt; override;
    procedure Initialize(Params: TSimpleNamedValues); override;
    procedure Finalize; override;
  public
    class Function LayerObjectProperties: TLSLayerObjectProperties; override;
    class Function LayerObjectParams: TLSLayerObjectParams; override;
    procedure Init(Params: TSimpleNamedValues); override;
    procedure Final; override;
    property Hasher: TCRC32BaseHash read fHasher;
    property CRC32: TCRC32 read GetCRC32;
  end;

implementation

uses
  LayeredStream;

{===============================================================================
    Auxiliary routines
===============================================================================}

Function CreateHasherCommon(const Prefix: String; Params: TSimpleNamedValues): TCRC32BaseHash;
begin
If Params.Exists(Prefix + '.Class',nvtInteger) then
  case Params.IntegerValue[Prefix + '.Class'] of
    CRC32CLASS_PKZIP:
      Result := TCRC32Hash.Create;
    CRC32CLASS_CASTAGNOLI:
      Result := TCRC32CHash.Create;
    CRC32CLASS_CUSTOM:
      begin
        Result := TCRC32CustomHash.Create;
        If Params.Exists(Prefix + '.PresetIndex',nvtInteger) then
          TCRC32CustomHash(Result).LoadPreset(Params.IntegerValue[Prefix + '.PresetIndex'])
        else If Params.Exists(Prefix + '.PresetName',nvtString) then
          TCRC32CustomHash(Result).LoadPreset(Params.StringValue[Prefix + '.PresetName'])
        else
          begin
            If Params.Exists(Prefix + '.Polynomial',nvtInteger) then
              TCRC32CustomHash(Result).CRC32Poly := TCRC32Sys(Params.IntegerValue[Prefix + '.Polynomial'])
            else If Params.Exists(Prefix + '.PolynomialRef',nvtInteger) then
              TCRC32CustomHash(Result).CRC32PolyRef := TCRC32Sys(Params.IntegerValue[Prefix + '.PolynomialRef']);
            If Params.Exists(Prefix + '.InitialValue',nvtInteger) then
              TCRC32CustomHash(Result).InitialValue := TCRC32(Params.IntegerValue[Prefix + '.InitialValue']);
            If Params.Exists(Prefix + '.ReflectIn',nvtBool) then
              TCRC32CustomHash(Result).ReflectIn := Params.BoolValue[Prefix + '.ReflectIn'];
            If Params.Exists(Prefix + '.ReflectOut',nvtBool) then
              TCRC32CustomHash(Result).ReflectOut := Params.BoolValue[Prefix + '.ReflectOut'];
            If Params.Exists(Prefix + '.XOROutValue',nvtInteger) then
              TCRC32CustomHash(Result).XOROutValue := TCRC32(Params.IntegerValue[Prefix + '.XOROutValue']);
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

Function TCRC32LayerReader.GetCRC32: TCRC32;
begin
Result := fHasher.CRC32;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerReader - protected methods
-------------------------------------------------------------------------------}

Function TCRC32LayerReader.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TCRC32LayerReader.ReadActive(out Buffer; Size: LongInt): LongInt;
begin
Result := ReadOut(Buffer,Size);
fHasher.Update(Buffer,Result);
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerReader.Initialize(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  fHasher := CreateHasherCommon('TCRC32LayerReader',Params)
else
  fHasher := TCRC32Hash.Create;
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerReader.Finalize;
begin
fHasher.Free;
inherited;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerReader - public methods
-------------------------------------------------------------------------------}

class Function TCRC32LayerReader.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopNeedsInit,lopNeedsFinal,lopPassthrough,lopObserver];
end;

//------------------------------------------------------------------------------

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
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerReader.Init(Params: TSimpleNamedValues);
begin
inherited;
fHasher.Init;
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerReader.Final;
begin
fHasher.Final;
inherited;
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

Function TCRC32LayerWriter.GetCRC32: TCRC32;
begin
Result := fHasher.CRC32;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerWriter - protected methods
-------------------------------------------------------------------------------}

Function TCRC32LayerWriter.SeekActive(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
Result := SeekOut(Offset,Origin);
end;

//------------------------------------------------------------------------------

Function TCRC32LayerWriter.WriteActive(const Buffer; Size: LongInt): LongInt;
begin
Result := WriteOut(Buffer,Size);
fHasher.Update(Buffer,Result);
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerWriter.Initialize(Params: TSimpleNamedValues);
begin
inherited;
If Assigned(Params) then
  fHasher := CreateHasherCommon('TCRC32LayerWriter',Params)
else
  fHasher := TCRC32Hash.Create;
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerWriter.Finalize;
begin
fHasher.Free;
inherited;
end;

{-------------------------------------------------------------------------------
    TCRC32LayerWriter - public methods
-------------------------------------------------------------------------------}

class Function TCRC32LayerWriter.LayerObjectProperties: TLSLayerObjectProperties;
begin
Result := [lopNeedsInit,lopNeedsFinal,lopPassthrough,lopObserver];
end;

//------------------------------------------------------------------------------

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
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerWriter.Init(Params: TSimpleNamedValues);
begin
inherited;
fHasher.Init;
end;

//------------------------------------------------------------------------------

procedure TCRC32LayerWriter.Final;
begin
fHasher.Final;
inherited;
end;

{===============================================================================
    Layer registration
===============================================================================}

initialization
  RegisterLayer('LSRL_CRC32',TCRC32LayerReader,TCRC32LayerWriter);

end.
