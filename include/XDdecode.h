#pragma once
/* Copyright (c) 2019 by Wayne E. Wright, W5XD  */
#include "commons.h"
extern "C" {
	void xdinitfftw3_(const char *data_dir);
	void xddecode_(decltype(dec_data::params)*params,
			short int d2[NTMAX*RX_SAMPLE_RATE],
            const char *temporary_dir);
	void xduninitfftw3_(const char *data_dir);
}
