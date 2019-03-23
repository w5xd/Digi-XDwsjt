/* CommonBlockOffsetDisplay.h
 *
 * Print the byte offsets to various members of FORTRAN
 * common blocks. Matching output from this function from
 * multiple compilers verifies those compilers see the block
 * the same way. If objects compiled by those different compilers
 * (e.g. Visual Studio and MINGW) print differently but are
 * linked into the same executable...it won't end well.
 *
 * This file is not part of the WSJT-X kit. 
 */
#include <iostream>
#include <commons.h>
inline void CommonBlockOffsetDisplay()
{
	struct dec_data *p = 0;
	const char *q1 = reinterpret_cast<const char *>(p);
	const char *q2 = reinterpret_cast<const char *>(&p->ss[0]);
	std::cout << "ss is at " << (q2 - q1) << std::endl;

	q2 = reinterpret_cast<const char *>(&p->savg[0]);
	std::cout << "savg is at 0x" << std::hex << (q2 - q1) << std::endl;
	q2 = reinterpret_cast<const char *>(&p->params.nftx);
	std::cout << "nftx is at 0x" << std::hex << (q2 - q1) << std::endl;
	q2 = reinterpret_cast<const char *>(&p->params.newdat);
	std::cout << "newdat is at 0x" << std::hex << (q2 - q1) << std::endl;
	q2 = reinterpret_cast<const char *>(&p->params.npts8);
	std::cout << "npts8 is at 0x" << std::hex << (q2 - q1) << std::endl;
	q2 = reinterpret_cast<const char *>(&p->params.hisgrid[0]);
	std::cout << "hisgrid is at 0x" << std::hex << (q2 - q1) << std::endl;

}
