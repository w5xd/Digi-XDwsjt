#include <vector>
#include <string>
#include <cstring>
#include <iostream>
#include <algorithm>
#include "XDxmitFT8.h"

int main(int argc, char **argv)
{
	std::cout << "Type line to pack:" << std::endl;
	std::string toPack;
	std::getline(std::cin, toPack);
	std::vector<char> toMsg(37, ' ');
	std::vector<char> c77(77, '0');
	int i3 = 0;
	int n3 = 0;
	std::cout << "converting \'" << toPack << "\'" << std::endl;
	memcpy(&toMsg[0], toPack.c_str(), std::min(toPack.size(), toMsg.size()));
	xdpack77_(&toMsg[0], &i3, &n3, &c77[0]);
	std::cout << "i3=" << i3 << " n3=" << n3 << std::endl << std::flush;
        char stat = 0;
        int nrx = 0;
	std::vector<char> unpacked(37,' ');
        xdunpack77_(&c77[0], &nrx, &unpacked[0], &stat);
	std::string unps;
	unps.assign(unpacked.begin(), unpacked.end());
    	std::cout << "\'" << unps << "\'" << std::endl;
	return 0;
}
