unit IdRegisterSSL;

{$mode objfpc}{$H+}

interface

uses
  Classes , SysUtils, IdDsnCoreResourceStrings,  IdDsnResourceStrings ,
  {$IFDEF FPC}
  LResources,
  {$ENDIF}
  IdSSLOpenSSL;

procedure Register;

implementation

procedure Register;
begin
  {$IFDEF FPC}
  RegisterComponents(RSRegIndyIOHandlers+RSProt, [
  TIdServerIOHandlerSSLOpenSSL,
  TIdSSLIOHandlerSocketOpenSSL
  ]);
  {$ELSE}
  RegisterComponents(RSRegIndyIOHandlers, [
  TIdServerIOHandlerSSLOpenSSL,
  TIdSSLIOHandlerSocketOpenSSL
  ]);
  {$ENDIF}
end;

{$IFDEF FPC}
initialization
{$i IdRegisterSSL.lrs}
{$ENDIF}
end.

