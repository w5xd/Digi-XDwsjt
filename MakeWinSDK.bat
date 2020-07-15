@rem gather up the results of this build that are themselves inputs
@rem to the visual studio build of Digi-XDft 

@rem extract the version number from XDwsjtFT.rc
@for /f "tokens=2 usebackq" %%f in (`find "FILEVERSION" XDwsjtFT.rc`) do @set ver=%%f
@set verDot=%ver:,=.%
@set zip=XDwsjtFtSdk-%verDot%.zip
@rem
@rem Makefile does NOT invoke MakeWinSDK.bat. You have to
@rem first "make all" in a 32bit and/or 64bit mingw environment.
@rem Once those are complete, run this command
if exist %zip% del %zip%
if exist include\*~ del include\*~
7z a %zip% libWin32/*.lib libx64/*.lib include
if exist binWin32 (
 copy "\MinGW\bin\libstdc++-6.dll" binWin32
 7z a %zip% binWin32 
)
if exist binx64 (
 copy "\mingw64\bin\libstdc++-6.dll" binx64
 7z a %zip% binx64 
)

