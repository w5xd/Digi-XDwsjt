/* Shim DLL between Windows clients and the mostly unmodified wsjt-x codes
** The purpose of this shim is to provide a place to maintain a more stable
** interface to Windows clients than they would get if the call directly into
** the wsjt-x as-built codes. That is, wsjt-x does not typically maintain function
** prototypes from release to release. Depending on the exact nature of the change,
** it might be possible to maintain the old interface here.
*/

#include <Windows.h>
#include "XDencode.h"
#include "XDdecode.h"

struct SymSpecFcn {
    // symspec has a new signature in wsjt-x 2.6 and this is it:
    typedef void (* symspec)(struct dec_data *, int* k, double* ntrperiod, int* nsps, int* ingain,
        bool* bLowSidelobes, int* minw, float* px, float s[], float* df3,
        int* nhsym, int* npts8, float *m_pxmax, int *npct);

    SymSpecFcn()
    {
        m_module = LoadLibraryA("XDwsjt.dll");
        m_proc = reinterpret_cast<symspec>(GetProcAddress(m_module, "symspec_"));
    }

    symspec fcn() const { return m_proc;  }
protected:
    HMODULE m_module;
    symspec m_proc;
};

extern "C" {

/* The naming convention here is to use "shim_" to prefix the names in this DLL.
** Windows development tools enable publishing a different name for clients than
** is used to link this DLL, and that publishing is done in the DLL's .DEF file.
*/

    // this is the old signature, pre wsjtx 2.6
    // we can't dispense with the "shim_" prefix because there cannot be multiple
    // C-callable functions sharing the same name but with different parameters.
    // Only C++ allows that.
    void shim_symspec_(struct dec_data *a1, int* k, int* ntrperiod, int* nsps, int* ingain,
        bool* bLowSidelobes, int* minw, float* px, float s[], float* df3,
        int* nhsym, int* npts8, float *m_pxmax)
    {
        static SymSpecFcn symSpecFcn;
        double TRPeriod = *ntrperiod;
        int pct = 0;
        auto f = symSpecFcn.fcn();
        return (*f)(a1, k, &TRPeriod, nsps, ingain, bLowSidelobes, minw, px, s, df3, nhsym, npts8, m_pxmax, &pct);
    }

    void shim_chkcall_(char call[13], char basecall[6], int *cok, fortran_charlen_t l1, fortran_charlen_t l2)
    {
        return chkcall_(call, basecall, cok, l1, l2);
    }

    void shim___packjt77_MOD_pack28(char call[13], int *n28, fortran_charlen_t l1)
    {
        return __packjt77_MOD_pack28(call, n28, l1);
    }

    void shim_xdpack77_(char msg[37], int *i3, int *n3, char c77[77])
    {
        return xdpack77_(msg, i3, n3, c77);
    }
    void shim_xdunpack77_(char c77[77], int *nrx, char msg[37], char *success)
    {
        return xdunpack77_(c77, nrx, msg, success);
    }

    // ensure the transmit-side unpack77 has hashed my call. 
    // generally not necessary to call here cuz genft8 packs and hashes.
    void shim_xdsetpack77mycall_(char mycall[13])
    {
        xdsetpack77mycall_(mycall);
    }

    void shim_xdsetpack77dxcall_(char dxcall[13])
    {
        return xdsetpack77dxcall_(dxcall);
    }

    void shim_xdinitfftw3_(const char *data_dir)
    {
        return xdinitfftw3_(data_dir);
    }

    void shim_xddecode_(decltype(dec_data::params)*params,
        short int d2[NTMAX*RX_SAMPLE_RATE],
        const char *temporary_dir)
    {
        return xddecode_(params, d2, temporary_dir);
    }

    void shim_xduninitfftw3_(const char *data_dir)
    {
        return xduninitfftw3_(data_dir);
    }

    void shim_genft8_(char* msg, int* i3, int* n3, char* msgsent, char ft8msgbits[],
        int itone[], fortran_charlen_t l1, fortran_charlen_t l2)
    {
        return genft8_(msg, i3, n3, msgsent, ft8msgbits, itone, l1, l2);
    }

    void shim_genft4_(char* msg, int* ichk, char* msgsent, char ft4msgbits[], int itone[],
        fortran_charlen_t l1, fortran_charlen_t l2)
    {
        return genft4_(msg, ichk, msgsent, ft4msgbits, itone, l1, l2);
    }
    float shim_gfsk_pulse_(float *amp, float *time)
    {
        return gfsk_pulse_(amp, time);
    }


}