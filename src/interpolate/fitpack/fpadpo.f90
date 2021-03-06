subroutine fpadpo(idim, t, n, c, nc, k, cp, np, cc, t1, t2)
  !  given a idim-dimensional spline curve of degree k, in its b-spline
  !  representation ( knots t(j),j=1,...,n , b-spline coefficients c(j),
  !  j=1,...,nc) and given also a polynomial curve in its b-spline
  !  representation ( coefficients cp(j), j=1,...,np), subroutine fpadpo
  !  calculates the b-spline representation (coefficients c(j),j=1,...,nc)
  !  of the sum of the two curves.
  !
  !  other subroutine required : fpinst
  !
  !  ..
  !  ..scalar arguments..
  integer :: idim, k, n, nc, np
  !  ..array arguments..
  real(8) :: t(n), c(nc), cp(np), cc(nc), t1(n), t2(n)
  !  ..local scalars..
  integer :: i, ii, j, jj, k1, l, l1, n1, n2, nk1, nk2
  !  ..
  k1 = k + 1
  nk1 = n - k1
  !  initialization
  j = 1
  l = 1
  do jj = 1, idim
    l1 = j
    do ii = 1, k1
      cc(l1) = cp(l)
      l1 = l1 + 1
      l = l + 1
    end do
    j = j + n
    l = l + k1
  end do

  if (nk1 == k1) go to 70
  n1 = k1 * 2
  j = n
  l = n1
  do i = 1, k1
    t1(i) = t(i)
    t1(l) = t(j)
    l = l - 1
    j = j - 1
  end do

  !  find the b-spline representation of the given polynomial curve
  !  according to the given set of knots.
  nk2 = nk1 - 1
  do l = k1, nk2
    l1 = l + 1
    j = 1
    do i = 1, idim
      call fpinst(0, t1, n1, cc(j), k, t(l1), l, t2, n2, cc(j), n)
      j = j + n
    end do

    t1(:n2) = t2(:n2)
    n1 = n2
  end do

  !  find the b-spline representation of the resulting curve.
70 j = 1
  do jj = 1, idim
    l = j
    do i = 1, nk1
      c(l) = cc(l) + c(l)
      l = l + 1
    end do

    j = j + n
  end do

end subroutine fpadpo
