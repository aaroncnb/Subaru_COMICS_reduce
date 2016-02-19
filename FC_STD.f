      PROGRAM FLUX_CALIBRATION
      
      IMPLICIT REAL*8(A-G,O-Z)
      IMPLICIT INTEGER*4(H-N)
      
      REAL*8 SADU(320),WL(320),WLT(692),FL(692)
      REAL*8 FLCAL(320),FNCAL(320),FLC(320)

      OPEN(1,FILE="STD_NL.ADU",STATUS="OLD")
C    Change this file name according to the target being observed...
      OPEN(2,FILE="IRAS18434.tem",STATUS="OLD")
      
      OPEN(11,FILE="STD_NL_FILTER_FL.TXT",STATUS="NEW")
      OPEN(12,FILE="STD_NL_FILTER_FN.TXT",STATUS="NEW")
      
      AWL=0.0198899992
      BWL=7.25

      DO K=1,692
         READ(2,*)WLT(K),FL(K),EL,E1,E2
      END DO   

      DO I=1,320
         READ(1,*)IX,SADU(I)
         WL(I)=IX*AWL+BWL
         DO K=1,691
      IF((WLT(K).LE.WL(I)).AND.(WL(I).LE.WLT(K+1)))THEN
         FLC(I)=FL(K)+
     +   (FL(K+1)-FL(K))/(WLT(K+1)-WLT(K))*(WL(I)-WLT(K))
      END IF   
         END DO
      END DO
      
      DO J=1,240
         DO I=1,320
C           IN UNITS OF "W cm-2 um-1 / SLIT WIDTH (pixel)"            
            WRITE(11,*)FLC(I)/SADU(I)
C           IN UNITS OF "Jy / SLIT WIDTH (pixel)"
            FNCP=FLC(I)/SADU(I)*1.E+16*WL(I)**2.0/2.998
            WRITE(12,*)FNCP
         END DO
      END DO

      STOP
      END
  
