program test
  USE utils
  ! USE fString
  ! USE strings, only: upper

  implicit none

  type(fStr) :: mystr1
  type(fStr) :: mystr2
  type(fStr) :: mystr3
  character(len=:), allocatable :: ch1
  character(len=10) :: iomsg = ' '
  integer :: i1
  ! logical :: l1

  ch1 = "NumFor - Library for Simple Numerical computing."
  mystr1 = ch1
  mystr2 = fStr(123123.e6)
  mystr3 = fStr("hola allá")
  print *, mystr1%upper()
  print *, mystr2
  print *, mystr3
  write (6, *) mystr3//mystr2
  write (6, *) mystr3//'chau'
  write (6, '(A)') mystr3       ! Esto no funciona
  call mystr3%writef(6, '(A)', [2], i1, iomsg)
  print *, "starts with 'Num'?", mystr1%startswith('Num')
  print *, "starts with 'Nume'? ", mystr1%startswith('Nume')
  print *, mystr1%reverse()
  print *, upper(str(mystr1%reverse()))
  print *, mystr1 == mystr2
  print *, ' 3 * fStr("hola") * 3 :'
  print *, '                      ', 3 * fStr("hola") * 3
  print *, len(mystr1)

  print *, mystr1%replace('Num', 'Sci')
  ! call writef(mystr2)

  print *, 'i appears ', mystr1%count('i'), 'times'
end program test
