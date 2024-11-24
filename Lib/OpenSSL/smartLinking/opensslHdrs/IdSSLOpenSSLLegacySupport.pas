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

unit IdSSLOpenSSLLegacySupport;

interface

uses
  Classes, SysUtils, IdSSLOpenSSLAPI;

procedure SetLegacyCallbacks;
procedure RemoveLegacyCallbacks;

implementation

uses SyncObjs,
     IdOpenSSLHeaders_crypto;

{$IFNDEF OPENSSL_NO_LEGACY_SUPPORT}
type

  { TOpenSSLLegacyCallbacks }

  TOpenSSLLegacyCallbacks = class(TThreadList)
  private
    procedure PrepareOpenSSLLocking;
    class var FCallbackList: TOpenSSLLegacyCallbacks;
  public
    constructor Create;
    destructor Destroy; override;
  end;

procedure TOpenSSLLegacyCallbacks.PrepareOpenSSLLocking;
var
  i: integer;
  Lock: TCriticalSection;
begin
  LockList;
  try
    for i := 0 to CRYPTO_num_locks - 1 do
    begin
      Lock := TCriticalSection.Create;
      try
        Add(Lock);
      except
        Lock.Free;
        raise;
      end;
    end;
  finally
    UnlockList;
  end;
end;

procedure OpenSSLSetCurrentThreadID(id : PCRYPTO_THREADID); cdecl;
begin
  CRYPTO_THREADID_set_numeric(id, TOpenSSL_C_ULONG(GetCurrentThreadId));
end;

procedure OpenSSLLockingCallback(mode, n: TOpenSSL_C_INT; Afile: PAnsiChar;
  line: TOpenSSL_C_INT); cdecl;
var
  Lock: TCriticalSection;
  LList: TList;
begin
  Assert(TOpenSSLLegacyCallbacks.FCallbackList <> nil);
  Lock := nil;

  LList := TOpenSSLLegacyCallbacks.FCallbackList.LockList;
  try
    if n < LList.Count then
      Lock := TCriticalSection(LList[n]);
  finally
    TOpenSSLLegacyCallbacks.FCallbackList.UnlockList;
  end;
  Assert(Lock <> nil);
  if (mode and CRYPTO_LOCK) = CRYPTO_LOCK then
    Lock.Acquire
  else
    Lock.Release;
end;

constructor TOpenSSLLegacyCallbacks.Create;
begin
  Assert(FCallbackList = nil);
  inherited Create;
  FCallbackList := self;
  PrepareOpenSSLLocking;
  CRYPTO_set_locking_callback(@OpenSSLLockingCallback);
  CRYPTO_THREADID_set_callback(@OpenSSLSetCurrentThreadID);
end;

destructor TOpenSSLLegacyCallbacks.Destroy;
var i: integer;
    LList: TList;
begin
  CRYPTO_set_locking_callback(nil);
  LList := LockList;

  try
    for i := 0 to LList.Count - 1 do
      TCriticalSection(LList[i]).Free;
    Clear;
  finally
    UnlockList;
  end;
  inherited Destroy;
  FCallbackList := nil;
end;
{$ENDIF}


procedure SetLegacyCallbacks;
begin
  {$IFNDEF OPENSSL_NO_LEGACY_SUPPORT}
  if TOpenSSLLegacyCallbacks.FCallbackList = nil then
    TOpenSSLLegacyCallbacks.Create;
  {$ENDIF}
end;

procedure RemoveLegacyCallbacks;
begin
  {$IFNDEF OPENSSL_NO_LEGACY_SUPPORT}
  if TOpenSSLLegacyCallbacks.FCallbackList <> nil then
    FreeAndNil(TOpenSSLLegacyCallbacks.FCallbackList);
  {$ENDIF}
end;

finalization
  RemoveLegacyCallbacks;

end.


