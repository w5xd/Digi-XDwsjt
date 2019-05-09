!Copyright (c) 2019 by Wayne E. Wright, W5XD
! extracted from wsjtx jt9.f90
subroutine xdinitfftw3(data_directory)
  use FFTW3
 use iso_c_binding, only: C_CHAR, C_NULL_CHAR
 
  character(kind=C_CHAR, len=1), dimension(*), intent(in) :: data_directory
  character(len=500) :: data_dir
  character wisfile*80
  integer(C_INT) iret
  data_dir = " ";
  do iret=1,500
   if (data_directory(iret) == C_NULL_CHAR) exit
   data_dir(iret:iret) = data_directory(iret)
  end do

  iret = fftwf_init_threads()            !Initialize FFTW threading 
! Default to 1 thread, but use nthreads for the big ones
  call fftwf_plan_with_nthreads(1)

! Import FFTW wisdom, if available
  wisfile=trim(data_dir)//'/xdft8_wisdom.dat'// C_NULL_CHAR
  iret = fftwf_import_wisdom_from_filename(wisfile)
end subroutine xdinitfftw3  
