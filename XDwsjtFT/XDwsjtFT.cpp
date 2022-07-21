// XDwsjtFT.cpp : Defines the exported functions for the DLL application.
//
#include <Windows.h>
#include "XDencode.h"
#include "XDdecode.h"

struct SymSpecFcn {
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

    void shim_symspec_(struct dec_data *a1, int* k, int* ntrperiod, int* nsps, int* ingain,
        bool* bLowSidelobes, int* minw, float* px, float s[], float* df3,
        int* nhsym, int* npts8, float *m_pxmax)
    {
        static SymSpecFcn symSpecFcn;
        double TRPeriod = *ntrperiod;
        int pct = 0;
        auto f = symSpecFcn.fcn();
        (*f)(a1, k, &TRPeriod, nsps, ingain, bLowSidelobes, minw, px, s, df3, nhsym, npts8, m_pxmax, &pct);
    }

    void shim_chkcall_(char call[13], char basecall[6], int *cok, fortran_charlen_t l1, fortran_charlen_t l2)
    {
        chkcall_(call, basecall, cok, l1, l2);
    }

    void shim___packjt77_MOD_pack28(char call[13], int *n28, fortran_charlen_t l1)
    {
        __packjt77_MOD_pack28(call, n28, l1);
    }

    void shim_xdpack77_(char msg[37], int *i3, int *n3, char c77[77])
    {
        xdpack77_(msg, i3, n3, c77);
    }
    void shim_xdunpack77_(char c77[77], int *nrx, char msg[37], char *success)
    {
        xdunpack77_(c77, nrx, msg, success);
    }

    // ensure the transmit-side unpack77 has hashed my call. 
    // generally not necessary to call here cuz genft8 packs and hashes.
    void shim_xdsetpack77mycall_(char mycall[13])
    {
        xdsetpack77mycall_(mycall);
    }

    void shim_xdsetpack77dxcall_(char dxcall[13])
    {
        xdsetpack77dxcall_(dxcall);
    }

    void shim_xdinitfftw3_(const char *data_dir)
    {
        xdinitfftw3_(data_dir);
    }

    void shim_xddecode_(decltype(dec_data::params)*params,
        short int d2[NTMAX*RX_SAMPLE_RATE],
        const char *temporary_dir)
    {
        xddecode_(params, d2, temporary_dir);
    }

    void shim_xduninitfftw3_(const char *data_dir)
    {
        xduninitfftw3_(data_dir);
    }

    void shim_genft8_(char* msg, int* i3, int* n3, char* msgsent, char ft8msgbits[],
        int itone[], fortran_charlen_t l1, fortran_charlen_t l2)
    {
        genft8_(msg, i3, n3, msgsent, ft8msgbits, itone, l1, l2);
    }

    void shim_genft4_(char* msg, int* ichk, char* msgsent, char ft4msgbits[], int itone[],
        fortran_charlen_t l1, fortran_charlen_t l2)
    {
        genft4_(msg, ichk, msgsent, ft4msgbits, itone, l1, l2);
    }
    float shim_gfsk_pulse_(float *amp, float *time)
    {
        return gfsk_pulse_(amp, time);
    }


}