subroutine analyze( P, zeta, sigma, V, f, kappa, alpha, corr, H, g, S_0, M, Q )
    implicit none
    !�������������ֳ�������ӷֳ������м�ֵ���
    integer         :: M, P, Q
    !��λ���ݣ�������ӷֳ����ٶȣ����ĳ���ǣ��������ӣ���ȹ�ϵ��
    real(kind=8)    :: zeta(M), sigma(P + Q), V(P + Q), f(P + Q), kappa(Q), alpha(Q)
    !��ӷֳ������ֳ��Ķ�Ӧ��ϵ
    integer         :: corr(Q)
    !���ֳ�����ӷֳ����м�����Ǻͦ�
    real(kind=8)    :: eta(P + Q), xi(P + Q)
    !���̵�ϵ������
    real(kind=8)    :: A(2*P + 1, 2*P + 1), b(2*P + 1), x(2*P + 1)
    !������a��b���Լ���ǰһ�ν�ı���
    real(kind=8)    :: res_a(P + Q), res_b(P + Q), res_bak_a(P), res_bak_b(P), bak_S_0
    !���ͳ���H��g���Լ�ƽ������S_0
    real(kind=8)    :: H(P + Q), g(P + Q), S_0
    !�����еļ�������
    integer         :: i, j, n, mid
    !������ʱ����
    real(kind=8)    :: A_ij, B_ij, A_0i, A_0j, F_0, F_i, G_i, m_max
    !�̶�������ֵ
    real(kind=8)    :: pi = 3.14159265358979323846d0, eps = 1d-9

!�����Ǳ���ָ����䣬���ڸ�F2PY��ȡ
!f2py intent(in,copy) P, zeta, sigma, V, f, kappa, alpha, corr
!f2py intent(out) H, g, S_0
!f2py integer,intent(hide),depend(zeta) :: M=len(zeta)
!f2py integer,intent(hide),depend(corr) :: Q=len(corr)

    !�ԦǺͦν��и�ֵ
    do i = 1, P + Q
        eta(i) = f(i) * dsin(V(i))
         xi(i) = f(i) * dcos(V(i))
    end do

    !����ӷֳ���a��b����ʼֵ������ȡ��
    res_a(P + 1:P + Q) = 0.d0
    res_b(P + 1:P + Q) = 0.d0

    !��¼ǰһ�εĽ⣬����ȷ�����ֳ��ĵ��ͳ����ı��˶��٣���ʼ��ֵΪ��
    bak_S_0 = 0.d0
    res_bak_a = 0.d0
    res_bak_b = 0.d0
    do while ( .true. )
        !�Է��������ϵ�����и�ֵ
        !Լ����ǰP��δ֪��Ϊa_i����P��δ֪��Ϊb_i�����һ��Ϊƽ������
        do i = 1, P
            A_0i = dsin(M*sigma(i)/2.d0) / dsin(sigma(i)/2.d0)
            A(i, 2*P + 1) = xi(i) * A_0i
            A(i + P, 2*P + 1) = eta(i) * A_0i
            do j = 1, P
                if ( i /= j ) then
                    A_ij = (dsin((sigma(i)-sigma(j))*M/2.d0) / dsin((sigma(i)-sigma(j))/2.d0) + &
                            dsin((sigma(i)+sigma(j))*M/2.d0) / dsin((sigma(i)+sigma(j))/2.d0)) / 2.d0
                    B_ij = (dsin((sigma(i)-sigma(j))*M/2.d0) / dsin((sigma(i)-sigma(j))/2.d0) - &
                            dsin((sigma(i)+sigma(j))*M/2.d0) / dsin((sigma(i)+sigma(j))/2.d0)) / 2.d0
                else
                    A_ij = ( M + dsin(M*sigma(i)) / dsin(sigma(i)) ) / 2.d0
                    B_ij = ( M - dsin(M*sigma(i)) / dsin(sigma(i)) ) / 2.d0
                end if
                A(i, j)         = xi(i) * xi(j) * A_ij + eta(i) * eta(j) * B_ij
                A(i, j + P)     = xi(i) * eta(j) * A_ij - eta(i) * xi(j) * B_ij
                A(i + P, j)     = eta(i) * xi(j) * A_ij - xi(i) * eta(j) * B_ij
                A(i + P, j + P) = eta(i) * eta(j) * A_ij + xi(i) * xi(j) * B_ij
            end do
        end do

        do j = 1, P
            A_0j = dsin(M*sigma(j)/2.d0) / dsin(sigma(j)/2.d0)
            A(2*P + 1, j) = xi(j) * A_0j
            A(2*P + 1, j + P) = eta(j) * A_0j
        end do
        A(2*P + 1, 2*P + 1) = M

        !�������ݵ��м�ֵ��������������ƫ��
        mid = ( M - 1 ) / 2 + 1

        !�Է������Ҳ���и�ֵ
        F_0 = 0.d0
        do i = 1, M
            F_0 = F_0 + zeta(i)
        end do
        do i = 1, P
            F_i = 0.d0
            G_i = 0.d0
            do n = 1, M
                F_i = F_i + zeta(n) * dcos((n - mid)*sigma(i))
                G_i = G_i + zeta(n) * dsin((n - mid)*sigma(i))
            end do
            b(i) = xi(i) * F_i - eta(i) * G_i
            b(i + P) = eta(i) * F_i + xi(i) * G_i
            do j = P + 1, P + Q
                A_ij = (dsin((sigma(i)-sigma(j))*M/2.d0) / dsin((sigma(i)-sigma(j))/2.d0) + &
                        dsin((sigma(i)+sigma(j))*M/2.d0) / dsin((sigma(i)+sigma(j))/2.d0)) / 2.d0
                B_ij = (dsin((sigma(i)-sigma(j))*M/2.d0) / dsin((sigma(i)-sigma(j))/2.d0) - &
                        dsin((sigma(i)+sigma(j))*M/2.d0) / dsin((sigma(i)+sigma(j))/2.d0)) / 2.d0
                b(i)     = b(i)     - res_a(j) * ( xi(i) * xi(j) * A_ij + eta(i) * eta(j) * B_ij ) &
                                    - res_b(j) * ( xi(i) * eta(j) * A_ij - eta(i) * xi(j) * B_ij )
                b(i + P) = b(i + P) - res_a(j) * ( eta(i) * xi(j) * A_ij - xi(i) * eta(j) * B_ij ) &
                                    - res_b(j) * ( eta(i) * eta(j) * A_ij + xi(i) * xi(j) * B_ij )
            end do
        end do
        b(2*P + 1) = F_0
        do j = P + 1, P + Q
            A_0j = dsin(M*sigma(j)/2.d0) / dsin(sigma(j)/2.d0)
            b(2*P + 1) = b(2*P + 1) - res_a(j) * xi(j) * A_0j - res_b(j) * eta(j) * A_0j
        end do

        !���ø�˹��Ԫ��ģ��������Է����飬������ǰP�ֵ��a����P�ֵ��b�����һ�ֵ��S_0
        call solve(A, b, x, 2*P + 1)
        res_a(1:P) = x(1:P)
        res_b(1:P) = x(P + 1:2 * P)
        S_0 = x(2*P + 1)

        m_max = dabs(S_0 - bak_S_0)
        do i = 1, P
            m_max = max(m_max, dabs(res_a(i) - res_bak_a(i)))
            m_max = max(m_max, dabs(res_b(i) - res_bak_b(i)))
        end do
        !��������������������˳�ѭ�������򱣴浱ǰ�Ľ�
        write(*,'("Current relative error: ", G17.9)') m_max
        if ( m_max < eps ) exit

        bak_S_0 = S_0
        res_bak_a = res_a(1:P)
        res_bak_b = res_b(1:P)

        !���ò�ȹ�ϵ������ӷֳ���a��b
        do i = 1, Q
            res_a(i + P) = kappa(i) * ( res_a(corr(i)) * dcos(alpha(i)) - &
                                        res_b(corr(i)) * dsin(alpha(i)) )
            res_b(i + P) = kappa(i) * ( res_a(corr(i)) * dsin(alpha(i)) + &
                                        res_b(corr(i)) * dcos(alpha(i)) )
        end do
    end do

    !������ͳ���
    do i = 1, P + Q
        H(i) = dsqrt(res_a(i)**2 + res_b(i)**2)
        g(i) = datan(res_b(i) / res_a(i))
        !��һ����������ʱר�óٽ�g��ȡֵ��Χ����Ϊb��sin(g)��ȻӦ��ͬ��
        if ( res_b(i) * dsin(g(i)) < 0.d0 ) g(i) = g(i) + pi
        if ( g(i) < 0.d0 ) g(i) = g(i) + 2 * pi
    end do

    return
end subroutine
