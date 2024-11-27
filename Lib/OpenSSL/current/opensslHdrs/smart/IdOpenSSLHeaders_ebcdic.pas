(* This unit was generated from the source file ebcdic.h2pas 
It should not be modified directly. All changes should be made to ebcdic.h2pas
and this file regenerated *)

{$i IdSSLOpenSSLDefines.inc}

{
    This file is part of the MWA Software Pascal API for OpenSSL .

    The MWA Software Pascal API for OpenSSL is free software: you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The MWA Software Pascal API for OpenSSL is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with the MWA Software Pascal API for OpenSSL.  If not, see <https://www.gnu.org/licenses/>.

    This file includes software copied from the Indy (Internet Direct) project, and which is offered
    under the dual-licensing agreement described on the Indy website. (https://www.indyproject.org/license/)
    }  


unit IdOpenSSLHeaders_ebcdic;


interface

// Headers for OpenSSL 1.1.1
// ebcdic.h


uses
  IdSSLOpenSSLAPI;


  //extern const unsigned char os_toascii[256];
  //extern const unsigned char os_toebcdic[256];

  
{ The EXTERNALSYM directive is ignored by FPC, however, it is used by Delphi as follows: 

The EXTERNALSYM directive prevents the specified Delphi symbol from appearing in header 
files generated for C++. }

{$EXTERNALSYM ebcdic2ascii}
{$EXTERNALSYM ascii2ebcdic}

{$IFDEF OPENSSL_STATIC_LINK_MODEL}
function ebcdic2ascii(dest: Pointer; const srce: Pointer; count: TOpenSSL_C_SIZET): Pointer; cdecl; external CLibCrypto;
function ascii2ebcdic(dest: Pointer; const srce: Pointer; count: TOpenSSL_C_SIZET): Pointer; cdecl; external CLibCrypto;

{$ELSE}
var
  ebcdic2ascii: function (dest: Pointer; const srce: Pointer; count: TOpenSSL_C_SIZET): Pointer; cdecl = nil;
  ascii2ebcdic: function (dest: Pointer; const srce: Pointer; count: TOpenSSL_C_SIZET): Pointer; cdecl = nil;
{$ENDIF}

implementation



uses classes,
     IdSSLOpenSSLExceptionHandlers,
     IdSSLOpenSSLResourceStrings;

{$IFNDEF OPENSSL_STATIC_LINK_MODEL}
{$IFNDEF OPENSSL_NO_LEGACY_SUPPORT}
{$ENDIF} { End of OPENSSL_NO_LEGACY_SUPPORT}

{$WARN  NO_RETVAL OFF}
function ERROR_ebcdic2ascii(dest: Pointer; const srce: Pointer; count: TOpenSSL_C_SIZET): Pointer; cdecl;
begin
  EOpenSSLAPIFunctionNotPresent.RaiseException('ebcdic2ascii');
end;

function ERROR_ascii2ebcdic(dest: Pointer; const srce: Pointer; count: TOpenSSL_C_SIZET): Pointer; cdecl;
begin
  EOpenSSLAPIFunctionNotPresent.RaiseException('ascii2ebcdic');
end;

{$WARN  NO_RETVAL ON}
procedure Load(LibVersion: TOpenSSL_C_UINT; const AFailed: TStringList);
var FuncLoadError: boolean;
begin
  ebcdic2ascii := LoadLibCryptoFunction('ebcdic2ascii');
  FuncLoadError := not assigned(ebcdic2ascii);
  if FuncLoadError then
  begin
    ebcdic2ascii :=  @ERROR_ebcdic2ascii;
  end;

  ascii2ebcdic := LoadLibCryptoFunction('ascii2ebcdic');
  FuncLoadError := not assigned(ascii2ebcdic);
  if FuncLoadError then
  begin
    ascii2ebcdic :=  @ERROR_ascii2ebcdic;
  end;

end;

procedure UnLoad;
begin
  ebcdic2ascii := nil;
  ascii2ebcdic := nil;
end;
{$ENDIF}

initialization

{$IFNDEF OPENSSL_STATIC_LINK_MODEL}
Register_SSLLoader(@Load);
Register_SSLUnloader(@Unload);
{$ENDIF}
finalization


end.
