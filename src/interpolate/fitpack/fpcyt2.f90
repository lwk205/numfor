subroutine fpcyt2(a, n, b, c, nn)
  ! subroutine fpcyt2 solves a linear n x n system
  !         a * c = b
  ! where matrix a is a cyclic tridiagonal matrix, decomposed
  ! using subroutine fpsyt1.
  !  ..
  !  ..scalar arguments..
  integer :: n, nn
  !  ..array arguments..
  real(8) :: a(nn, 6), b(n), c(n)
  !  ..local scalars..
  real(8) :: cc, sum
  integer :: i, j, j1, n1
  !  ..
  c(1) = b(1) * a(1, 4)
  sum = c(1) * a(1, 5)
  n1 = n - 1
  do i = 2, n1
    c(i) = (b(i) - a(i, 1) * c(i - 1)) * a(i, 4)
    sum = sum + c(i) * a(i, 5)
  end do

  cc = (b(n) - sum) * a(n, 4)
  c(n) = cc
  c(n1) = c(n1) - cc * a(n1, 6)
  j = n1
  do i = 3, n
    j1 = j - 1
    c(j1) = c(j1) - c(j) * a(j1, 3) * a(j1, 4) - cc * a(j1, 6)
    j = j1
  end do

end subroutine fpcyt2
