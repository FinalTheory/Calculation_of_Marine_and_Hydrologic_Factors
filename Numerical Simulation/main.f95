! title: ��ά������ֵģ�����
! brief: ��Fortran����Ϊ�����к�ˣ�����ʵ����ֵģ�������Լ���������Ĺ��ܣ�
!        ����������б�������Ҫ����ȷ�Ĳ�������һ��˳�������ã�����������˵����
! Author: ����
! date: 2014-05-21
! gfortran version: 4.5.2

! ��������Լ��:
! 1) ���з��ž����ܰ��չ�ʽ�е���ʽ���룻
! 2) Ӣ����ĸ����ԭ����ʽ���룻
! 3) ϣ����ĸ�ȷ�ASCII�ַ�����LaTex��д��ʾ��
! 4) ���»��ߺ�����ַ�����ʾ�½Ǳꣻ
! 5) ����������ı�����ѭJavascript���Ե���������

! ������ò���˳��Լ��:
! 1.  ˮ�������ļ���
! 2.  ���߽���ͳ��������ļ���
! 3.  x����ڵ���
! 4.  y����ڵ���
! 5.  ʱ�䲽��
! 6.  �ռ�ֱ��ʣ���λ:�֣�
! 7.  ������ʱ�䣨��λ:�룩
! 8.  �Ƿ�����ƽ���0��ʾ��1��ʾ�ǣ�
! 9.  �Ƿ�����ճ���0��ʾ��1��ʾ�ǣ�
! 10. �Ƿ������Ħ����0��ʾ��1��ʾ�ǣ�
! 11. �Ƿ�ʹ�ÿ�����������0��ʾ��1��ʾ������������2��ʾ�ɱ��������
! 12. �Ƿ�ʹ������γ�ȱ仯��x����ռ䲽����0��ʾ��1��ʾ�ǣ�
! 13. ����ճ��ϵ��
! 14. ��Ħ��ϵ��
! 15. �������Բ�ָ�ʽ��ϵ����
! 16. ģ������ĵײ���Ӧγ��
! 17. ����ļ��ı��

module constants
    implicit none

    !--------------------�����趨����--------------------
    ! �����쳣ֵ
    real(kind=8), parameter :: invalid = -1.1d6
    ! ��ֵģ�������������
    integer, parameter :: maxLoops = 30
    ! �������ȿ��Ʊ������������ȿ��Ʊ�����������
    real(kind=8), parameter :: eps = 1d-3, epsZero = 1e-4, PI = 3.14159265358979323846d0, conv = PI / 180.d0
    ! ����뾶���ף�����ת���ٶȣ�rad/s�����������ٶ�(m/s^2)
    real(kind=8), parameter :: earthRadius = 6378.1d3, Omega = 2.d0 * PI / ( 24.d0 * 3600.d0 ), g = 9.8d0
    ! ʱ�䲽��ΪnumSteps�����߽�ڵ�����ΪnumOpenNodes
    integer :: numX, numY, numSteps, numOpenNodes

    !--------------------�����������--------------------

    ! ����ռ���С�ֱ����Լ��о�����ױߵ�γ��
    real(kind=8) :: resolution, latitude
    ! ����ʱ�䲽������ϫ���������ܳ��ȡ���ϫ���ٶȵȲ���
    real(kind=8) :: delta_t, T, w
    ! ����ճ��ϵ������Ħ��ϵ�����������Ը�ʽ�Ŀ���ϵ��
    real(kind=8) :: A, K, alpha
    ! ���忪�߽��ϵĵ��ͳ�����ˮ������h
    real(kind=8), allocatable :: Boundary(:, :), h(:, :)

    !--------------------���в�������--------------------

    ! �趨�Ƿ�����ƽ���ճ�����Ħ����������
    integer :: enableAdvection, enableViscosity, enableFriction, enableCoriolisForce
    ! �趨�Ƿ�ʹ���Զ��仯��x����ռ䲽����
    integer :: autoXStep
    ! �ļ����
    integer :: fileidx

    !--------------------��ʱ��������--------------------

    integer :: n, i, j, idx

    contains

    subroutine parseParameters()
        implicit none
        integer :: ioStatus = 0
        character(len=80) :: buf, name1, name2

        if ( iargc() /= 17 ) then
            write(*, *) 'Not enough input parameters!'
            call exit(-1)
        end if

        call getarg(1, buf)
        read(buf, *) name1
        call getarg(2, buf)
        read(buf, *) name2
        call getarg(3, buf)
        read(buf, *) numX
        call getarg(4, buf)
        read(buf, *) numY
        call getarg(5, buf)
        read(buf, *) numSteps
        call getarg(6, buf)
        read(buf, *) resolution
        ! �ֱ�����"��"ת����"��"
        resolution = resolution / 60.d0
        call getarg(7, buf)
        read(buf, *) T
        ! ����ֳ����ٶ�
        w = 2.d0 * PI / T
        call getarg(8, buf)
        read(buf, *) enableAdvection
        call getarg(9, buf)
        read(buf, *) enableViscosity
        call getarg(10, buf)
        read(buf, *) enableFriction
        call getarg(11, buf)
        read(buf, *) enableCoriolisForce
        call getarg(12, buf)
        read(buf, *) autoXStep
        call getarg(13, buf)
        read(buf, *) A
        call getarg(14, buf)
        read(buf, *) K
        call getarg(15, buf)
        read(buf, *) alpha
        call getarg(16, buf)
        read(buf, *) latitude
        call getarg(17, buf)
        read(buf, *) fileidx

        ! ��ջ�ڴ��Ϸ������ݿռ�
        allocate(h(numX, numY))
        allocate(Boundary(numX*numY, 4))

        delta_t = T / numSteps

        ! ����ˮ�����ݺͿ��߽�����
        open(11, file = name1, action = 'read')
        open(12, file = name2, action = 'read')
        read(11, *) ( h(:, j), j = numY, 1, -1 )
        i = 1
        do while ( .true. )
            read(12, *, iostat = ioStatus) Boundary(i, :)
            if ( ioStatus /= 0 ) exit
            i = i + 1
        end do
        numOpenNodes = i - 1
        close(11)
        close(12)

    end subroutine

end module

module calculate
    use constants
    implicit none

    !--------------------���ݷ��䲿��--------------------

    ! ���庣�沨��������u��v
    real(kind=8), allocatable :: u(:, :, :), v(:, :, :), zeta(:, :, :)
    ! ������ά�Ȳ�ͬ�������仯��x����ռ䲽�����̶���y����ռ䲽��������������
    real(kind=8), allocatable :: delta_x(:), delta_y, f(:)
    ! ���忪�߽��ϵĵ��ͳ��������Լ�ˮλ����
    real(kind=8), allocatable :: boundaryWaterLevel(:, :, :)
    ! ����������������Լ�����u��v������
    integer, allocatable :: mask(:, :), ctrlU(:, :), ctrlV(:, :)
    ! ��¼�������ϵ���Լ��Ҳ���ֵ��ƽ���ٶȵ���ʱ����
    real(kind=8) :: equalLeft, equalRight, temp, u_aver, v_aver

    contains

    ! ������һ�������б߽������ϵ�ˮλ���
    subroutine calculateBoundary()
        implicit none
        ! ������ǿ�ȵ�ǰ����λ
        real(kind=8) :: curPhase

        boundaryWaterLevel = 0.d0

        do n = 1, numSteps + 1
            do idx = 1, numOpenNodes
                curPhase = w * ( n - 1 ) * delta_t
                i = int(Boundary(idx, 1) + epsZero)
                j = int(Boundary(idx, 2) + epsZero)
                boundaryWaterLevel(i, j, n) = Boundary(idx, 3) * dcos(curPhase) + Boundary(idx, 4) * dsin(curPhase)
                ! write(*, *) boundaryWaterLevel(i, j, n)
            end do
        end do

    end subroutine

    subroutine initData()
        implicit none
        real(kind=8) :: theta

        allocate(f(numY))
        allocate(delta_x(numY))
        allocate(mask(numX, numY))
        allocate(ctrlU(numX, numY))
        allocate(ctrlV(numX, numY))
        allocate(u(numX, numY, numSteps + 1))
        allocate(v(numX, numY, numSteps + 1))
        allocate(zeta(numX, numY, numSteps + 1))
        allocate(boundaryWaterLevel(numX, numY, numSteps + 2))

        ! ��ʼγ��ѡȡΪģ���������λ��
        theta = ( numY / 2 * resolution + latitude ) * conv
        delta_y = 2.d0 * PI * earthRadius * resolution / 360.d0
        delta_x(:) = dcos(theta) * delta_y
        if ( enableCoriolisForce == 0 ) then
            f(:) = 0.d0
        else if ( enableCoriolisForce == 1 ) then
            f(:) = 2.d0 * Omega * dsin(theta)
        end if

        if ( autoXStep /= 0 ) then
            theta = ( resolution / 2.d0 + latitude ) * conv
            do j = 1, numY
                delta_x(j) = dcos(theta) * delta_y
                theta = theta + resolution * conv
            end do
        end if

        if ( enableCoriolisForce == 2 ) then
            theta = ( resolution / 2.d0 + latitude ) * conv
            do j = 1, numY
                f(j) = 2.d0 * Omega * dsin(theta)
                theta = theta + resolution * conv
            end do
        end if

        ! ����ˮ���mask
        where ( h > epsZero )
            mask = 1
        elsewhere
            mask = 0
        endwhere

        ! ǿ����߽�������Ϊ1
        do idx = 1, numOpenNodes
            ! �����������
            i = int(Boundary(idx, 1) + epsZero)
            j = int(Boundary(idx, 2) + epsZero)
            mask(i, j) = 5
        end do

        ! ������������
        ctrlU = 1
        ctrlV = 1
        do j = 1, numY
            do i = 1, numX
                if ( mask(i, j) == 0 .or. mask(i + 1, j) == 0 ) ctrlU(i, j) = 0
                if ( mask(i, j) == 0 .or. mask(i, j + 1) == 0 ) ctrlV(i, j) = 0
            end do
        end do

!        write(*, *) f
!        write(*, *) delta_x
!        write(*, *) delta_t
!        write(*, *) resolution, latitude
!        write(*, *) numX, numY, numSteps, numOpenNodes
!        write(*, *) Boundary(:, :)

        call calculateBoundary()

        ! ��ˮλ�����ٳ�ʼ��Ϊ��
        ! ������ʼʱ�̵�ˮλ��ʼ��Ϊ���߽�ˮλ
        u = 0.d0
        v = 0.d0
        zeta = 0.d0
        zeta(:, :, numSteps + 1) = boundaryWaterLevel(:, :, 1)

    end subroutine

    ! ���ݵ�ǰ��������һ����ˮλ
    subroutine calculateZeta(curStep)
        implicit none
        integer :: curStep
        real(kind=8) :: h_r, h_l, h_u, h_d

        do j = 1, numY
            do i = 1, numX
                ! �ж����λ���Ƿ���Ҫ����ˮλ���Լ��Ƿ�Ϊ���߽�
                if ( mask(i, j) == 0 ) then
                    zeta(i, j, curStep + 1) = 0.d0
                    cycle
                else if ( mask(i, j) == 5 ) then
                    zeta(i, j, curStep + 1) = boundaryWaterLevel(i, j, curStep + 1)
                    cycle
                end if

                h_r = ( h(i, j) + h(i + 1, j) + zeta(i, j, curStep) + zeta(i + 1, j, curStep) ) * 0.5d0
                h_l = ( h(i, j) + h(i - 1, j) + zeta(i, j, curStep) + zeta(i - 1, j, curStep) ) * 0.5d0
                h_u = ( h(i, j) + h(i, j + 1) + zeta(i, j, curStep) + zeta(i, j + 1, curStep) ) * 0.5d0
                h_d = ( h(i, j) + h(i, j - 1) + zeta(i, j, curStep) + zeta(i, j - 1, curStep) ) * 0.5d0

                zeta(i, j, curStep + 1) = zeta(i, j, curStep) - delta_t * &
                ( ( h_r * u(i, j, curStep) - h_l * u(i-1, j, curStep) ) / delta_x(j) + &
                ( h_u * v(i, j, curStep) - h_d * v(i, j-1, curStep) ) / delta_y )
            end do
        end do
    end subroutine

    ! ���ݲ���������һʱ�䲽��u
    ! ���������ֱ����ǰʱ����ţ����Ƴ���һ����������ʱ��������v��ʱ�����
    subroutine calculateU(curStep, relyOnStep)
        implicit none
        integer :: curStep, relyOnStep

        do j = 1, numY
            do i = 1, numX
                if ( ctrlU(i, j) == 0 ) then
                    u(i, j, curStep + 1) = 0.d0
                    cycle
                end if

                v_aver = ( v(i, j, relyOnStep) + v(i + 1, j, relyOnStep) + &
                v(i, j - 1, relyOnStep) + v(i + 1, j - 1, relyOnStep) ) / &
                max(dble(ctrlV(i, j) + ctrlV(i + 1, j) + ctrlV(i, j - 1) + ctrlV(i + 1, j - 1)), 1.d0)

                ! ��ʼ����������
                equalLeft = 1.d0 / delta_t
                equalRight = u(i, j, curStep) / delta_t - g * ( zeta(i + 1, j, curStep + 1) - zeta(i, j, curStep + 1) ) / delta_x(j)

                ! ���������
                if ( enableCoriolisForce /= 0 ) then
                    equalRight = equalRight + f(j) * v_aver
                end if

                ! ���������
                if ( enableViscosity /= 0 ) then
                    equalRight = equalRight + A * ( ( u(i + 1, j, curStep) - 2 * u(i, j, curStep) + u(i - 1, j, curStep) ) &
                    / delta_x(j)**2 + ( u(i, j + 1, curStep) - 2 * u(i, j, curStep) + u(i, j - 1, curStep) ) / delta_y**2 )
                end if

                ! ����ƽ����
                if ( enableAdvection /= 0 ) then
                    equalRight = equalRight - u(i, j, curStep) * ( u(i + 1, j, curStep) - u(i - 1, j, curStep) ) &
                    / delta_x(j) / 2.d0 - v_aver * ( u(i, j + 1, curStep) - u(i, j - 1, curStep) ) / delta_y / 2.d0
                end if

                ! �����Ħ��
                if ( enableFriction /= 0 ) then
                    temp = 2.d0 * K * dsqrt( u(i, j, curStep)**2 + v_aver**2 ) / ( h(i, j) + h(i + 1, j) + &
                    zeta(i, j, curStep) + zeta(i + 1, j, curStep) )
                    equalLeft = equalLeft + ( 1.d0 - alpha ) * temp
                    equalRight = equalRight - temp * alpha * u(i, j, curStep)
                end if
                u(i, j, curStep + 1) = equalRight / equalLeft
            end do
        end do
    end subroutine

    subroutine calculateV(curStep, relyOnStep)
        implicit none
        integer :: curStep, relyOnStep

        do j = 1, numY
            do i = 1, numX
                if ( ctrlV(i, j) == 0 ) then
                    v(i, j, curStep + 1) = 0.d0
                    cycle
                end if

                u_aver = ( u(i, j, relyOnStep) + u(i, j + 1, relyOnStep) + &
                u(i - 1, j, relyOnStep) + u(i - 1, j + 1, relyOnStep) ) / &
                max(dble(ctrlU(i, j) + ctrlU(i, j + 1) + ctrlU(i - 1, j) + ctrlU(i - 1, j + 1)), 1.d0)

                ! ��ʼ����������
                equalLeft = 1.d0 / delta_t
                equalRight = v(i, j, curStep) / delta_t - g * ( zeta(i, j + 1, curStep + 1) - zeta(i, j, curStep + 1) ) / delta_y

                ! ���������
                if ( enableCoriolisForce /= 0 ) then
                    equalRight = equalRight - f(j) * u_aver
                end if

                ! ���������
                if ( enableViscosity /= 0 ) then
                    equalRight = equalRight + A * ( ( v(i + 1, j, curStep) - 2 * v(i, j, curStep) + v(i - 1, j, curStep) ) &
                    / delta_x(j)**2 + ( v(i, j + 1, curStep) - 2 * v(i, j, curStep) + v(i, j - 1, curStep) ) / delta_y**2 )
                end if

                ! ����ƽ����
                if ( enableAdvection /= 0 ) then
                    equalRight = equalRight - u_aver * ( v(i + 1, j, curStep) - v(i - 1, j, curStep) ) / delta_x(j) / 2.d0 &
                    - v(i, j, curStep) * ( v(i, j + 1, curStep) - v(i, j - 1, curStep) ) / delta_y / 2.d0
                end if

                ! �����Ħ��
                if ( enableFriction /= 0 ) then
                    temp = 2.d0 * K * dsqrt( v(i, j, curStep)**2 + u_aver**2 ) / ( h(i, j) + h(i, j + 1) + &
                    zeta(i, j, curStep) + zeta(i, j + 1, curStep) )
                    equalLeft = equalLeft + ( 1.d0 - alpha ) * temp
                    equalRight = equalRight - temp * alpha * v(i, j, curStep)
                end if
                v(i, j, curStep + 1) = equalRight / equalLeft
            end do
        end do
    end subroutine

    ! ������ͳ��������
    subroutine outputHarmonic()
        implicit none
        character(len = 80) :: str, filename1, filename2
        real(kind=8), dimension(numX, numY) :: harmonicA, harmonicB, amplitude, arg

        write(str, '(I3.3)') fileidx
        filename1 = 'output_Amplitude_' // trim(str) // '.txt'
        filename2 = 'output_Arg_' // trim(str) // '.txt'
        write(str, '(I0)') numX

        harmonicA = 0.d0
        harmonicB = 0.d0

        do n = 1, numSteps
            do j = 1, numY
                do i = 1, numX
                    harmonicA(i, j) = harmonicA(i, j) + zeta(i, j, n) * dcos(w*(n-1)*delta_t)
                    harmonicB(i, j) = harmonicB(i, j) + zeta(i, j, n) * dsin(w*(n-1)*delta_t)
                end do
            end do
        end do

        harmonicA = harmonicA / dble(numSteps) * 2.d0
        harmonicB = harmonicB / dble(numSteps) * 2.d0

        do j = 1, numY
            do i = 1, numX
                amplitude(i, j) = dsqrt(harmonicA(i, j)**2 + harmonicB(i, j)**2)
                ! �ж��Ƿ����޳���
                if ( amplitude(i, j) < epsZero ) then
                    arg(i, j) = invalid
                ! �ж��Ƿ���X��������
                else if ( dabs(harmonicB(i, j)) < epsZero .and. harmonicA(i, j) >  amplitude(i, j) - epsZero ) then
                    arg(i, j) = 0.d0
                ! �ж��Ƿ���X�Ḻ����
                else if ( dabs(harmonicB(i, j)) < epsZero .and. harmonicA(i, j) < -amplitude(i, j) + epsZero ) then
                    arg(i, j) = PI
                ! �ж��Ƿ���Y��������
                else if ( dabs(harmonicA(i, j)) < epsZero .and. harmonicB(i, j) <  amplitude(i, j) - epsZero ) then
                    arg(i, j) = PI / 2.d0
                ! �ж��Ƿ���Y�Ḻ����
                else if ( dabs(harmonicA(i, j)) < epsZero .and. harmonicB(i, j) < -amplitude(i, j) + epsZero ) then
                    arg(i, j) = PI / 2.d0 * 3.d0
                ! �ж��Ƿ��ǵ�һ����
                else if ( harmonicB(i, j) > 0.d0 .and. harmonicA(i, j) > 0.d0 ) then
                    arg(i, j) = datan(harmonicB(i, j) / harmonicA(i, j))
                ! �ж��Ƿ��ǵڶ�����
                else if ( harmonicB(i, j) > 0.d0 .and. harmonicA(i, j) < 0.d0 ) then
                    arg(i, j) = datan(harmonicB(i, j) / harmonicA(i, j)) + PI
                ! �ж��Ƿ��ǵ�������
                else if ( harmonicB(i, j) < 0.d0 .and. harmonicA(i, j) < 0.d0 ) then
                    arg(i, j) = datan(harmonicB(i, j) / harmonicA(i, j)) + PI
                ! �ж��Ƿ��ǵ�������
                else if ( harmonicB(i, j) < 0.d0 .and. harmonicA(i, j) > 0.d0 ) then
                    arg(i, j) = datan(harmonicB(i, j) / harmonicA(i, j))
                end if
            end do
        end do

        arg = arg / PI * 180.d0

        do j = 1, numY
            do i = 1, numX
                if ( mask(i, j) == 0 ) then
                    amplitude(i, j) = invalid
                    arg(i, j) = invalid
                end if
            end do
        end do

        open(14, file = filename1, status = 'replace', action = 'write')
        do j = numY, 1, -1
            write(14, '(' // str // '(1X, F15.6))') ( amplitude(i, j), i = 1, numX )
        end do
        close(14)
        open(14, file = filename2, status = 'replace', action = 'write')
        do j = numY, 1, -1
            write(14, '(' // str // '(1X, F15.6))') ( arg(i, j), i = 1, numX )
        end do
        close(14)

    end subroutine

end module

subroutine outputData( filename, matrix, numX, numY, numSteps )
    implicit none
    integer :: i, j, n, numX, numY, numSteps
    real(kind=8) :: matrix(numX, numY, numSteps)
    character(len = 80) :: filename, str
    write(str, '(I0)') numX

    open(13, file = filename, status = 'replace', action = 'write')

    do n = 1, numSteps
        do j = numY, 1, -1
            write(13, '(' // str // '(1X, F15.6))') ( matrix(i, j, n), i = 1, numX )
        end do
    end do

    close(13)

end subroutine

program TideModeling
    use calculate
    implicit none
    integer :: loopCounter
    ! ����������ȿ��Ʊ���
    real(kind=8) :: accuracy
    character(len=80) :: filename, str

    call parseParameters()
    call initData()

    do loopCounter = 1, maxLoops

        ! ����һ�����ڵĽ���״̬��ֵ����ǰ���ڵ���ʼ״̬
        u(:, :, 1) = u(:, :, numSteps + 1)
        v(:, :, 1) = v(:, :, numSteps + 1)
        zeta(:, :, 1) = zeta(:, :, numSteps + 1)

        ! ��ʼ�����ڵ�ģ��
        do n = 1, numSteps - 1, 2
            call calculateZeta(n)
            call calculateV(n, n)
            call calculateU(n, n + 1)
            ! ��������
            call calculateZeta(n + 1)
            call calculateU(n + 1, n + 1)
            call calculateV(n + 1, n + 2)
        end do

        accuracy = maxval(dabs(zeta(:, :, numSteps + 1) - zeta(:, :, 1)))
        write(*, '("Current error: ", F15.6)') accuracy
        if ( accuracy < eps ) exit

    end do

    do j = 1, numY
        do i = 1, numX
            if ( ctrlU(i, j) == 0 ) u(i, j, :) = invalid
            if ( ctrlV(i, j) == 0 ) v(i, j, :) = invalid
            if ( mask(i, j) == 0 ) zeta(i, j, :) = invalid
        end do
    end do

    write(str, '(I3.3)') fileidx
    filename = 'output_U_' // trim(str) // '.txt'
    call outputData(filename, u, numX, numY, numSteps)
    filename = 'output_V_' // trim(str) // '.txt'
    call outputData(filename, v, numX, numY, numSteps)
    filename = 'output_Zeta_' // trim(str) // '.txt'
    call outputData(filename, Zeta, numX, numY, numSteps)

    ! ������ͳ��������
    call outputHarmonic()

end program
