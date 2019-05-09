/* Copyright (c) 2019 by Wayne E. Wright, W5XD
 *
 * The contents of this file are exerpted from the sources obtained from  
 * https://sourceforge.net/projects/wsjt/files/wsjtx-2.0.0/
 * 
 * The algorithms, source code, look-and-feel of WSJT-X and related programs, and
 * protocol specifications for the modes FSK441, FT8, JT4, JT6M JT9, JT65, JTMS, QRA64,
 * ISCAT, MSK144 are Copyright (C) 2001-2018 by one or more of the following authors:
 * Joseph Taylor, K1JT; Bill Somerville, G4WJS; Steven Franke, K9AN; Nico Palermo, 
 * IV3NWV; Grea Bream, KI7MT; Michael Black, W9MDB; Edson Pereira, PY2SDR; Philip Karn,
 * KA9Q; and other memobers of the WSJT Development Group.
 */
#include <cstddef>

#include "include/commons.h"

decltype(foxcom_)* getFoxcom(void)
{
	return &foxcom_;
}


