{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit indylaz_openssllegacy;

{$warn 5023 off : no warning about unused units}
interface

uses
  IdRegisterSSL, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('IdRegisterSSL' , @IdRegisterSSL.Register);
end;

initialization
  RegisterPackage('indylaz_openssllegacy' , @Register);
end.
