# Indy - Internet Direct - Proposed Update

This is a proposed update to Indy adding support for OpenSSL 3.x. See Readme.OpenSSL for more information.

##August 2025 Update

The objective of this update is to improve readability and maintainability with only minimal impact on the end user. Primarily, this involves splitting up the IdSSLOpenSSL unit with limited code clean up. IdSSLOpenSSL is retained and continues to provide the classes TIdSSLIOHandlerSocketOpenSSL and TIdServerIOHandlerSSLOpenSSL. This should ensure that basic users of Indy OpenSSL should need to do no more than recompile their source code in order to use this update.

For more information see README.IdSSLOpenSSL.Split

##About Indy

Indy is a well-known internet component suite for **Delphi**, **C++Builder**, and **Free Pascal** providing both low-level 
support (TCP, UDP, raw sockets) and over a 120 higher level protocols (SMTP, POP3, NNT, HTTP, FTP) for building both client and server applications.

For instructions on upgrading the default installed version of Indy in your IDE and for links to the documentation, visit the [Wiki](https://github.com/IndySockets/Indy/wiki).

## License

This project is dual-licensed under the terms of the Indy Modified BSD License and Indy MPL License.
You can choose between one of them if you use this work.

SPDX-License-Identifier: LicenseRef-IndyBSD OR MPL-1.1
