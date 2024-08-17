unit IdWindowsRootCertStore;

{$i IdCompilerDefines.inc}

interface

uses
  Classes , SysUtils, IdOpenSSL, IdSSLOpenSSLHeaders, Windows;

const
  wincryptdll = 'crypt32.dll';
  RootStore = 'ROOT';

type
  HCERTSTORE = THandle;
  HCRYPTPROV_LEGACY = PIdC_LONG;
  PCERT_INFO = pointer; {don't need to know this structure}
  PCCERT_CONTEXT = ^CERT_CONTEXT;
  CERT_CONTEXT = record
    dwCertEncodingType: DWORD;
    pbCertEncoded: PByte;
    cbCertEncoded: DWORD;
    CertInfo: PCERT_INFO;
    certstore: HCERTSTORE
  end;

procedure LoadWindowsCertStore(aContext: TIdSSLContext);

implementation

type
  THackedContext = class(TIdSSLContext)
  private
    function GetContext: PSSL_CTX;
  public
    property SSLContext: PSSL_CTX read GetContext;
  end;


function THackedContext.GetContext: PSSL_CTX;
begin
  Result := fContext;
end;

{$IFDEF STRING_IS_ANSI}
{$EXTERNALSYM CertOpenSystemStoreA}
function CertOpenSystemStoreA(hProv: HCRYPTPROV_LEGACY; szSubsystemProtocol: PIdAnsiChar):HCERTSTORE;
  stdcall; external wincryptdll;
{$ELSE}
{$EXTERNALSYM CertOpenSystemStoreW}
function CertOpenSystemStoreW(hProv: HCRYPTPROV_LEGACY; szSubsystemProtocol: PCHar):HCERTSTORE;
  stdcall; external wincryptdll;
{$ENDIF}

{$EXTERNALSYM CertCloseStore}
function CertCloseStore(certstore: HCERTSTORE; dwFlags: DWORD): boolean; stdcall; external wincryptdll;

{$EXTERNALSYM CertEnumCertificatesInStore}
function CertEnumCertificatesInStore(certstore: HCERTSTORE; pPrevCertContext: PCCERT_CONTEXT): PCCERT_CONTEXT;
  stdcall; external wincryptdll;

{Copy Windows CA Certs to out cert store}
procedure LoadWindowsCertStore(aContext: TIdSSLContext);
var WinCertStore: HCERTSTORE;
    X509Cert: PX509;
    cert_context: PCCERT_CONTEXT;
    error: integer;
    SSLCertStore: PX509_STORE;
    CertEncoded: PByte;
    fContext: PSSL_CTX;
begin
  cert_context := nil;
  fContext := THackedContext(aContext).SSLContext;
  {$IFDEF STRING_IS_ANSI}
  WinCertStore := CertOpenSystemStoreA(0,RootStore);
  {$ELSE}
  WinCertStore := CertOpenSystemStoreW(0,RootStore);
  {$ENDIF}
  if WinCertStore = 0 then
    Exit;

  SSLCertStore := SSL_CTX_get_cert_store(fContext);
  try
    cert_context := CertEnumCertificatesInStore(WinCertStore,cert_context);
    while cert_context <> nil do
    begin
      CertEncoded := cert_context^.pbCertEncoded;
      X509Cert := d2i_X509(nil,@CertEncoded, cert_context^.cbCertEncoded);
      if X509Cert <> nil then
      begin
        error := X509_STORE_add_cert(SSLCertStore, X509Cert);
//Ignore if cert already in store
        if (error = 0) and
           (ERR_GET_REASON(ERR_get_error) <> X509_R_CERT_ALREADY_IN_HASH_TABLE) then
          EIdOpenSSLAPICryptoError.RaiseException(ROSCertificateNotAddedToStore);
        X509_free(X509Cert);
      end;
      cert_context := CertEnumCertificatesInStore(WinCertStore,cert_context);
    end;
  finally
     CertCloseStore(WinCertStore, 0);
  end;
end;



end.

