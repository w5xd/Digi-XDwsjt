# Makefile for XDwsjtFT.dll for Windows
# Copyright (c) 2019 by Wayne E. Wright, W5XD
#
# Notice required because this work is a derivative of WSJT-X:
#
#   The algorithms, source code, look-and-feel of WSJT-X and related programs, and
#   protocol specifications for the modes FSK441, FT8, JT4, JT6M JT9, JT65, JTMS, QRA64,
#   ISCAT, MSK144 are Copyright (C) 2001-2018 by one or more of the following authors:
#   Joseph Taylor, K1JT; Bill Somerville, G4WJS; Steven Franke, K9AN; Nico Palermo, 
#   IV3NWV; Grea Bream, KI7MT; Michael Black, W9MDB; Edson Pereira, PY2SDR; Philip Karn,
#   KA9Q; and other memobers of the WSJT Development Group.
#
# If you want to build a .NET application that implements FT8/FT4 that is compatible
# with wsjtx, then you probably do NOT need to run this Makefile. 
#
# If you link to XDwsjtFT.dll, you should read this:
# https://www.gnu.org/licenses/gpl-faq.html#IfLibraryIsGPL
#
# Instead, you need the binaries and include files that result from
# this make. That result is built into XDwsjtSdk.7z. That kit is
# build on occasion and made available
# for download in the repo where you found this source.
# Also in XDwsjtSdk are the binaires you'll need
# for a distribution kit in runtimeWin32 and/or runtimex64.
#
# This Makefile builds the Windows dll XDwsjtFT.dll using the MINGW toolset.
# There are 3 downloads to obtain to make this work, (and a fourth to get a w64 dll):
# 
# 1. The file wsjtx-2.0.1.tgz from https://sourceforge.net/projects/wsjt/files/wsjtx-2.0.1/
# These are the sources to wsjtx version 2. NO CHANGES ARE MADE TO THOSE SOURCES
# Unpack the archive onto your disk to the location of your choosing.
# The archive contains archives. Unpack them, too.
# Arrange for this Makefile to find them (see below)
#
# 2. Download and install the MingW toolkit for building 32 bit executables:
#    https://sourceforge.net/projects/mingw/
#    You need g++, gfortran, and make.
#
# 3. The fftw libraries from http://www.fftw.org/download.html
# 32bit: ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll32.zip
# 64bit: ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll64.zip (optional)
# Unzip both into eponymous folders where this Makefile resides.
#
# Arranging for make to find the wsjtx source
# The MINGW environment has an etc directory containing a file named fstab.
# Add two lines to it, similar to this:
# 	C:/dev/wsjtx-src				/wsjtx-src
# 	C:/dev/wsjtx-src/wsjtx-2.0.1/src/wsjtx/boost	/boost
# Explanation: I unzipped the wsjtx sources into C:\dev\wsjtx-src. So I make MINGW's /wsjtx-src point to it.
# A cpp compile below needs boost. Make MINGW's /boost point to the boost from wsjtx
# Now that /dev is MINGW's view of the source, point WSJTX_SOURCE to its subdirectory that this Makefile cares about.
WSJTX_SOURCE = /wsjtx-src

# if you need a 64bit build as well, then:
# 4. Get the MINGW64 toolkit. I used this one:
# https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-win32/seh/x86_64-8.1.0-release-win32-seh-rt_v6-rev0.7z/download
# Unpack the archive somewhere and add another line to the same fstab as above:
# C:/mingw64		                /mingw64
#
# Two more files to edit to make the 64 bit build work:
# In the MINGW msys directory with msys.bat, I added the following contents to a new file named msys64.bat:
# in msys64.bat:
# 	@rem for XDwsjtFT 64 bit build
#	set MSYSTEM=MINGW64
# 	call msys.bat
# 
# In MINGW's etc directory where the file "profile" is found. I added a clause to its PATH setting, this way:
# in etc/profile:
# 	if [ $MSYSTEM == MINGW32 ]; then
# 		export PATH=".:/usr/local/bin:/mingw/bin:/bin:$PATH"
#	elif [ $MSYSTEM == MINGW64 ]; then
#  		export PATH=".:/usr/local/bin:/mingw64/bin:/bin:$PATH"
#	else
#
# 5. Start a command window by double clicking either msys.bat (to build x32)
#    or msys64.bat (to build x64)
# 	cd <to the directory containing this Makefile>
#	make clean
#	make all
#
# When you switch between 32b and 64b builds, its is IMPORTANT to "make clean" before "make all"
#
# What you need at the end is the buildWin32 (or buildx64) directory. Those are the binaries for
# distribution. 
#
# To build against XDwsjtFT.dll, you go to the Visual Studio solution (in a separate 
# repo) and edit the 3 Visual Studio .props files to point here for INCLUDE and LIB defintions.
#
# To pack up the results of building this kit, use MakeWinSDK.bat to pack
# only the bits the Visual Studio project needs into XDwsjtSdk.7z.
# 
FC = gfortran
CPP = g++
ARCH = 
RM = rm

#use MINGW's MSYSTEM env variable to see whether its a 32 or 64 build
ifeq ($(MSYSTEM), MINGW32)
LIB=fftw-3.3.5-dll32
BUILDDIR = libWin32
KITLIBDIR = binWin32
else
LIB=fftw-3.3.5-dll64
BUILDDIR = libx64
KITLIBDIR = binx64
LIBQUADMATH = "-lquadmath" #64bit link of packtest requires this
endif

#fftw requires this one-time, ming-specific lib extraction. do it each of the 32 and 64 bit directories
#   dlltool -l libfftw3f-3.lib -d libfftw3f-3.def
#

OPTIMIZE_OR_DEBUG = -O2  
#OPTIMIZE_OR_DEBUG = -g -Og

FFLAGS = $(OPTIMIZE_OR_DEBUG) -fbounds-check -Wall -Wno-conversion -fno-second-underscore ${ARCH}
CFLAGS = $(OPTIMIZE_OR_DEBUG) -I. -I/boost -std=c++0x -fpermissive -mno-stack-arg-probe ${ARCH}

vpath %.f90 $(WSJTX_SOURCE)/lib
vpath %.f03 $(WSJTX_SOURCE)/lib
vpath %.f90 $(WSJTX_SOURCE)/lib/ft8
vpath %.f90 $(WSJTX_SOURCE)/lib/ft2
vpath %.f90 $(WSJTX_SOURCE)/lib/ft4
vpath %.f90 $(WSJTX_SOURCE)/lib/77bit
vpath %.cpp $(WSJTX_SOURCE)/lib
vpath %.f90 XDrcv            #one compile is code that is NOT from wsjtx

all:    $(BUILDDIR)/XDwsjtFT.dll include/commons.h $(BUILDDIR)/CommonBlockOffsetDisplay \
	$(BUILDDIR)/XDwsjtFT.dll $(KITLIBDIR) packtest.exe


#modulator
fortran_xmit_src = packjt.f90 packjt77.f90 genft8.f90 grid2deg.f90 deg2grid.f90 fmtmsg.f90 crc.f90 \
		   encode174_91.f90 fftw3mod.f90 \
      		   chkcall.f90 four2a.f90 foxgen.f90 foxfilt.f90 symspec.f90 flat1.f90 smo.f90 \
		   pctile.f90 shell.f90 \
     	           refspectrum.f90 smo121.f90 polyfit.f90 db.f90 determ.f90 gfsk_pulse.f90 \
		   gen_ft4wave.f90 genft4.f90

$(BUILDDIR)/XDxmitFT8.o: XDxmitFT8.cpp include/commons.h

$(BUILDDIR)/packandunpack77.o: packandunpack77.f90

cpp_src = crc14.cpp
objects = $(patsubst %.f90,$(BUILDDIR)/%.o,$(fortran_xmit_src))
cpp_objects = $(patsubst %.cpp,$(BUILDDIR)/%.o,$(cpp_src))

#demodulator
fortran_rcv_src = options.f90 prog_args.f90 iso_c_utilities.f90 \
		  timer_module.f90 timer_impl.f90 ft8_decode.f90 \
		  my_hash.f90 ft8b.f90 sync8.f90 ft8apset.f90 indexx.f90 sync8d.f90 \
		  twkfreq1.f90 baseline.f90 \
		  ft8_downsample.f90 subtractft8.f90 osd174_91.f90 bpdecode174_91.f90 \
		  genft8refsig.f90 chkcrc14a.f90 \
		  platanh.f90 azdist.f90 geodist.f90 filbig.f90 \
		  xdinitfftw3.f90 xduninitfftw3.f90 nuttal_window.f90 gen_ft8wave.f90 \
		  ft4_decode.f90 ft4_downsample.f90 getcandidates4.f90 subtractft4.f90 \
		  sync4d.f90 

$(BUILDDIR)/XDdecode.o: XDrcv/XDdecode.f90 XDrcv/jt9com.f90
	${FC} ${FFLAGS} -Wno-unused-dummy-argument -c XDrcv/XDdecode.f90 -o $(BUILDDIR)/XDdecode.o

robjects = $(patsubst %.f90,$(BUILDDIR)/%.o,$(fortran_rcv_src))

$(BUILDDIR):
	mkdir $(BUILDDIR)

$(objects): | $(BUILDDIR)

$(robjects): | $(BUILDDIR)

$(cpp_objects): | $(BUILDDIR)

# Default rules
$(BUILDDIR)/%.o: %.cpp
	${CPP} ${CFLAGS} -c $< -o $@
$(BUILDDIR)/%.o: %.f
	${FC} ${FFLAGS} -c $< -o $@
$(BUILDDIR)/%.o: %.f90
	${FC} ${FFLAGS} -c $< -o $@

# move files from the wsjtx source tree here. This makes an include directory
# for the rest of XDft8 to depend on that only has the needed bits.
include/commons.h:
	cp $(WSJTX_SOURCE)/commons.h include
	cp $(WSJTX_SOURCE)/COPYING include
#...and a few more here
XDrcv/jt9com.f90:
	cp $(WSJTX_SOURCE)/lib/jt9com.f90 XDrcv
	cp $(WSJTX_SOURCE)/lib/timer_common.inc XDrcv
	cp $(WSJTX_SOURCE)/lib/constants.f90 XDrcv

#resource compile so the binaries have version numbers.
#how come nobody in the open source world puts versions in their binaries like this?
$(BUILDDIR)/XDwsjtFTres.o:	XDwsjtFT.rc
	windres XDwsjtFT.rc $(BUILDDIR)/XDwsjtFTres.o

$(KITLIBDIR):	 $(BUILDDIR)/XDwsjtFT.dll make-$(KITLIBDIR)
	make-$(KITLIBDIR)

# is fftw3f-3 the best one for this purpose? its the one wsjtx-2.0.0 uses
$(BUILDDIR)/XDwsjtFT.dll: \
	$(objects) $(cpp_objects) $(BUILDDIR)/XDwsjtFTres.o $(BUILDDIR)/XDxmitFT8.o \
		$(robjects) $(BUILDDIR)/XDdecode.o $(BUILDDIR)/packandunpack77.o
	$(FC) -g -Og -o $(BUILDDIR)/XDwsjtFT.dll $(objects) $(cpp_objects) \
	$(BUILDDIR)/XDwsjtFTres.o \
	$(BUILDDIR)/XDxmitFT8.o \
	$(BUILDDIR)/packandunpack77.o \
	$(robjects) $(BUILDDIR)/XDdecode.o \
	-shared -L$(LIB) -lfftw3f-3 -Wl,--out-implib,$(BUILDDIR)/XDwsjtFT.lib

#test programs

#Using FORTRAN common blocks to communicate in shared memory calls for
#verification when we're using 6 (count 'em !) compilers that ALL have to agree on the memory layout.
# g++, gfortran and visual studio,,,and each in its x86 and x64 variantions.
$(BUILDDIR)/CommonBlockOffsetDisplay: CommonBlockOffsetDisplay.cpp include/CommonBlockOffsetDisplay.h include/commons.h
	${CPP} -Iinclude -o $(BUILDDIR)/CommonBlockOffsetDisplay CommonBlockOffsetDisplay.cpp

#the pack77 unpack77 routines might need a little debug inspection
packtest.exe: \
	$(objects) $(cpp_objects) $(BUILDDIR)/XDwsjtFTres.o $(BUILDDIR)/XDxmitFT8.o \
		$(robjects) $(BUILDDIR)/XDdecode.o $(BUILDDIR)/packandunpack77.o packtest.o
	${CPP} -g -Og -o packtest.exe packtest.o $(objects) $(cpp_objects) \
	$(BUILDDIR)/XDwsjtFTres.o \
	$(BUILDDIR)/XDxmitFT8.o \
	$(BUILDDIR)/packandunpack77.o \
	$(robjects) $(BUILDDIR)/XDdecode.o \
	-L$(LIB) -lfftw3f-3 -lgfortran $(LIBQUADMATH)

packtest.o: packtest.cpp
	${CPP} -Iinclude $(CFLAGS) -o packtest.o -c packtest.cpp

.PHONY : clean

clean:
	$(RM) *.mod $(BUILDDIR)/*.o $(BUILDDIR)/*.dll $(BUILDDIR)/*.lib include/commons.h $(BUILDDIR)/*.exe *.exe *.o
	$(RM) -rf $(KITLIBDIR)
