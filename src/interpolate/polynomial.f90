!> @file polynomial.f90
!! @date "2019-08-27 13:59:25"

!> polynomials provides a framework for simple (and quite naive) work with polynomials
!! It allows to easily evaluate, derivate, and integrate a polynomial
!! Examples:
!!
!!```
!! real(dp), dimension(5) :: p1
!! p1 = arange(5, 1, -1)
!! print "(A)", Evaluations
!! print "(f0.0)", polyval(p1, -1._dp)  ! gives 3.
!! print "(f0.0)", polyval(p1, 0._dp)   ! gives 1
!! print "(f0.0)", polyval(p1, 1._dp)   ! gives 15
!! print "(3(f0.0,1x))", polyval(p1, [-1._dp, 0._dp, 1._dp]) ! gives 3.,1.,15.
!!
!! print "(A)", Derivatives
!! print "(3(f0.0,1x))", polyval(polyder(p1, 1), [-1._dp, 0._dp, 1._dp])
!! print "(3(f0.0,1x))", polyval(polyder(p1, 2), [-1._dp, 0._dp, 1._dp])
!! print "(3(f0.0,1x))", polyval(polyder(p1, 3), [-1._dp, 0._dp, 1._dp])
!! ! gives as a result:
!! !   -12. 2. 40.
!! !    42. 6. 90.
!! !   -96. 24. 144.
!!
!! print "(A)", Integrals
!! print "(3(f0.0,1x))", polyval(polyint(p1, 1), [-1._dp, 0._dp, 1._dp])
!! ! gives:
!! !       -1. 0. 5.
!! !
!! ```
module polynomial

  USE basic, only: dp, Zero, print_msg

  !> polyval Computes the value of the polynomial when applied to a number or list of numbers
  !!
  !! Examples:
  !!
  !!```
  !! real(dp), dimension(5) :: p1
  !! p1 = arange(5, 1, -1)
  !!
  !! print "(f0.0)", polyval(p1, -1._dp)  ! gives 3.
  !! print "(f0.0)", polyval(p1, 0._dp)   ! gives 1
  !! print "(f0.0)", polyval(p1, 1._dp)   ! gives 15
  !! print "(3(f0.0,1x))", polyval(p1, [-1._dp, 0._dp, 1._dp]) ! gives 3.,1.,15.
  !! !
  !! ```
  interface polyval
    module procedure :: polyval_1, polyval_v
  end interface polyval

  private
  public polyval, polyder, polyint

contains

  !> Evaluation of a polynomial in a number
  pure function polyval_1(p, x) result(y)
    implicit none
    real(dp) :: y               !< Value of polynomial evaluated in x
    real(dp), dimension(:), intent(IN) :: p !< Array of coefficients, from highest degree to constant term
    real(dp), intent(IN) :: x !< A number at which to evaluate the polynomial
    integer :: i

    y = p(1)
    do i = 2, size(p)
      y = y * x + p(i)
    end do

  end function polyval_1

  !> Evaluation of a polynomial in an array of numbers
  pure function polyval_v(p, x) result(y)
    implicit none
    real(dp), dimension(:), intent(IN) :: p !< Array of coefficients, from highest degree to constant term
    real(dp), dimension(:), intent(IN) :: x !< A number at which to evaluate the polynomial
    real(dp), dimension(size(x)) :: y !< Polynomial evaluated in x
    integer :: i, j

    y = p(1)
    do j = 1, size(x)
      do i = 2, size(p)
        y(j) = y(j) * x(j) + p(i)
      end do
    end do
  end function polyval_v

  !> polyder Computes the derivative of a polynomial. Returns an array with the coefficients
  !!
  !! Examples:
  !!```
  !! real(dp), dimension(5) :: p1
  !! p1 = arange(5, 1, -1)
  !!
  !! print "(3(f0.0,1x))", polyval(polyder(p1, 1), [-1._dp, 0._dp, 1._dp])
  !! print "(3(f0.0,1x))", polyval(polyder(p1, 2), [-1._dp, 0._dp, 1._dp])
  !! print "(3(f0.0,1x))", polyval(polyder(p1, 3), [-1._dp, 0._dp, 1._dp])
  !! ! gives as a result:
  !! !   -12. 2. 40.
  !! !    42. 6. 90.
  !! !   -96. 24. 144.
  !! !
  !! ```
  function polyder(p, m) result(Pd)
    implicit none
    real(dp), dimension(:), intent(IN) :: p !<
    integer, optional, intent(IN) :: m !<
    real(dp), dimension(:), allocatable :: Pd !<
    integer :: m_
    integer :: i, k, n
    integer :: order

    m_ = 1; IF (present(m)) m_ = m
    IF (m_ < 0) call print_msg('Order of derivative must be positive', errcode=0)

    if (m_ == 0) then           ! Return the original polynomial
      Pd = p
      return
    end if

    if (size(p) - m_ < 0) then  ! Return the null polynomial
      allocate (Pd(1))
      Pd = Zero
      return
    end if

    order = size(p) - m_      ! Number of term of resulting polynomial
    allocate (Pd(order)); Pd = p(:order)

    morder: do k = 0, m_ - 1
      n = size(p) - k
      do i = 1, order
        Pd(i) = (n - i) * Pd(i)
      end do
    end do morder
  end function polyder

  !> polyint Computes m-esima antiderivative
  !!
  !! Examples:
  !!```
  !! real(dp), dimension(5) :: p1
  !! p1 = arange(5, 1, -1)
  !!
  !! print "(3(f0.0,1x))", polyval(polyint(p1, 1), [-1._dp, 0._dp, 1._dp])
  !! !
  !! ! gives:
  !! !       -1. 0. 5.
  !! !
  !!```
  function polyint(p, m, k) result(p_I)
    implicit none
    real(dp), dimension(:), intent(IN) :: p !<
    integer, optional, intent(IN) :: m !<
    real(dp), optional, intent(IN) :: k !<
    real(dp), dimension(:), allocatable :: p_I !<
    integer :: m_
    real(dp) :: k_
    integer :: i, j, n
    integer :: order

    m_ = 1; IF (present(m)) m_ = m
    IF (m_ < 0) call print_msg('Order of derivative must be positive', errcode=0)

    k_ = Zero; IF (present(k)) k_ = k

    if (m_ == 0) then           ! Return the original polynomial
      p_I = p
      return
    end if

    order = size(p) + m_      ! Number of term of resulting polynomial
    allocate (p_I(order)); p_I(:size(p)) = p; p_I(size(p) + 1:) = k_

    morder: do j = 1, m_
      n = size(p) + j
      do i = 1, n - 1
        P_I(i) = P_I(i) / (n - i)
      end do
    end do morder
  end function polyint

end module polynomial
! Local variables:
! eval: (add-hook 'before-save-hook 'time-stamp)
! time-stamp-start: "date[ ]+\\\\?[\"]+"
! time-stamp-format: "%:y-%02m-%02d %02H:%02M:%02S"
! End: