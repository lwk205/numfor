subroutine cualde(idim, t, n, c, nc, k1, u, d, nd, ier)
  !  subroutine cualde evaluates at the point u all the derivatives
  !                     (l)
  !     d(idim*l+j) = sj   (u) ,l=0,1,...,k, j=1,2,...,idim
  !  of a spline curve s(u) of order k1 (degree k=k1-1) and dimension idim
  !  given in its b-spline representation.
  !
  !  calling sequence:
  !     call cualde(idim,t,n,c,nc,k1,u,d,nd,ier)
  !
  !  input parameters:
  !    idim : integer, giving the dimension of the spline curve.
  !    t    : array,length n, which contains the position of the knots.
  !    n    : integer, giving the total number of knots of s(u).
  !    c    : array,length nc, which contains the b-spline coefficients.
  !    nc   : integer, giving the total number of coefficients of s(u).
  !    k1   : integer, giving the order of s(u) (order=degree+1).
  !    u    : real, which contains the point where the derivatives must
  !           be evaluated.
  !    nd   : integer, giving the dimension of the array d. nd >= k1*idim
  !
  !  output parameters:
  !    d    : array,length nd,giving the different curve derivatives.
  !           d(idim*l+j) will contain the j-th coordinate of the l-th
  !           derivative of the curve at the point u.
  !    ier  : error flag
  !      ier = 0 : normal return
  !      ier =10 : invalid input data (see restrictions)
  !
  !  restrictions:
  !    nd >= k1*idim
  !    t(k1) <= u <= t(n-k1+1)
  !
  !  further comments:
  !    if u coincides with a knot, right derivatives are computed
  !    ( left derivatives if u = t(n-k1+1) ).
  !
  !  other subroutines required: fpader.
  !
  !  references :
  !    de boor c : on calculating with b-splines, j. approximation theory
  !                6 (1972) 50-62.
  !    cox m.g.  : the numerical evaluation of b-splines, j. inst. maths
  !                applics 10 (1972) 134-149.
  !    dierckx p. : curve and surface fitting with splines, monographs on
  !                 numerical analysis, oxford university press, 1993.
  !
  !  author :
  !    p.dierckx
  !    dept. computer science, k.u.leuven
  !    celestijnenlaan 200a, b-3001 heverlee, belgium.
  !    e-mail : Paul.Dierckx@cs.kuleuven.ac.be
  !
  !  latest update : march 1987
  !
  !  ..scalar arguments..
  integer :: idim, n, nc, k1, nd, ier
  real(8) :: u
  !  ..array arguments..
  real(8) :: t(n), c(nc), d(nd)
  !  ..local scalars..
  integer :: i, j, kk, l, m, nk1
  !  ..local array..
  real(8) :: h(6)
  !  ..
  !  before starting computations a data check is made. if the input data
  !  are invalid control is immediately repassed to the calling program.
  ier = 10
  if (nd < (k1 * idim)) return
  nk1 = n - k1
  if (u < t(k1) .or. u > t(nk1 + 1)) return
  !  search for knot interval t(l) <= u < t(l+1)
  l = k1
100 if (u < t(l + 1) .or. l == nk1) go to 200
  l = l + 1
  go to 100
200 if (t(l) >= t(l + 1)) return
  ier = 0
  !  calculate the derivatives.
  j = 1
  do i = 1, idim
    call fpader(t, n, c(j), k1, u, l, h)
    m = i
    do kk = 1, k1
      d(m) = h(kk)
      m = m + idim
    end do

    j = j + n
  end do

end subroutine cualde
