   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.6 (r4159) - 21 Sep 2011 10:11
   !
   !  Differentiation of forcesadj in reverse (adjoint) mode:
   !   gradient     of useful results: moment refpoint force
   !   with respect to varying inputs: padj refpoint pts normadj
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          forcesAdj.f90                                   *
   !      * Author:        Edwin van der Weide,C.A.(Sandy) Mader           *
   !      * Starting date: 08-17-2008                                      *
   !      * Last modified: 08-17-2008                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE FORCESADJ_B(padj, padjb, pts, ptsb, normadj, normadjb, &
   &  refpoint, refpointb, force, forceb, moment, momentb, fact, ibeg, iend&
   &  , jbeg, jend, inode, jnode)
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   ! Subroutine Arguments
   REAL(kind=realtype), INTENT(IN) :: padj(3, 2, 2)
   REAL(kind=realtype) :: padjb(3, 2, 2)
   REAL(kind=realtype), INTENT(IN) :: pts(3, 3, 3)
   REAL(kind=realtype) :: ptsb(3, 3, 3)
   REAL(kind=realtype), INTENT(IN) :: normadj(3, 2, 2)
   REAL(kind=realtype) :: normadjb(3, 2, 2)
   REAL(kind=realtype), INTENT(IN) :: refpoint(3)
   REAL(kind=realtype) :: refpointb(3)
   REAL(kind=realtype) :: force(3)
   REAL(kind=realtype) :: forceb(3)
   REAL(kind=realtype) :: moment(3)
   REAL(kind=realtype) :: momentb(3)
   REAL(kind=realtype), INTENT(IN) :: fact
   INTEGER(kind=inttype), INTENT(IN) :: ibeg, iend, jbeg, jend, inode, &
   &  jnode
   ! Local Variables
   INTEGER(kind=inttype) :: i, j
   REAL(kind=realtype) :: pp, scaledim, xc(3), r(3), addforce(3)
   REAL(kind=realtype) :: ppb, xcb(3), rb(3), addforceb(3)
   REAL(kind=realtype) :: tauxx, tauyy, tauzz
   REAL(kind=realtype) :: tauxy, tauxz, tauyz
   INTEGER :: branch
   REAL(kind=realtype) :: tempb(3)
   scaledim = pref
   ! Force is the contribution of each of 4 cells
   DO j=1,2
   DO i=1,2
   IF (.NOT.(((inode + i - 2 .LT. ibeg .OR. inode + i - 1 .GT. iend) &
   &          .OR. jnode + j - 2 .LT. jbeg) .OR. jnode + j - 1 .GT. jend)) &
   &      THEN
   CALL PUSHREAL8ARRAY(pp, realtype/8)
   ! Calculate the Pressure
   pp = half*(padj(1, i, j)+padj(2, i, j)) - pinf
   pp = fourth*fact*scaledim*pp
   ! Incremental Force to Add
   ! Add increment to total Force for this node
   ! Cell Center, xc
   xc(:) = fourth*(pts(:, i, j)+pts(:, i+1, j)+pts(:, i, j+1)+pts(:&
   &          , i+1, j+1))
   CALL PUSHREAL8ARRAY(r, realtype*3/8)
   ! Vector from center to refPoint
   r(:) = xc(:) - refpoint(:)
   ! Moment is F x r ( F cross r)
   !          ! Viscous Force: Below is the code one would use to compute
   !            ! the viscous forces. This code has NOT been verified, and
   !            ! will not run. tau MUST be passed to this function, which
   !            ! will have been computed by a routine similar to
   !            ! viscousFlux.  The outer driving routines, will remain the
   !            ! same (since this is just an extra w-dependance). 
   !            if  (viscousSubface) then
   !               tauXx = tau(i,j,1)
   !               tauYy = tau(i,j,2)
   !               tauZz = tau(i,j,3)
   !               tauXy = tau(i,j,4)
   !               tauXz = tau(i,j,5)
   !               tauYz = tau(i,j,6)
   !               ! Compute the viscous force on the face. A minus sign
   !               ! is now present, due to the definition of this force.
   !               addForce(1)= -fact*(tauXx*normAdj(1,i,j) + tauXy*normAdj(2,i,j) &
   !                    +        tauXz*normAdj(3,i,j))
   !               addForce(2) = -fact*(tauXy*normAdj(i,j,1) + tauYy*normAdj(2,i,j) &
   !                    +        tauYz*normAdj(3,i,j))
   !               addForce(3) = -fact*(tauXz*normAdj(1,i,j) + tauYz*normAdj(2,i,j) &
   !                    +        tauZz*normAdj(3,i,j))
   !               ! Increment the Force
   !               force(:) = force(:) + addForce(:)
   !               ! Increment the Moment
   !               moment(1) = moment(1) + r(2)*addForce(3) - r(3)*addForce(2)
   !               moment(2) = moment(2) + r(3)*addForce(1) - r(1)*addForce(3)
   !               moment(3) = moment(3) + r(1)*addForce(2) - r(2)*addForce(1)
   !            end if
   CALL PUSHCONTROL1B(1)
   ELSE
   CALL PUSHCONTROL1B(0)
   END IF
   END DO
   END DO
   padjb = 0.0
   ptsb = 0.0
   normadjb = 0.0
   DO j=2,1,-1
   DO i=2,1,-1
   CALL POPCONTROL1B(branch)
   IF (branch .NE. 0) THEN
   addforce = pp*normadj(:, i, j)
   addforceb = 0.0
   rb = 0.0
   rb(1) = rb(1) + addforce(2)*momentb(3)
   addforceb(2) = addforceb(2) + r(1)*momentb(3)
   rb(2) = rb(2) - addforce(1)*momentb(3)
   addforceb(1) = addforceb(1) + r(3)*momentb(2) - r(2)*momentb(3)
   rb(3) = rb(3) + addforce(1)*momentb(2)
   rb(1) = rb(1) - addforce(3)*momentb(2)
   addforceb(3) = addforceb(3) + r(2)*momentb(1) - r(1)*momentb(2)
   rb(2) = rb(2) + addforce(3)*momentb(1)
   rb(3) = rb(3) - addforce(2)*momentb(1)
   addforceb(2) = addforceb(2) - r(3)*momentb(1)
   xcb = 0.0
   CALL POPREAL8ARRAY(r, realtype*3/8)
   xcb(:) = rb(:)
   refpointb = refpointb - rb
   tempb = fourth*xcb(:)
   ptsb(:, i, j) = ptsb(:, i, j) + tempb
   ptsb(:, i+1, j) = ptsb(:, i+1, j) + tempb
   ptsb(:, i, j+1) = ptsb(:, i, j+1) + tempb
   ptsb(:, i+1, j+1) = ptsb(:, i+1, j+1) + tempb
   addforceb = addforceb + forceb
   ppb = SUM(normadj(:, i, j)*addforceb)
   normadjb(:, i, j) = normadjb(:, i, j) + pp*addforceb
   ppb = fourth*fact*scaledim*ppb
   CALL POPREAL8ARRAY(pp, realtype/8)
   padjb(1, i, j) = padjb(1, i, j) + half*ppb
   padjb(2, i, j) = padjb(2, i, j) + half*ppb
   END IF
   END DO
   END DO
   END SUBROUTINE FORCESADJ_B
