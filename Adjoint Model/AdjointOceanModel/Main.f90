!  AdjointOceanModel.f90 
!
!  FUNCTIONS:
!  AdjointOceanModel - Entry point of console application.
!

!****************************************************************************
!
!  PROGRAM: AdjointOceanModel
!
!  PURPOSE:  Entry point for the console application.
!
!****************************************************************************
    program AdjointOceanModel
    use Const
    use Ocean_Model
    use Adjoint_Model
    
    ! read constants and parameters
    call Const_init
    call Ocean_Model_allocate
    call Adjoint_Model_allocate
    
    ! ������Ż����߽硢��Ħ����˵��Ҫ��������ģʽ
    if ( (.not. optOpenBoundary) .and. (.not. optFrictionData) ) then
        write(*, *) "Now running the 2-D forward simulation."
        call Ocean_Model_Run
        ! ���ͷ���
        call Harmonic
        ! �����������ĵ��ͳ���
        call dump2D(simZeta, 'Zeta.dat')
        call dump2D(simSigma, 'Sigma.dat')
        ! ���ˮλ�������仯
        call dump3D(H, 'H.dat')
        call dump3D(U, 'U.dat')
        call dump3D(V, 'V.dat')
    else
        write(*, *) "Now running the adjoint optimization."
        call Adjoint_Model_Run
        if ( optOpenBoundary ) then
            ! ע�������Ż�����A��B�����ǿ��߽������
            call dump2D(Tide_A, 'A.dat')
            call dump2D(Tide_B, 'B.dat')
            ! ע�����������ٽ����������ģ�������
            call dump2D(simZeta, 'Zeta.dat')
            call dump2D(simSigma, 'Sigma.dat')
            ! ע������Ĺ۲����ģ��ֵ֮����ֻ�ڹ۲���ϵ�
            call dump2D(diffZeta, 'diffZeta.dat')
            call dump2D(diffSigma, 'diffSigma.dat')
        end if
        if ( optFrictionData ) then
            ! ע����������ĵ�Ħ�������������������
            call dump2D(Friction, 'Friction.dat')
        end if
    endif
    
    end program AdjointOceanModel
