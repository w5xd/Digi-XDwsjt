!Copyright (c) 2019 by Wayne E. Wright, W5XD
! extracted from wsjtx jt9.f90

subroutine xduninitfftw3(data_directory)
  use FFTW3
  use iso_c_binding, only: C_CHAR, C_NULL_CHAR
   character(kind=c_char, len=1), dimension(*), intent(in) :: data_directory
  character(len=500) :: data_dir
  character wisfile*80
  integer iret
  data_dir = " ";
  do iret=1,500
   if (data_directory(iret) == C_NULL_CHAR) exit
   data_dir(iret:iret) = data_directory(iret)
  end do
! Save wisdom and free memory
  wisfile=trim(data_dir)//'/xdft8_wisdom.dat'// C_NULL_CHAR
  iret = fftwf_export_wisdom_to_filename(wisfile)
  call four2a(a,-1,1,1,1)
  call filbig(a,-1,1,0.0,0,0,0,0,0)        !used for FFT plans
  call fftwf_cleanup_threads()
  call fftwf_cleanup()
        
end subroutine xduninitfftw3
