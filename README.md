# Digi-XDwsjt
XDxmitFT8.dll build kit
Copyright (c) 2019 by Wayne E. Wright, W5XD

 The algorithms, source code, look-and-feel of WSJT-X and related programs, and
 protocol specifications for the modes FSK441, FT8, JT4, JT6M JT9, JT65, JTMS, QRA64,
 ISCAT, MSK144 are Copyright (C) 2001-2018 by one or more of the following authors:
 Joseph Taylor, K1JT; Bill Somerville, G4WJS; Steven Franke, K9AN; Nico Palermo, 
 IV3NWV; Grea Bream, KI7MT; Michael Black, W9MDB; Edson Pereira, PY2SDR; Philip Karn,
 KA9Q; and other memobers of the WSJT Development Group.

If you want to build a Visual Studio .net project that implements FT8, then
you do NOT need to build this kit. Instead, download its result:
	 XDwsjtFT8Sdk-<version>.7z
And clone the git project Digi-XDft

See the <a href='Makefile'>Makefile</a>.
It uses MINGW to build a dll with the FT8 encoding algorithms as built from 
the published wsjt-x sources. It supports a 32 bit bulid using mingw, and,
optionally, also a 64 bit build if you also install mingw64.

The result of "make all" is a lib32 or lib64 continaing the code to
distribute. After you do make-all in 32b and/or 64b, then run
MakeWinSDK to pack up an SDK that itself supports whichever
architectures you have built up to then.


The sources from wsjtx-2.0.1 are reproduced here in wsjtx-2.0.1-subset.7z. Only the sources needed to build XDwsjtFT8.dll are included.
