subroutine fpopsp(ifsu, ifsv, ifbu, ifbv, u, mu, v, mv, r, mr, r0, r1, dr,&
  &iopt, ider, tu, nu, tv, nv, nuest, nvest, p, step, c, nc, fp, fpu, fpv,&
  &nru, nrv, wrk, lwrk)
  !  given the set of function values r(i,j) defined on the rectangular
  !  grid (u(i),v(j)),i=1,2,...,mu;j=1,2,...,mv, fpopsp determines a
  !  smooth bicubic spline approximation with given knots tu(i),i=1,..,nu
  !  in the u-direction and tv(j),j=1,2,...,nv in the v-direction. this
  !  spline sp(u,v) will be periodic in the variable v and will satisfy
  !  the following constraints
  !
  !     s(tu(1),v) = dr(1) , tv(4) <=v<= tv(nv-3)
  !
  !     s(tu(nu),v) = dr(4) , tv(4) <=v<= tv(nv-3)
  !
  !  and (if iopt(2) = 1)
  !
  !     d s(tu(1),v)
  !     ------------ =  dr(2)*cos(v)+dr(3)*sin(v) , tv(4) <=v<= tv(nv-3)
  !     d u
  !
  !  and (if iopt(3) = 1)
  !
  !     d s(tu(nu),v)
  !     ------------- =  dr(5)*cos(v)+dr(6)*sin(v) , tv(4) <=v<= tv(nv-3)
  !     d u
  !
  !  where the parameters dr(i) correspond to the derivative values at the
  !  poles as defined in subroutine spgrid.
  !
  !  the b-spline coefficients of sp(u,v) are determined as the least-
  !  squares solution  of an overdetermined linear system which depends
  !  on the value of p and on the values dr(i),i=1,...,6. the correspond-
  !  ing sum of squared residuals sq is a simple quadratic function in
  !  the variables dr(i). these may or may not be provided. the values
  !  dr(i) which are not given will be determined so as to minimize the
  !  resulting sum of squared residuals sq. in that case the user must
  !  provide some initial guess dr(i) and some estimate (dr(i)-step,
  !  dr(i)+step) of the range of possible values for these latter.
  !
  !  sp(u,v) also depends on the parameter p (p>0) in such a way that
  !    - if p tends to infinity, sp(u,v) becomes the least-squares spline
  !      with given knots, satisfying the constraints.
  !    - if p tends to zero, sp(u,v) becomes the least-squares polynomial,
  !      satisfying the constraints.
  !    - the function  f(p)=sumi=1,mu(sumj=1,mv((r(i,j)-sp(u(i),v(j)))**2)
  !      is continuous and strictly decreasing for p>0.
  !
  !  ..scalar arguments..
  integer :: ifsu, ifsv, ifbu, ifbv, mu, mv, mr, nu, nv, nuest, nvest,&
    &nc, lwrk
  real(8) :: r0, r1, p, fp
  !  ..array arguments..
  integer :: ider(4), nru(mu), nrv(mv), iopt(3)
  real(8) :: u(mu), v(mv), r(mr), dr(6), tu(nu), tv(nv), c(nc), fpu(nu), fpv(nv)&
    &, wrk(lwrk), step(2)
  !  ..local scalars..
  real(8) :: sq, sqq, sq0, sq1, step1, step2, three
  integer :: i, id0, iop0, iop1, i1, j, l, lau, lav1, lav2, la0, la1, lbu, lbv, lb0,&
    &lb1, lc0, lc1, lcs, lq, lri, lsu, lsv, l1, l2, mm, mvnu, number
  !  ..local arrays..
  integer :: nr(6)
  real(8) :: delta(6), drr(6), sum(6), a(6, 6), g(6)
  !  ..function references..
  integer :: max0
  !  ..subroutine references..
  !    fpgrsp,fpsysy
  !  ..
  !  set constant
  three = 3
  !  we partition the working space
  lsu = 1
  lsv = lsu + 4 * mu
  lri = lsv + 4 * mv
  mm = max0(nuest, mv + nvest)
  lq = lri + mm
  mvnu = nuest * (mv + nvest - 8)
  lau = lq + mvnu
  lav1 = lau + 5 * nuest
  lav2 = lav1 + 6 * nvest
  lbu = lav2 + 4 * nvest
  lbv = lbu + 5 * nuest
  la0 = lbv + 5 * nvest
  la1 = la0 + 2 * mv
  lb0 = la1 + 2 * mv
  lb1 = lb0 + 2 * nvest
  lc0 = lb1 + 2 * nvest
  lc1 = lc0 + nvest
  lcs = lc1 + nvest
  !  we calculate the smoothing spline sp(u,v) according to the input
  !  values dr(i),i=1,...,6.
  iop0 = iopt(2)
  iop1 = iopt(3)
  id0 = ider(1)
  id1 = ider(3)
  call fpgrsp(ifsu, ifsv, ifbu, ifbv, 0, u, mu, v, mv, r, mr, dr,&
    &iop0, iop1, tu, nu, tv, nv, p, c, nc, sq, fp, fpu, fpv, mm, mvnu,&
    &wrk(lsu), wrk(lsv), wrk(lri), wrk(lq), wrk(lau), wrk(lav1),&
    &wrk(lav2), wrk(lbu), wrk(lbv), wrk(la0), wrk(la1), wrk(lb0),&
    &wrk(lb1), wrk(lc0), wrk(lc1), wrk(lcs), nru, nrv)
  sq0 = 0.
  sq1 = 0.
  if (id0 == 0) sq0 = (r0 - dr(1))**2
  if (id1 == 0) sq1 = (r1 - dr(4))**2
  sq = sq + sq0 + sq1
  ! in case all derivative values dr(i) are given (step<=0) or in case
  ! we have spline interpolation, we accept this spline as a solution.
  if (sq <= 0.) return
  if (step(1) <= 0. .and. step(2) <= 0.) return

  drr(:6) = dr(:6)

  ! number denotes the number of derivative values dr(i) that still must
  ! be optimized. let us denote these parameters by g(j),j=1,...,number.
  number = 0
  if (id0 > 0) go to 20
  number = 1
  nr(1) = 1
  delta(1) = step(1)
20 if (iop0 == 0) go to 30
  if (ider(2) /= 0) go to 30
  step2 = step(1) * three / (tu(5) - tu(4))
  nr(number + 1) = 2
  nr(number + 2) = 3
  delta(number + 1) = step2
  delta(number + 2) = step2
  number = number + 2
30 if (id1 > 0) go to 40
  number = number + 1
  nr(number) = 4
  delta(number) = step(2)
40 if (iop1 == 0) go to 50
  if (ider(4) /= 0) go to 50
  step2 = step(2) * three / (tu(nu) - tu(nu - 4))
  nr(number + 1) = 5
  nr(number + 2) = 6
  delta(number + 1) = step2
  delta(number + 2) = step2
  number = number + 2
50 if (number == 0) return
  ! the sum of squared residulas sq is a quadratic polynomial in the
  ! parameters g(j). we determine the unknown coefficients of this
  ! polymomial by calculating (number+1)*(number+2)/2 different splines
  ! according to specific values for g(j).
  do i = 1, number
    l = nr(i)
    step1 = delta(i)
    drr(l) = dr(l) + step1
    call fpgrsp(ifsu, ifsv, ifbu, ifbv, 1, u, mu, v, mv, r, mr, drr,&
      &iop0, iop1, tu, nu, tv, nv, p, c, nc, sum(i), fp, fpu, fpv, mm, mvnu,&
      &wrk(lsu), wrk(lsv), wrk(lri), wrk(lq), wrk(lau), wrk(lav1),&
      &wrk(lav2), wrk(lbu), wrk(lbv), wrk(la0), wrk(la1), wrk(lb0),&
      &wrk(lb1), wrk(lc0), wrk(lc1), wrk(lcs), nru, nrv)
    if (id0 == 0) sq0 = (r0 - drr(1))**2
    if (id1 == 0) sq1 = (r1 - drr(4))**2
    sum(i) = sum(i) + sq0 + sq1
    drr(l) = dr(l) - step1
    call fpgrsp(ifsu, ifsv, ifbu, ifbv, 1, u, mu, v, mv, r, mr, drr,&
      &iop0, iop1, tu, nu, tv, nv, p, c, nc, sqq, fp, fpu, fpv, mm, mvnu,&
      &wrk(lsu), wrk(lsv), wrk(lri), wrk(lq), wrk(lau), wrk(lav1),&
      &wrk(lav2), wrk(lbu), wrk(lbv), wrk(la0), wrk(la1), wrk(lb0),&
      &wrk(lb1), wrk(lc0), wrk(lc1), wrk(lcs), nru, nrv)
    if (id0 == 0) sq0 = (r0 - drr(1))**2
    if (id1 == 0) sq1 = (r1 - drr(4))**2
    sqq = sqq + sq0 + sq1
    drr(l) = dr(l)
    a(i, i) = (sum(i) + sqq - sq - sq) / step1**2
    if (a(i, i) <= 0.) go to 110
    g(i) = (sqq - sum(i)) / (step1 + step1)
  end do

  if (number == 1) go to 90
  do i = 2, number
    l1 = nr(i)
    step1 = delta(i)
    drr(l1) = dr(l1) + step1
    i1 = i - 1
    do j = 1, i1
      l2 = nr(j)
      step2 = delta(j)
      drr(l2) = dr(l2) + step2
      call fpgrsp(ifsu, ifsv, ifbu, ifbv, 1, u, mu, v, mv, r, mr, drr,&
        &iop0, iop1, tu, nu, tv, nv, p, c, nc, sqq, fp, fpu, fpv, mm, mvnu,&
        &wrk(lsu), wrk(lsv), wrk(lri), wrk(lq), wrk(lau), wrk(lav1),&
        &wrk(lav2), wrk(lbu), wrk(lbv), wrk(la0), wrk(la1), wrk(lb0),&
        &wrk(lb1), wrk(lc0), wrk(lc1), wrk(lcs), nru, nrv)
      if (id0 == 0) sq0 = (r0 - drr(1))**2
      if (id1 == 0) sq1 = (r1 - drr(4))**2
      sqq = sqq + sq0 + sq1
      a(i, j) = (sq + sqq - sum(i) - sum(j)) / (step1 * step2)
      drr(l2) = dr(l2)
    end do

    drr(l1) = dr(l1)
  end do

  ! the optimal values g(j) are found as the solution of the system
  ! d (sq) / d (g(j)) = 0 , j=1,...,number.
90 call fpsysy(a, number, g)
  do i = 1, number
    l = nr(i)
    dr(l) = dr(l) + g(i)
  end do

  ! we determine the spline sp(u,v) according to the optimal values g(j).
110 call fpgrsp(ifsu, ifsv, ifbu, ifbv, 0, u, mu, v, mv, r, mr, dr,&
  &iop0, iop1, tu, nu, tv, nv, p, c, nc, sq, fp, fpu, fpv, mm, mvnu,&
  &wrk(lsu), wrk(lsv), wrk(lri), wrk(lq), wrk(lau), wrk(lav1),&
  &wrk(lav2), wrk(lbu), wrk(lbv), wrk(la0), wrk(la1), wrk(lb0),&
  &wrk(lb1), wrk(lc0), wrk(lc1), wrk(lcs), nru, nrv)
  if (id0 == 0) sq0 = (r0 - dr(1))**2
  if (id1 == 0) sq1 = (r1 - dr(4))**2
  sq = sq + sq0 + sq1
  return
end subroutine fpopsp
