unit IdOpenSSLNTMLv2;

{$I IdCompilerDefines.inc}

interface

uses
  Classes , SysUtils, IdGlobal;

procedure LoadNTMLv2Functions;

implementation

uses
  IdNTLMv2, IdOpenSSLHeaders_des;

const
  Magic: des_cblock = ( $4B, $47, $53, $21, $40, $23, $24, $25 );

{/*
 * turns a 56 bit key into the 64 bit, odd parity key and sets the key.
 * The key schedule ks is also set.
 */}
procedure setup_des_key(key_56: des_cblock; Var ks: des_key_schedule);
{$IFDEF USE_INLINE}inline;{$ENDIF}
var
  key: des_cblock;
begin
  key[0] := key_56[0];

  key[1] := ((key_56[0] SHL 7) and $FF) or (key_56[1] SHR 1);
  key[2] := ((key_56[1] SHL 6) and $FF) or (key_56[2] SHR 2);
  key[3] := ((key_56[2] SHL 5) and $FF) or (key_56[3] SHR 3);
  key[4] := ((key_56[3] SHL 4) and $FF) or (key_56[4] SHR 4);
  key[5] := ((key_56[4] SHL 3) and $FF) or (key_56[5] SHR 5);
  key[6] := ((key_56[5] SHL 2) and $FF) or (key_56[6] SHR 6);
  key[7] :=  (key_56[6] SHL 1) and $FF;

  DES_set_odd_parity(@key);
  DES_set_key(@key, ks);
end;

//Returns 8 bytes in length
procedure _DES_(var Res : TIdBytes; const Akey, AData : array of byte; const AKeyIdx, ADataIdx, AResIdx : Integer);
var
  Lks: des_key_schedule;
begin
  setup_des_key(pdes_cblock(@Akey[AKeyIdx])^, Lks);
  DES_ecb_encrypt(@AData[ADataIdx], PDES_cblock(@Res[AResIdx]), @Lks, DES_ENCRYPT);

end;

{/*
 * takes a 21 byte array and treats it as 3 56-bit DES keys. The
 * 8 byte plaintext is encrypted with each key and the resulting 24
 * bytes are stored in the results array.
 */}
procedure DESL_(const Akeys: TIdBytes; const AServerNonce: TIdBytes; out results: TIdBytes);
//procedure DESL(keys: TIdBytes; AServerNonce: TIdBytes; results: TIdBytes);
//procedure DESL(keys: TIdBytes; AServerNonce: TIdBytes; results: Pdes_key_schedule);
var
  ks: des_key_schedule;
begin
  SetLength(Results,24);
  setup_des_key(PDES_cblock(@Akeys[0])^, ks);
  DES_ecb_encrypt(@AServerNonce[0], PDES_cblock(results), @ks, DES_ENCRYPT);

  setup_des_key(PDES_cblock(@Akeys[7])^, ks);
  DES_ecb_encrypt(@AServerNonce[0], PDES_cblock(PtrUInt(results) + 8), @ks, DES_ENCRYPT);

  setup_des_key(PDES_cblock(@Akeys[14])^, ks);
  DES_ecb_encrypt(@AServerNonce[0], PDES_cblock(PtrUInt(results) + 16), @ks, DES_ENCRYPT);
end;

//* setup LanManager password */
function SetupLMResponse_(var vlmHash : TIdBytes; const APassword : String; AServerNonce : TIdBytes): TIdBytes;
var
  lm_hpw : TIdBytes;
  lm_pw : TIdBytes;
  ks: des_key_schedule;
begin
  SetLength( lm_hpw,21);
  FillBytes( lm_hpw, 14, 0);
  SetLength( lm_pw, 21);
  FillBytes( lm_pw, 14, 0);
  SetLength( vlmHash, 16);
  CopyTIdString( UpperCase( APassword), lm_pw, 0, 14);

  //* create LanManager hashed password */
  setup_des_key(pdes_cblock(@lm_pw[0])^, ks);
  DES_ecb_encrypt(@magic, PDES_cblock(@lm_hpw[0]), @ks, DES_ENCRYPT);

  setup_des_key(pdes_cblock(@lm_pw[7])^, ks);
  DES_ecb_encrypt(@magic, PDES_cblock(@lm_hpw[8]), @ks, DES_ENCRYPT);
  CopyTIdBytes(lm_pw,0,vlmHash,0,16);
 // FillChar(lm_hpw[17], 5, 0);
  SetLength(Result,24);
  DESL(lm_hpw, AServerNonce, Result);
//  DESL(PDes_cblock(@lm_hpw[0]), AServerNonce, Pdes_key_schedule(@Result[0]));
//
end;

function LanManagerSessionKey_(const ALMHash : TIdBytes) : TIdBytes;
var
  LKey : TIdBytes;
  ks : des_key_schedule;
  LHash8 : TIdBytes;
begin
  LHash8 := ALMHash;
  SetLength(LHash8,8);
  SetLength(LKey,14);
  FillChar(LKey,14,$bd);
  CopyTIdBytes(LHash8,0,LKey,0,8);
  SetLength(Result,16);
  setup_des_key(pdes_cblock(@LKey[0])^, ks);
  DES_ecb_encrypt(@LHash8, PDES_cblock(@Result[0]), @ks, DES_ENCRYPT);

  setup_des_key(pdes_cblock(@LKey[7])^, ks);
  DES_ecb_encrypt(@LHash8, PDES_cblock(@Result[8]), @ks, DES_ENCRYPT);
end;

procedure LoadNTMLv2Functions;
begin
  _DES := @_DES_;
  DESL := @DESL_;
  SetupLMResponse := @SetupLMResponse_;
  LanManagerSessionKey := @LanManagerSessionKey_;
end;

end.

