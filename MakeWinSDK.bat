@rem gather up the results of this build that are themselves inputs
@rem to the visual studio build of XDft8
@rem Makefile does NOT invoke MakeWinSDK.bat. You have to
@rem first "make all" in a 32bit and/or 64bit mingw environment.
@rem Once those are complete, run this command
if exist XDwsjtFT8Sdk.7z del XDwsjtFT8Sdk.7z
7z a XDwsjtFT8Sdk.7z libWin32/*.lib libx64/*.lib include
if exist binWin32 7z a XDwsjtFT8Sdk.7z binWin32 
if exist binx64 7z a XDwsjtFT8Sdk.7z binx64 

