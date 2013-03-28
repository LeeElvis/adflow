   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.7 (r4786) - 21 Feb 2013 15:53
   !
   !  Differentiation of prodsmag2 in forward (tangent) mode (with options debugTangent i4 dr8 r8):
   !   variations   of useful results: *prod
   !   with respect to varying inputs: *w *vol *si *sj *sk *prod
   !   Plus diff mem management of: w:in vol:in si:in sj:in sk:in
   !                prod:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          prodSmag2.f90                                   *
   !      * Author:        Georgi Kalitzin, Edwin van der Weide            *
   !      * Starting date: 08-01-2003                                      *
   !      * Last modified: 04-12-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE PRODSMAG2_T()
   USE BLOCKPOINTERS_D
   USE TURBMOD
   USE DIFFSIZES
   !  Hint: ISIZE4OFDrfsk should be the size of dimension 4 of array *sk
   !  Hint: ISIZE3OFDrfsk should be the size of dimension 3 of array *sk
   !  Hint: ISIZE2OFDrfsk should be the size of dimension 2 of array *sk
   !  Hint: ISIZE1OFDrfsk should be the size of dimension 1 of array *sk
   !  Hint: ISIZE4OFDrfsj should be the size of dimension 4 of array *sj
   !  Hint: ISIZE3OFDrfsj should be the size of dimension 3 of array *sj
   !  Hint: ISIZE2OFDrfsj should be the size of dimension 2 of array *sj
   !  Hint: ISIZE1OFDrfsj should be the size of dimension 1 of array *sj
   !  Hint: ISIZE4OFDrfsi should be the size of dimension 4 of array *si
   !  Hint: ISIZE3OFDrfsi should be the size of dimension 3 of array *si
   !  Hint: ISIZE2OFDrfsi should be the size of dimension 2 of array *si
   !  Hint: ISIZE1OFDrfsi should be the size of dimension 1 of array *si
   !  Hint: ISIZE3OFDrfvol should be the size of dimension 3 of array *vol
   !  Hint: ISIZE2OFDrfvol should be the size of dimension 2 of array *vol
   !  Hint: ISIZE1OFDrfvol should be the size of dimension 1 of array *vol
   !  Hint: ISIZE4OFDrfw should be the size of dimension 4 of array *w
   !  Hint: ISIZE3OFDrfw should be the size of dimension 3 of array *w
   !  Hint: ISIZE2OFDrfw should be the size of dimension 2 of array *w
   !  Hint: ISIZE1OFDrfw should be the size of dimension 1 of array *w
   !  Hint: ISIZE3OFDrfprod should be the size of dimension 3 of array *prod
   !  Hint: ISIZE2OFDrfprod should be the size of dimension 2 of array *prod
   !  Hint: ISIZE1OFDrfprod should be the size of dimension 1 of array *prod
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * prodSmag2 computes the term:                                   *
   !      *        2*sij*sij - 2/3 div(u)**2 with  sij=0.5*(duidxj+dujdxi) *
   !      * which is used for the turbulence equations.                    *
   !      * It is assumed that the pointer prod, stored in turbMod, is     *
   !      * already set to the correct entry.                              *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !      Local parameter
   !
   REAL(kind=realtype), PARAMETER :: f23=two*third
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: i, j, k
   REAL(kind=realtype) :: ux, uy, uz, vx, vy, vz, wx, wy, wz
   REAL(kind=realtype) :: uxd, uyd, uzd, vxd, vyd, vzd, wxd, wyd, wzd
   REAL(kind=realtype) :: div2, fact, sxx, syy, szz, sxy, sxz, syz
   REAL(kind=realtype) :: div2d, factd, sxxd, syyd, szzd, sxyd, sxzd, &
   &  syzd
   EXTERNAL DEBUG_TGT_HERE
   LOGICAL :: DEBUG_TGT_HERE
   IF (.TRUE. .AND. DEBUG_TGT_HERE('entry', .FALSE.)) THEN
   CALL DEBUG_TGT_REAL8ARRAY('w', w, wd, ISIZE1OFDrfw*ISIZE2OFDrfw*&
   &                        ISIZE3OFDrfw*ISIZE4OFDrfw)
   CALL DEBUG_TGT_REAL8ARRAY('vol', vol, vold, ISIZE1OFDrfvol*&
   &                        ISIZE2OFDrfvol*ISIZE3OFDrfvol)
   CALL DEBUG_TGT_REAL8ARRAY('si', si, sid, ISIZE1OFDrfsi*ISIZE2OFDrfsi&
   &                        *ISIZE3OFDrfsi*ISIZE4OFDrfsi)
   CALL DEBUG_TGT_REAL8ARRAY('sj', sj, sjd, ISIZE1OFDrfsj*ISIZE2OFDrfsj&
   &                        *ISIZE3OFDrfsj*ISIZE4OFDrfsj)
   CALL DEBUG_TGT_REAL8ARRAY('sk', sk, skd, ISIZE1OFDrfsk*ISIZE2OFDrfsk&
   &                        *ISIZE3OFDrfsk*ISIZE4OFDrfsk)
   CALL DEBUG_TGT_DISPLAY('entry')
   END IF
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Loop over the cell centers of the given block. It may be more
   ! efficient to loop over the faces and to scatter the gradient,
   ! but in that case the gradients for u, v and w must be stored.
   ! In the current approach no extra memory is needed.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   IF (.TRUE. .AND. DEBUG_TGT_HERE('middle', .FALSE.)) THEN
   CALL DEBUG_TGT_REAL8ARRAY('w', w, wd, ISIZE1OFDrfw*&
   &                              ISIZE2OFDrfw*ISIZE3OFDrfw*ISIZE4OFDrfw)
   CALL DEBUG_TGT_REAL8ARRAY('vol', vol, vold, ISIZE1OFDrfvol*&
   &                              ISIZE2OFDrfvol*ISIZE3OFDrfvol)
   CALL DEBUG_TGT_REAL8ARRAY('si', si, sid, ISIZE1OFDrfsi*&
   &                              ISIZE2OFDrfsi*ISIZE3OFDrfsi*ISIZE4OFDrfsi)
   CALL DEBUG_TGT_REAL8ARRAY('sj', sj, sjd, ISIZE1OFDrfsj*&
   &                              ISIZE2OFDrfsj*ISIZE3OFDrfsj*ISIZE4OFDrfsj)
   CALL DEBUG_TGT_REAL8ARRAY('sk', sk, skd, ISIZE1OFDrfsk*&
   &                              ISIZE2OFDrfsk*ISIZE3OFDrfsk*ISIZE4OFDrfsk)
   CALL DEBUG_TGT_REAL8ARRAY('prod', prod, prodd, ISIZE1OFDrfprod&
   &                              *ISIZE2OFDrfprod*ISIZE3OFDrfprod)
   CALL DEBUG_TGT_DISPLAY('middle')
   END IF
   ! Compute the gradient of u in the cell center. Use is made
   ! of the fact that the surrounding normals sum up to zero,
   ! such that the cell i,j,k does not give a contribution.
   ! The gradient is scaled by the factor 2*vol.
   uxd = wd(i+1, j, k, ivx)*si(i, j, k, 1) + w(i+1, j, k, ivx)*sid(&
   &          i, j, k, 1) - wd(i-1, j, k, ivx)*si(i-1, j, k, 1) - w(i-1, j, &
   &          k, ivx)*sid(i-1, j, k, 1) + wd(i, j+1, k, ivx)*sj(i, j, k, 1) &
   &          + w(i, j+1, k, ivx)*sjd(i, j, k, 1) - wd(i, j-1, k, ivx)*sj(i&
   &          , j-1, k, 1) - w(i, j-1, k, ivx)*sjd(i, j-1, k, 1) + wd(i, j, &
   &          k+1, ivx)*sk(i, j, k, 1) + w(i, j, k+1, ivx)*skd(i, j, k, 1) -&
   &          wd(i, j, k-1, ivx)*sk(i, j, k-1, 1) - w(i, j, k-1, ivx)*skd(i&
   &          , j, k-1, 1)
   ux = w(i+1, j, k, ivx)*si(i, j, k, 1) - w(i-1, j, k, ivx)*si(i-1&
   &          , j, k, 1) + w(i, j+1, k, ivx)*sj(i, j, k, 1) - w(i, j-1, k, &
   &          ivx)*sj(i, j-1, k, 1) + w(i, j, k+1, ivx)*sk(i, j, k, 1) - w(i&
   &          , j, k-1, ivx)*sk(i, j, k-1, 1)
   uyd = wd(i+1, j, k, ivx)*si(i, j, k, 2) + w(i+1, j, k, ivx)*sid(&
   &          i, j, k, 2) - wd(i-1, j, k, ivx)*si(i-1, j, k, 2) - w(i-1, j, &
   &          k, ivx)*sid(i-1, j, k, 2) + wd(i, j+1, k, ivx)*sj(i, j, k, 2) &
   &          + w(i, j+1, k, ivx)*sjd(i, j, k, 2) - wd(i, j-1, k, ivx)*sj(i&
   &          , j-1, k, 2) - w(i, j-1, k, ivx)*sjd(i, j-1, k, 2) + wd(i, j, &
   &          k+1, ivx)*sk(i, j, k, 2) + w(i, j, k+1, ivx)*skd(i, j, k, 2) -&
   &          wd(i, j, k-1, ivx)*sk(i, j, k-1, 2) - w(i, j, k-1, ivx)*skd(i&
   &          , j, k-1, 2)
   uy = w(i+1, j, k, ivx)*si(i, j, k, 2) - w(i-1, j, k, ivx)*si(i-1&
   &          , j, k, 2) + w(i, j+1, k, ivx)*sj(i, j, k, 2) - w(i, j-1, k, &
   &          ivx)*sj(i, j-1, k, 2) + w(i, j, k+1, ivx)*sk(i, j, k, 2) - w(i&
   &          , j, k-1, ivx)*sk(i, j, k-1, 2)
   uzd = wd(i+1, j, k, ivx)*si(i, j, k, 3) + w(i+1, j, k, ivx)*sid(&
   &          i, j, k, 3) - wd(i-1, j, k, ivx)*si(i-1, j, k, 3) - w(i-1, j, &
   &          k, ivx)*sid(i-1, j, k, 3) + wd(i, j+1, k, ivx)*sj(i, j, k, 3) &
   &          + w(i, j+1, k, ivx)*sjd(i, j, k, 3) - wd(i, j-1, k, ivx)*sj(i&
   &          , j-1, k, 3) - w(i, j-1, k, ivx)*sjd(i, j-1, k, 3) + wd(i, j, &
   &          k+1, ivx)*sk(i, j, k, 3) + w(i, j, k+1, ivx)*skd(i, j, k, 3) -&
   &          wd(i, j, k-1, ivx)*sk(i, j, k-1, 3) - w(i, j, k-1, ivx)*skd(i&
   &          , j, k-1, 3)
   uz = w(i+1, j, k, ivx)*si(i, j, k, 3) - w(i-1, j, k, ivx)*si(i-1&
   &          , j, k, 3) + w(i, j+1, k, ivx)*sj(i, j, k, 3) - w(i, j-1, k, &
   &          ivx)*sj(i, j-1, k, 3) + w(i, j, k+1, ivx)*sk(i, j, k, 3) - w(i&
   &          , j, k-1, ivx)*sk(i, j, k-1, 3)
   ! Idem for the gradient of v.
   vxd = wd(i+1, j, k, ivy)*si(i, j, k, 1) + w(i+1, j, k, ivy)*sid(&
   &          i, j, k, 1) - wd(i-1, j, k, ivy)*si(i-1, j, k, 1) - w(i-1, j, &
   &          k, ivy)*sid(i-1, j, k, 1) + wd(i, j+1, k, ivy)*sj(i, j, k, 1) &
   &          + w(i, j+1, k, ivy)*sjd(i, j, k, 1) - wd(i, j-1, k, ivy)*sj(i&
   &          , j-1, k, 1) - w(i, j-1, k, ivy)*sjd(i, j-1, k, 1) + wd(i, j, &
   &          k+1, ivy)*sk(i, j, k, 1) + w(i, j, k+1, ivy)*skd(i, j, k, 1) -&
   &          wd(i, j, k-1, ivy)*sk(i, j, k-1, 1) - w(i, j, k-1, ivy)*skd(i&
   &          , j, k-1, 1)
   vx = w(i+1, j, k, ivy)*si(i, j, k, 1) - w(i-1, j, k, ivy)*si(i-1&
   &          , j, k, 1) + w(i, j+1, k, ivy)*sj(i, j, k, 1) - w(i, j-1, k, &
   &          ivy)*sj(i, j-1, k, 1) + w(i, j, k+1, ivy)*sk(i, j, k, 1) - w(i&
   &          , j, k-1, ivy)*sk(i, j, k-1, 1)
   vyd = wd(i+1, j, k, ivy)*si(i, j, k, 2) + w(i+1, j, k, ivy)*sid(&
   &          i, j, k, 2) - wd(i-1, j, k, ivy)*si(i-1, j, k, 2) - w(i-1, j, &
   &          k, ivy)*sid(i-1, j, k, 2) + wd(i, j+1, k, ivy)*sj(i, j, k, 2) &
   &          + w(i, j+1, k, ivy)*sjd(i, j, k, 2) - wd(i, j-1, k, ivy)*sj(i&
   &          , j-1, k, 2) - w(i, j-1, k, ivy)*sjd(i, j-1, k, 2) + wd(i, j, &
   &          k+1, ivy)*sk(i, j, k, 2) + w(i, j, k+1, ivy)*skd(i, j, k, 2) -&
   &          wd(i, j, k-1, ivy)*sk(i, j, k-1, 2) - w(i, j, k-1, ivy)*skd(i&
   &          , j, k-1, 2)
   vy = w(i+1, j, k, ivy)*si(i, j, k, 2) - w(i-1, j, k, ivy)*si(i-1&
   &          , j, k, 2) + w(i, j+1, k, ivy)*sj(i, j, k, 2) - w(i, j-1, k, &
   &          ivy)*sj(i, j-1, k, 2) + w(i, j, k+1, ivy)*sk(i, j, k, 2) - w(i&
   &          , j, k-1, ivy)*sk(i, j, k-1, 2)
   vzd = wd(i+1, j, k, ivy)*si(i, j, k, 3) + w(i+1, j, k, ivy)*sid(&
   &          i, j, k, 3) - wd(i-1, j, k, ivy)*si(i-1, j, k, 3) - w(i-1, j, &
   &          k, ivy)*sid(i-1, j, k, 3) + wd(i, j+1, k, ivy)*sj(i, j, k, 3) &
   &          + w(i, j+1, k, ivy)*sjd(i, j, k, 3) - wd(i, j-1, k, ivy)*sj(i&
   &          , j-1, k, 3) - w(i, j-1, k, ivy)*sjd(i, j-1, k, 3) + wd(i, j, &
   &          k+1, ivy)*sk(i, j, k, 3) + w(i, j, k+1, ivy)*skd(i, j, k, 3) -&
   &          wd(i, j, k-1, ivy)*sk(i, j, k-1, 3) - w(i, j, k-1, ivy)*skd(i&
   &          , j, k-1, 3)
   vz = w(i+1, j, k, ivy)*si(i, j, k, 3) - w(i-1, j, k, ivy)*si(i-1&
   &          , j, k, 3) + w(i, j+1, k, ivy)*sj(i, j, k, 3) - w(i, j-1, k, &
   &          ivy)*sj(i, j-1, k, 3) + w(i, j, k+1, ivy)*sk(i, j, k, 3) - w(i&
   &          , j, k-1, ivy)*sk(i, j, k-1, 3)
   ! And for the gradient of w.
   wxd = wd(i+1, j, k, ivz)*si(i, j, k, 1) + w(i+1, j, k, ivz)*sid(&
   &          i, j, k, 1) - wd(i-1, j, k, ivz)*si(i-1, j, k, 1) - w(i-1, j, &
   &          k, ivz)*sid(i-1, j, k, 1) + wd(i, j+1, k, ivz)*sj(i, j, k, 1) &
   &          + w(i, j+1, k, ivz)*sjd(i, j, k, 1) - wd(i, j-1, k, ivz)*sj(i&
   &          , j-1, k, 1) - w(i, j-1, k, ivz)*sjd(i, j-1, k, 1) + wd(i, j, &
   &          k+1, ivz)*sk(i, j, k, 1) + w(i, j, k+1, ivz)*skd(i, j, k, 1) -&
   &          wd(i, j, k-1, ivz)*sk(i, j, k-1, 1) - w(i, j, k-1, ivz)*skd(i&
   &          , j, k-1, 1)
   wx = w(i+1, j, k, ivz)*si(i, j, k, 1) - w(i-1, j, k, ivz)*si(i-1&
   &          , j, k, 1) + w(i, j+1, k, ivz)*sj(i, j, k, 1) - w(i, j-1, k, &
   &          ivz)*sj(i, j-1, k, 1) + w(i, j, k+1, ivz)*sk(i, j, k, 1) - w(i&
   &          , j, k-1, ivz)*sk(i, j, k-1, 1)
   wyd = wd(i+1, j, k, ivz)*si(i, j, k, 2) + w(i+1, j, k, ivz)*sid(&
   &          i, j, k, 2) - wd(i-1, j, k, ivz)*si(i-1, j, k, 2) - w(i-1, j, &
   &          k, ivz)*sid(i-1, j, k, 2) + wd(i, j+1, k, ivz)*sj(i, j, k, 2) &
   &          + w(i, j+1, k, ivz)*sjd(i, j, k, 2) - wd(i, j-1, k, ivz)*sj(i&
   &          , j-1, k, 2) - w(i, j-1, k, ivz)*sjd(i, j-1, k, 2) + wd(i, j, &
   &          k+1, ivz)*sk(i, j, k, 2) + w(i, j, k+1, ivz)*skd(i, j, k, 2) -&
   &          wd(i, j, k-1, ivz)*sk(i, j, k-1, 2) - w(i, j, k-1, ivz)*skd(i&
   &          , j, k-1, 2)
   wy = w(i+1, j, k, ivz)*si(i, j, k, 2) - w(i-1, j, k, ivz)*si(i-1&
   &          , j, k, 2) + w(i, j+1, k, ivz)*sj(i, j, k, 2) - w(i, j-1, k, &
   &          ivz)*sj(i, j-1, k, 2) + w(i, j, k+1, ivz)*sk(i, j, k, 2) - w(i&
   &          , j, k-1, ivz)*sk(i, j, k-1, 2)
   wzd = wd(i+1, j, k, ivz)*si(i, j, k, 3) + w(i+1, j, k, ivz)*sid(&
   &          i, j, k, 3) - wd(i-1, j, k, ivz)*si(i-1, j, k, 3) - w(i-1, j, &
   &          k, ivz)*sid(i-1, j, k, 3) + wd(i, j+1, k, ivz)*sj(i, j, k, 3) &
   &          + w(i, j+1, k, ivz)*sjd(i, j, k, 3) - wd(i, j-1, k, ivz)*sj(i&
   &          , j-1, k, 3) - w(i, j-1, k, ivz)*sjd(i, j-1, k, 3) + wd(i, j, &
   &          k+1, ivz)*sk(i, j, k, 3) + w(i, j, k+1, ivz)*skd(i, j, k, 3) -&
   &          wd(i, j, k-1, ivz)*sk(i, j, k-1, 3) - w(i, j, k-1, ivz)*skd(i&
   &          , j, k-1, 3)
   wz = w(i+1, j, k, ivz)*si(i, j, k, 3) - w(i-1, j, k, ivz)*si(i-1&
   &          , j, k, 3) + w(i, j+1, k, ivz)*sj(i, j, k, 3) - w(i, j-1, k, &
   &          ivz)*sj(i, j-1, k, 3) + w(i, j, k+1, ivz)*sk(i, j, k, 3) - w(i&
   &          , j, k-1, ivz)*sk(i, j, k-1, 3)
   ! Compute the components of the stress tensor.
   ! The combination of the current scaling of the velocity
   ! gradients (2*vol) and the definition of the stress tensor,
   ! leads to the factor 1/(4*vol).
   factd = -(fourth*vold(i, j, k)/vol(i, j, k)**2)
   fact = fourth/vol(i, j, k)
   sxxd = two*(factd*ux+fact*uxd)
   sxx = two*fact*ux
   syyd = two*(factd*vy+fact*vyd)
   syy = two*fact*vy
   szzd = two*(factd*wz+fact*wzd)
   szz = two*fact*wz
   sxyd = factd*(uy+vx) + fact*(uyd+vxd)
   sxy = fact*(uy+vx)
   sxzd = factd*(uz+wx) + fact*(uzd+wxd)
   sxz = fact*(uz+wx)
   syzd = factd*(vz+wy) + fact*(vzd+wyd)
   syz = fact*(vz+wy)
   ! Compute 2/3 * divergence of velocity squared
   div2d = f23*2*(sxx+syy+szz)*(sxxd+syyd+szzd)
   div2 = f23*(sxx+syy+szz)**2
   ! Store the square of strain as the production term.
   prodd(i, j, k) = two*(two*(2*sxy*sxyd+2*sxz*sxzd+2*syz*syzd)+2*&
   &          sxx*sxxd+2*syy*syyd+2*szz*szzd) - div2d
   prod(i, j, k) = two*(two*(sxy**2+sxz**2+syz**2)+sxx**2+syy**2+&
   &          szz**2) - div2
   END DO
   END DO
   END DO
   IF (.TRUE. .AND. DEBUG_TGT_HERE('exit', .FALSE.)) THEN
   CALL DEBUG_TGT_REAL8ARRAY('prod', prod, prodd, ISIZE1OFDrfprod*&
   &                        ISIZE2OFDrfprod*ISIZE3OFDrfprod)
   CALL DEBUG_TGT_DISPLAY('exit')
   END IF
   END SUBROUTINE PRODSMAG2_T