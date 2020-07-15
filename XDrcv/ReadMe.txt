These files in this directory are copied from the wsjt-x source:
	cp $(WSJTX_SOURCE)/lib/jt9com.f90 XDrcv
	cp $(WSJTX_SOURCE)/lib/timer_common.inc XDrcv
	cp $(WSJTX_SOURCE)/lib/constants.f90 XDrcv

The others are source files in this repo.

The Makefile gives priority to files it finds here over those in the WSJTX sources.
At this writing, gen_ft8wave.f90 is an example. That file has a bug that is fixed here
so that users of this library won't crash.

