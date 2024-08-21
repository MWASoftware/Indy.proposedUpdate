brc32 IdRegister.rc -r -foIdRegister.dcr
copy IdRegister.dcr ..\src\Protocols
brc32 IdCoreRegister.rc -r -foIdCoreRegister.dcr
copy IdCoreRegister.dcr ..\src\Core
brc32 IdSuperCoreRegister.rc -r -foIdSuperCoreRegister.dcr
copy IdSuperCoreRegister.dcr ..\src\SuperCore
brcc32 IdOpenSSLRegister.rc -r -foIdOpenSSLRegister.dcr
copy IdOpenSSLRegister.dcr ..\src\OpenSSL\legacy
