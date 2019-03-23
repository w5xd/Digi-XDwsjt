#pragma once
#include "commons.h"
/* Copyright (c) 2019 by Wayne E. Wright, W5XD
 *
 * The contents of this file are exerpted from the sources obtained from  
 * https://sourceforge.net/projects/wsjt/files/wsjtx-2.0.1/
 * 
 * From the WSJT-X source:
 *
 * The algorithms, source code, look-and-feel of WSJT-X and related programs, and
 * protocol specifications for the modes FSK441, FT8, JT4, JT6M JT9, JT65, JTMS, QRA64,
 * ISCAT, MSK144 are Copyright (C) 2001-2018 by one or more of the following authors:
 * Joseph Taylor, K1JT; Bill Somerville, G4WJS; Steven Franke, K9AN; Nico Palermo, 
 * IV3NWV; Grea Bream, KI7MT; Michael Black, W9MDB; Edson Pereira, PY2SDR; Philip Karn,
 * KA9Q; and other memobers of the WSJT Development Group.
 */
typedef size_t fortran_charlen_t;
extern "C" {
	// for transmit....
    void genft8_(char* msg, int* i3, int* n3, char* msgsent, char ft8msgbits[],
		int itone[], fortran_charlen_t, fortran_charlen_t);

	// for receive...
    void symspec_(struct dec_data *, int* k, int* ntrperiod, int* nsps, int* ingain,
		int* minw, float* px, float s[], float* df3, int* nhsym, int* npts8,
		float *m_pxmax);

    void chkcall_(char call[13], char basecall[6], int *cok, fortran_charlen_t, fortran_charlen_t);

    void xdpack77_(char msg[37], int *i3, int *n3, char c77[77]);
    void xdunpack77_(char c77[77], int *nrx, char msg[37], char *success );

    // ensure the transmit-side unpack77 has hashed my call. 
    // generally not necessary to call here cuz genft8 packs and hashes.
    void xdsetpack77mycall_(char mycall[13]);
    void xdsetpack77dxcall_(char dxcall[13]);

}
