      PROGRAM A_B_LINEAR_FIT
      
      IMPLICIT REAL*8(A-G,O-Z)
      IMPLICIT INTEGER*4(H-N)

      INTEGER*4 LMAX,MMAX
      PARAMETER(LMAX=320,MMAX=1)

      REAL*8 X1(MMAX),X2(MMAX),X3(MMAX),X4(MMAX)
      REAL*8 Y1(MMAX),X1Y1(MMAX),X2Y1(MMAX)
      REAL*8 AA(MMAX),BB(MMAX),CC(MMAX),DD(MMAX),
     +       EE(MMAX),FF(MMAX)
      REAL*8 AL(MMAX),BT(MMAX),GM(MMAX)
      INTEGER*4 NUM(MMAX)
      
      CHARACTER FN1*21

      OPEN(11,FILE="FN_SF.LST",STATUS="OLD")
      OPEN(50,FILE="SPATIAL_CONST_FIT.DAT",STATUS="NEW")
      
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CC               LEAST SQUARE FIT with y=ŠÁ(x-ŠÂ)**2+ŠÃ           CC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CC                                                                CC 
CC     n            n              n              n               CC
CC    Š²(xi) = X1, Š²(xi^2) = X2, Š²(xi^3) = X3, Š²(xi^4) = X4    CC
CC    i=1          i=1            i=1            i=1              CC
CC                                                                CC
CC                                                                CC 
CC      n              n                    n                     CC
CC     Š²(yi) = Y1,   Š²(xi¡Šyi) = X1Y1,   Š²(xi^2¡Šyi) = X2Y1    CC
CC     i=1            i=1                  i=1                    CC
CC                                                                CC
CC                                                                CC
CC     AA = n¡ŠX3 - X1¡ŠX2                                        CC
CC     BB = n¡ŠX2 - X1¡ŠX1                                        CC
CC     CC = n¡ŠX1Y1 - X1¡ŠY1                                      CC
CC                                                                CC
CC     DD = n¡ŠX4 - X2¡ŠX2                                        CC
CC     EE = n¡ŠX3 - X1¡ŠX2                                        CC
CC     FF = n¡ŠX2Y1 - X2¡ŠY1                                      CC
CC                                                                CC
CC                                                                CC
CC         CC¡ŠEE - BB¡ŠFF           1     CC¡ŠDD - AA¡ŠFF        CC  
CC   ŠÁ = ----------------- ,  ŠÂ = ---¡Š ----------------- ,     CC
CC         AA¡ŠEE - BB¡ŠDD           2     CC¡ŠEE - BB¡ŠFF        CC
CC                                                                CC
CC                X2        X1                    Y1              CC  
CC        ŠÃ = - ---¡ŠŠÁ + ---¡Š2ŠÁŠÂ - ŠÁŠÂŠÂ + ---              CC
CC                n         n                     n               CC
CC                                                                CC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC


      X1(1)=0.0
      X2(1)=0.0
      X3(1)=0.0
      X4(1)=0.0
      Y1(1)=0.0
      X1Y1(1)=0.0
      X2Y1(1)=0.0

      DO M=1,1
         READ(11,*)FN1
         OPEN(1,FILE=FN1,STATUS="OLD")
         DO L=1,LMAX
            READ(1,*,END=10)IXP,YP
C            WRITE(*,*)M,L,XP,YP
            XP=1.0*IXP
            WRITE(*,*)M,L,XP,YP
            NUM(M)=NUM(M)+1
            X1(M)=X1(M)+XP
            X2(M)=X2(M)+XP*XP
            X3(M)=X3(M)+XP*XP*XP
            X4(M)=X4(M)+XP*XP*XP*XP
            Y1(M)=Y1(M)+YP
            X1Y1(M)=X1Y1(M)+XP*YP
            X2Y1(M)=X2Y1(M)+XP*XP*YP
         END DO
 10      CONTINUE
C         WRITE(*,*)M,NUM(M)
         AA(M)=NUM(M)*X3(M)-X1(M)*X2(M)
         BB(M)=NUM(M)*X2(M)-X1(M)*X1(M)
         CC(M)=NUM(M)*X1Y1(M)-X1(M)*Y1(M)
         DD(M)=NUM(M)*X4(M)-X2(M)*X2(M)
         EE(M)=NUM(M)*X3(M)-X1(M)*X2(M)
         FF(M)=NUM(M)*X2Y1(M)-X2(M)*Y1(M)

         WRITE(*,*)AA(M),BB(M),CC(M),DD(M),EE(M),FF(M)
        
         AL(M)=(CC(M)*EE(M)-BB(M)*FF(M))/
     +           (AA(M)*EE(M)-BB(M)*DD(M))
         BT(M)=0.5*(CC(M)*DD(M)-AA(M)*FF(M))/
     +           (CC(M)*EE(M)-BB(M)*FF(M))
         GM(M)=-1.0*AL(M)*X2(M)/NUM(M)+
     +         2.0*AL(M)*BT(M)*X1(M)/NUM(M)-
     +         AL(M)*BT(M)*BT(M)+
     +         Y1(M)/NUM(M)
         
           WRITE(*,*)"DETECTOR No.=",M
           WRITE(*,*)"    ALPHA ; ",AL(M) 
           WRITE(*,*)"    BETA  ; ",BT(M) 
           WRITE(*,*)"    GAMMA ; ",GM(M) 
C           WRITE(*,*)AL(M),"* (x-", BT(M),")**2.0 +",GM(M)
         WRITE(50,*)"DETECTOR No.=",M+1,AL(M),BT(M),GM(M) 
C         WRITE(*,*)"DETECTOR No.=",M+1,AL(M),BT(M),GM(M) 
      END DO   
         WRITE(*,*)"B0(1)=",AL(1)
         WRITE(*,*)"B1(1)=",BT(1)

      STOP
      END
