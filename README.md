# Digi-XDwsjt
XDxmitFT8.dll build kit
Copyright (c) 2020 by Wayne E. Wright, W5XD
<blockquote>
The algorithms, source code, look-and-feel of WSJT-X and related 
programs, and protocol specifications for the modes FSK441, FT8, JT4, 
JT6M, JT9, JT65, JTMS, QRA64, ISCAT, MSK144 are Copyright (C) 
2001-2020 by one or more of the following authors: Joseph Taylor, 
K1JT; Bill Somerville, G4WJS; Steven Franke, K9AN; Nico Palermo, 
IV3NWV; Greg Beam, KI7MT; Michael Black, W9MDB; Edson Pereira, PY2SDR;
Philip Karn, KA9Q; and other members of the WSJT Development Group.
</blockquote>

If you want to build a Visual Studio .net project that implements FT8, then
you do <b><i>not</i></b> need to build this kit. Instead, download its result:
	 XDwsjtFtSdk-&lt;version&gt;.zip

See the <a href='Makefile'>Makefile</a>.
It uses <a href='https://osdn.net/projects/mingw/'>MINGW</a> to build a dll with the FT8 encoding algorithms as built from 
the published wsjt-x sources. It supports a 32 bit bulid using mingw, and,
optionally, also a 64 bit build if you also install mingw64.

The result of "make all" is a lib32 or lib64 containing the code to
distribute. After you do make-all in 32b and/or 64b, then run
MakeWinSDK to pack up an SDK that itself supports whichever
architectures you have built up to then.


