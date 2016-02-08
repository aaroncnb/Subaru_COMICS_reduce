      PROGRAM A_B_LINEAR_FIT
      
      IMPLICIT REAL*8(A-G,O-Z)
      IMPLICIT INTEGER*4(H-N)
      INTEGER*4 LMAX
      PARAMETER(LMAX=19)

      REAL*4 AL(41,3,LMAX),BT(41,3,LMAX),CUT(LMAX)
      REAL*4 X1(41,3),X2(41,3)
      REAL*4 Y1A(41,3),Y1B(41,3),XYA(41,3),XYB(41,3)
      REAL*4 AA(41,3),AB(41,3)
      REAL*4 BA(41,3),BB(41,3)
      REAL*4 B0(3),B1(3)
      REAL*4 AFIX(3),BFIX(3)

      CHARACTER FN1*21,FN2*18

      INTEGER*4 NMAX1,NMAX2

      NMAX1=7
      NMAX2=1

      OPEN(11,FILE="FN_A_B_OBJ.LST",STATUS="OLD")
      OPEN(12,FILE="FN_A_B_STD.LST",STATUS="OLD")

      OPEN(51,FILE="GEOMAP_WL_PIX_OBJ.DAT",STATUS="OLD")
      OPEN(52,FILE="GEOMAP_WL_PIX_STD.DAT",STATUS="OLD")
      
C
C     Values are from "SPATIAL_CONST_FIT.DAT"
C      
      B0(1)= 2.56092368E-05
      B1(1)= 80.1720743
      B0(2)= 2.56092368E-05
      B1(2)= 80.1720743

      AFIX(1)=0.01989
      BFIX(1)=7.2500
      AFIX(2)=0.01989
      BFIX(2)=7.2500

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CC               LEAST SQUARE FIT with y=¦Áx+¦Â                   CC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CC                                                                CC 
CC      n            n              n            n                CC
CC     ¦²(xi) = X1, ¦²(xi^2) = X2, ¦²(yi) = Y1, ¦²(xi yi) = XY    CC
CC     i=1          i=1            i=1          i=1               CC
CC                                                                CC
CC             1                     1              1             CC     
CC       XY - --- (X1¡¦Y1)          --- (X2¡¦Y1) - --- (X1¡¦XY)   CC  
CC             n                     n              n             CC
CC ¦Á = ------------------- ,  ¦Â = ---------------------------   CC
CC             1                               1                  CC
CC       X2 - --- (X1¡¦X1)              X2 -  --- (X1¡¦X1)        CC
CC             n                               n                  CC
CC                                                                CC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      DO M=1,NMAX1
         READ(11,*)FN1
         OPEN(1,FILE=FN1,STATUS="OLD")
         DO L=1,LMAX
            READ(1,*)CUT(L),AL(M,1,L),BT(M,1,L)
         END DO
         CLOSE(1)
      END DO   
            
      DO M=1,NMAX1
         N=1
         DO L=1,LMAX
            X1(M,N)=X1(M,N)+CUT(L)
            X2(M,N)=X2(M,N)+(CUT(L)*CUT(L))
            Y1A(M,N)=Y1A(M,N)+AL(M,N,L)
            XYA(M,N)=XYA(M,N)+(CUT(L)*AL(M,N,L))
            Y1B(M,N)=Y1B(M,N)+BT(M,N,L)
            XYB(M,N)=XYB(M,N)+(CUT(L)*BT(M,N,L))
         END DO   

       AA(M,N)=(XYA(M,N)-(1./LMAX)*(X1(M,N)*Y1A(M,N)))/
     +         (X2(M,N)-(1./LMAX)*(X1(M,N)*X1(M,N)))
       BA(M,N)=(1./LMAX)*((X2(M,N)*Y1A(M,N))-(X1(M,N)*XYA(M,N)))/
     +         (X2(M,N)-(1./LMAX)*(X1(M,N)*X1(M,N)))

       AB(M,N)=(XYB(M,N)-(1./LMAX)*(X1(M,N)*Y1B(M,N)))/
     +         (X2(M,N)-(1./LMAX)*(X1(M,N)*X1(M,N)))
       BB(M,N)=(1./LMAX)*((X2(M,N)*Y1B(M,N))-(X1(M,N)*XYB(M,N)))/
     +         (X2(M,N)-(1./LMAX)*(X1(M,N)*X1(M,N)))
            
            WRITE(*,*)"FILE No.=",M
            WRITE(*,*)"ALPHA;"," a =",AA(M,N)," b =",BA(M,N) 
            WRITE(*,*)" BETA;"," a =",AB(M,N)," b =",BB(M,N) 

            WRITE(51,*)"q_transtable2",AA(M,N),BA(M,N),
     +      AB(M,N),BB(M,N),B0(N),B1(N)," GEOTRAN_OBJ0",M,".DAT",
     +      AFIX(N),BFIX(N)
      END DO   



      DO M=1,NMAX2
         READ(12,*)FN2
         OPEN(2,FILE=FN2,STATUS="OLD")
         DO L=1,LMAX
            READ(2,*)CUT(L),AL(M,2,L),BT(M,2,L)
         END DO
         CLOSE(2)
      END DO   
            
      DO M=1,NMAX2
         N=2
         DO L=1,LMAX
            X1(M,N)=X1(M,N)+CUT(L)
            X2(M,N)=X2(M,N)+(CUT(L)*CUT(L))
            Y1A(M,N)=Y1A(M,N)+AL(M,N,L)
            XYA(M,N)=XYA(M,N)+(CUT(L)*AL(M,N,L))
            Y1B(M,N)=Y1B(M,N)+BT(M,N,L)
            XYB(M,N)=XYB(M,N)+(CUT(L)*BT(M,N,L))
         END DO
   
       AA(M,N)=(XYA(M,N)-(1./LMAX)*(X1(M,N)*Y1A(M,N)))/
     +         (X2(M,N)-(1./LMAX)*(X1(M,N)*X1(M,N)))
       BA(M,N)=(1./LMAX)*((X2(M,N)*Y1A(M,N))-(X1(M,N)*XYA(M,N)))/
     +         (X2(M,N)-(1./LMAX)*(X1(M,N)*X1(M,N)))

       AB(M,N)=(XYB(M,N)-(1./LMAX)*(X1(M,N)*Y1B(M,N)))/
     +         (X2(M,N)-(1./LMAX)*(X1(M,N)*X1(M,N)))
       BB(M,N)=(1./LMAX)*((X2(M,N)*Y1B(M,N))-(X1(M,N)*XYB(M,N)))/
     +         (X2(M,N)-(1./LMAX)*(X1(M,N)*X1(M,N)))
            
            WRITE(*,*)"FILE No.=",M
            WRITE(*,*)"ALPHA;"," a =",AA(M,N)," b =",BA(M,N) 
            WRITE(*,*)" BETA;"," a =",AB(M,N)," b =",BB(M,N) 

            WRITE(52,*)"q_transtable2",AA(M,N),BA(M,N),
     +      AB(M,N),BB(M,N),B0(N),B1(N)," GEOTRAN_STD0",M,".DAT",
     +      AFIX(N),BFIX(N)
      END DO   

      STOP
      END
