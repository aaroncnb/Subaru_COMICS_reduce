###################Once q_all.sh and q_iraf_all are finished, please run this!##########
#### This script picks up after the IRAF/GEOMAP and GEOTRAN processes,
#### and proceeds with the FLUX calibration.
#### These steps partly require the rbin C codes, and partly depend
#### on the fortran codes provided by Sakon-san


####################FLUX CALIBRATION START!!!#########################

## First we have to combine thsoe two sets of 16 images we've been dragging around until now..

# COMBINE SLIT 1 (A):

q_fcombine NL_OBJ_A01N.fits NL_OBJ_A02N.fits NL_OBJ_A03N.fits NL_OBJ_A04N.fits NL_OBJ_A05N.fits NL_OBJ_A06N.fits NL_OBJ_A07N.fits NL_OBJ_A08N.fits NL_OBJ_A09N.fits NL_OBJ_A10N.fits NL_OBJ_A11N.fits NL_OBJ_A12N.fits NL_OBJ_A13N.fits NL_OBJ_A14N.fits NL_OBJ_A15N.fits NL_OBJ_A16N.fits ave=NL_SLIT1.fits

# COMBINE SLIT 2 (B):
####WARNING: For Slit B, Image #7 FAILED the GEOTRAN process
#### ALso, images 8-16 gave a "Warning, CD3 set to 1" message####
#### So please carefully check the result, and be sure to add-in the
#### B07 .fits file to this q_fcombine command, once everything's resolved (if it can be resolved...) [NL_OBJ_B07N.fits]

q_fcombine NL_OBJ_B01N.fits NL_OBJ_B02N.fits NL_OBJ_B03N.fits NL_OBJ_B04N.fits NL_OBJ_B05N.fits NL_OBJ_B06N.fits NL_OBJ_B08N.fits NL_OBJ_B09N.fits NL_OBJ_B10N.fits NL_OBJ_B11N.fits NL_OBJ_B12N.fits NL_OBJ_B13N.fits NL_OBJ_B14N.fits NL_OBJ_B15N.fits NL_OBJ_B16N.fits ave=NL_SLIT2.fits

ds9 NL_SLIT1.fits -scale mode zscale  NL_SLIT2.fits &

#If the output is ok, we can now start the actual flux calibration...
###########ACTUAL FLUX CALIBRATION##################################
echo "Preparing the Standard Star data for the flux calibration..."
q_list_stat NL_STD_A01N.fits 1 - 53-77 1 STD1P.fits
q_list_stat NL_STD_A01N.fits 1 - 166-190 1 STD1N.fits
q_arith STD1P.fits - STD1N.fits S1
q_arith S1 x 0.5 STD_NL.fits
ds9 -scale mode zscale NL_STD_A01N.fits STD1P.fits STD1N.fits STD_NL.fits &

echo "Creating the ADU table for the Standard Star.."
q_list_stat STD_NL.fits 1 - : : | awk '{print $2,$5*25.0}' > STD_NL.ADU
cat STD_NL.ADU

#####Now we run the FOTRAN code 'FC_STD.f', by Sakon-san#####
# Compile the code - to make sure we're using the latest version

g77 -o test FC_STD.f

# Run the code

./test

 #
echo "Finished flux calibration comparison (FC_STD.f)"
echo "FILTER FL RESULT"
cat STD_NL_FILTER_FL.TXT
echo "FILTER FL RESULT"
cat STD_NL_FILTER_FN.TXT

C  OUTPUT FILE; STD_NL_FILTER_FL.TXT
C  IN UNITS OF "W cm-2 um-1 / SLIT WIDTH (pixel)"
%> q_mkimg STD_NL_FILTER_FL.TXT STD_NL_FILTER_FL.fits 320 240
%> q_mkimg STD_NL_FILTER_320x80_FL.TXT STD_NL_FILTER_320x80_FL.fits 320 80

C  OUTPUT FILE; STD_NL_FILTER_FN.TXT
C  IN UNITS OF "Jy / SLIT WIDTH (pixel)"
%> q_mkimg STD_NL_FILTER_FN.TXT STD_NL_FILTER_FN.fits 320 240
%> q_mkimg STD_NL_FILTER_320x80_FN.TXT STD_NL_FILTER_320x80_FN.fits 320 80




---------------------------------------

[SLIT POSITION #A]
q_list_stat NL_OBJ_A01N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A01.DAT
q_list_stat NL_OBJ_A02N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A02.DAT
q_list_stat NL_OBJ_A03N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A03.DAT
q_list_stat NL_OBJ_A04N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A04.DAT
q_list_stat NL_OBJ_A05N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A05.DAT


plot "A01.DAT" u 1:2 w l, "A02.DAT" u ($1+1):($2*1.2) w l, "A01.DAT" u ($1-117):($2*(-1.1)) w l

q_list_stat NL_OBJ_A01N.fits 1 - 33-112 1 POS
q_list_stat NL_OBJ_A01N.fits 1 - 150-229 1 NEG
q_arith POS - NEG TEST
q_arith TEST x 0.5 NL_SLIT_A.fits

q_list_stat NL_SLIT_A.fits 1 - - 1 | awk '{print $2,$3,$5}' > 
(C³) NL_SLIT_A_BPC.TXT
paste NL_SLIT_A_BPC.TXT | awk '{print $3}' > NL_SLIT_A_BPC.ADU
q_mkimg NL_SLIT_A_BPC.ADU NL_SLIT_A_BPC.fits 320 80

q_arith NL_SLIT_A_BPC.fits x STD_NL_FILTER_320x80_FL.fits NL_SLIT_A_Wcm-2um-1.fits 
q_arith NL_SLIT_A_BPC.fits x STD_NL_FILTER_320x80_FN.fits NL_SLIT_A_JY.fits 

q_list_stat NL_SLIT_A_Wcm-2um-1.fits 1 - 35:48 1 | awk '{print $2*0.0198899992+6.94999981,$5*14}' > SLIT_A_Y35-48_Wcm-2um-1.SPC
q_list_stat NL_SLIT_A_Wcm-2um-1.fits 1 - 16:30 1 | awk '{print $2*0.0198899992+6.94999981,$5*15}' > SLIT_A_Y16-30_Wcm-2um-1.SPC



q_list_stat SLIT_B01.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B01.ADU 
q_list_stat SLIT_B02.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B02.ADU 
q_list_stat SLIT_B03.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B03.ADU 
q_list_stat SLIT_B04.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B04.ADU 
q_list_stat SLIT_B05.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B05.ADU 
q_list_stat SLIT_B06.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B06.ADU 
q_list_stat SLIT_B07.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B07.ADU 
q_list_stat SLIT_B08.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B08.ADU 
q_list_stat SLIT_B09.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B09.ADU 
q_list_stat SLIT_B10.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B10.ADU 
q_list_stat SLIT_B11.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B11.ADU 
q_list_stat SLIT_B12.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B12.ADU 
q_list_stat SLIT_B13.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B13.ADU 
q_list_stat SLIT_B14.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B14.ADU 
q_list_stat SLIT_B15.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B15.ADU 
q_list_stat SLIT_B16.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B16.ADU 
q_list_stat SLIT_B17.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B17.ADU 
q_list_stat SLIT_B18.fits 1 101:150 41-190 1 | awk '{print $3,$5}' > B18.ADU 

    Y OFFSET relative to B01 position
B01: 0
B02: 0

plot "B01.DAT" u 1:($2-1700) w l, "B02.DAT" u 1:($2*0.8) w l , "B01.DAT" u ($1-116):(($2-1750)*(-1.16)) w l

q_list_stat NL_OBJ_B01N.fits 1 - 41-120 1 POS1
q_list_stat NL_OBJ_B01N.fits 1 - 157-236 1 NEG1
q_list_stat NL_OBJ_B02N.fits 1 - 41-120 1 POS2
q_list_stat NL_OBJ_B02N.fits 1 - 157-236 1 NEG2
q_arith POS1 - NEG1 TEST1
q_arith POS2 - NEG2 TEST2
q_arith TEST1 x 0.5 T1
q_arith TEST2 x 0.5 T2
q_fcombine T1 T2 ave=NL_SLIT_B1.fits

q_list_stat NL_SLIT_B1.fits 1 - - 1 | awk '{print $2,$3,$5}' > 
(C³) NL_SLIT_B1_BPC.TXT
paste NL_SLIT_B1_BPC.TXT | awk '{print $3}' > NL_SLIT_B1_BPC.ADU
q_mkimg NL_SLIT_B1_BPC.ADU NL_SLIT_B1_BPC.fits 320 80

q_arith NL_SLIT_B1_BPC.fits x STD_NL_FILTER_320x80_FL.fits NL_SLIT_B1_Wcm-2um-1.fits 
q_arith NL_SLIT_B1_BPC.fits x STD_NL_FILTER_320x80_FN.fits NL_SLIT_B1_JY.fits 

q_list_stat NL_SLIT_B1_Wcm-2um-1.fits 1 - 34:53 1 | awk '{print $2*0.0198899992+6.94999981,$5*20}' > SLIT_B1_Y34-53_Wcm-2um-1.SPC
q_list_stat NL_SLIT_B1_Wcm-2um-1.fits 1 - 16:30 1 | awk '{print $2*0.0198899992+6.94999981,$5*15}' > SLIT_B1_Y16-30_Wcm-2um-1.SPC


6.95 13.314

    Y OFFSET relative to B01 position
B03: -4.5  0.0
B04: -5.5 -1.0 #
B05: -5.0  0.0
B06: -5.0 -0.5
B07: -4.5  0.0
B08: -5.0 -1.0 # 
B09: -4.5 -0.5
B10: -4.0  0.0
B11: -4.5 -1.0 # 
B15: -4.0 +0.5
B16: -5.0 +0.5
B17: -5.0 +1.0 # 
B18: -5.0 +2.0 # 

plot "B03.DAT" u 1:2 w l, "B03.DAT" u ($1-116):($2*(-1.16)) w l, "B04.DAT" u ($1+1):($2*1.3) w l

q_list_stat NL_OBJ_B03N.fits 1 - 41-120 1 POS1
q_list_stat NL_OBJ_B03N.fits 1 - 157-236 1 NEG1
q_list_stat NL_OBJ_B04N.fits 1 - 40-119 1 POS2
q_list_stat NL_OBJ_B04N.fits 1 - 156-235 1 NEG2
q_list_stat NL_OBJ_B05N.fits 1 - 41-120 1 POS3
q_list_stat NL_OBJ_B05N.fits 1 - 157-236 1 NEG3
q_list_stat NL_OBJ_B06N.fits 1 - 41-120 1 POS4
q_list_stat NL_OBJ_B06N.fits 1 - 157-236 1 NEG4
q_list_stat NL_OBJ_B07N.fits 1 - 41-120 1 POS5
q_list_stat NL_OBJ_B07N.fits 1 - 157-236 1 NEG5
q_list_stat NL_OBJ_B08N.fits 1 - 40-119 1 POS6
q_list_stat NL_OBJ_B08N.fits 1 - 156-235 1 NEG6
q_list_stat NL_OBJ_B09N.fits 1 - 41-120 1 POS7
q_list_stat NL_OBJ_B09N.fits 1 - 157-236 1 NEG7
q_list_stat NL_OBJ_B10N.fits 1 - 41-120 1 POS8
q_list_stat NL_OBJ_B10N.fits 1 - 157-236 1 NEG8
q_list_stat NL_OBJ_B11N.fits 1 - 40-119 1 POS9
q_list_stat NL_OBJ_B11N.fits 1 - 156-235 1 NEG9
q_list_stat NL_OBJ_B15N.fits 1 - 41-120 1 POSX
q_list_stat NL_OBJ_B15N.fits 1 - 157-236 1 NEGX
q_list_stat NL_OBJ_B16N.fits 1 - 41-120 1 POSJ
q_list_stat NL_OBJ_B16N.fits 1 - 157-236 1 NEGJ
q_list_stat NL_OBJ_B17N.fits 1 - 42-121 1 POSQ
q_list_stat NL_OBJ_B17N.fits 1 - 158-237 1 NEGQ
q_list_stat NL_OBJ_B18N.fits 1 - 43-122 1 POSK
q_list_stat NL_OBJ_B18N.fits 1 - 159-238 1 NEGK


q_fcombine POS1 POS2 POS3 POS4 POS5 POS6 POS7 POS8 POS9 POSX POSJ POSQ POSK ave=POS_AVE
q_fcombine NEG1 NEG2 NEG3 NEG4 NEG5 NEG6 NEG7 NEG8 NEG9 NEGX NEGJ NEGQ NEGK ave=NEG_AVE

q_arith POS_AVE + NEG_AVE TEST
q_list_stat TEST 1 - - 1 | awk '{print $2,$3,$5}' > BP_SLIT_B2.TXT
g77 -o test BP.f
q_mkimg BP_SLIT_B2.ADU BP_SLIT_B2.fits 320 80

q_arith POS_AVE - NEG_AVE T
q_arith T + BP_SLIT_B2.fits TBPC
q_arith TBPC x 0.5 NL_SLIT_B2.fits


q_arith NL_SLIT_B2.fits x STD_NL_FILTER_320x80_FL.fits NL_SLIT_B2_Wcm-2um-1.fits &
q_arith NL_SLIT_B2.fits x STD_NL_FILTER_320x80_FN.fits NL_SLIT_B2_JY.fits 

q_list_stat NL_SLIT_B2_Wcm-2um-1.fits 1 - 16:30 1 | awk '{print $2*0.0198899992+6.94999981,$5*15}' > SLIT_B2_Y16-30_Wcm-2um-1.SPC
q_list_stat NL_SLIT_B2_Wcm-2um-1.fits 1 - 31:50 1 | awk '{print $2*0.0198899992+6.94999981,$5*20}' > SLIT_B2_Y31-50_Wcm-2um-1.SPC
q_list_stat NL_SLIT_B2_Wcm-2um-1.fits 1 - 53:59 1 | awk '{print $2*0.0198899992+6.94999981,$5*20}' > SLIT_B2_Y53-59_Wcm-2um-1.SPC

q_list_stat NL_SLIT_B2_Wcm-2um-1.fits 1 - 13:35 1 | awk '{print $2*0.0198899992+6.94999981,$5*23}' > SLIT_B2_Y13-35_Wcm-2um-1.SPC
q_list_stat NL_SLIT_B2_Wcm-2um-1.fits 1 - 36:47 1 | awk '{print $2*0.0198899992+6.94999981,$5*12}' > SLIT_B2_Y36-47_Wcm-2um-1.SPC
q_list_stat NL_SLIT_B2_Wcm-2um-1.fits 1 - 48:53 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_B2_Y48-52_Wcm-2um-1.SPC
q_list_stat NL_SLIT_B2_Wcm-2um-1.fits 1 - 54:59 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_B2_Y53-59_Wcm-2um-1.SPC

q_list_stat NL_SLIT_B2_Wcm-2um-1.fits 1 - 40:44 1 | awk '{print $2*0.0198899992+6.94999981,$5*5}' > SLIT_B2_Y40-44_Wcm-2um-1.SPC


q_list_stat NL_OBJ_B01N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B01.DAT
q_list_stat NL_OBJ_B02N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B02.DAT

q_list_stat NL_OBJ_B12N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B12.DAT
q_list_stat NL_OBJ_B13N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B13.DAT
q_list_stat NL_OBJ_B14N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B14.DAT

q_list_stat NL_OBJ_B03N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B03.DAT
q_list_stat NL_OBJ_B04N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B04.DAT
q_list_stat NL_OBJ_B05N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B05.DAT
q_list_stat NL_OBJ_B06N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B06.DAT
q_list_stat NL_OBJ_B07N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B07.DAT
q_list_stat NL_OBJ_B08N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B08.DAT
q_list_stat NL_OBJ_B09N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B09.DAT
q_list_stat NL_OBJ_B10N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B10.DAT
q_list_stat NL_OBJ_B11N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B11.DAT
q_list_stat NL_OBJ_B15N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B15.DAT
q_list_stat NL_OBJ_B16N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B16.DAT
q_list_stat NL_OBJ_B17N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B17.DAT
q_list_stat NL_OBJ_B18N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B18.DAT

q_list_stat SLIT_B03.fits 1 71-170 86-185 1 SLIT_B2.fits

[SLIT C]

q_list_stat SLIT_C01.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > C01.ADU 
q_list_stat SLIT_C02.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > C02.ADU 
q_list_stat SLIT_C03.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > C03.ADU 
q_list_stat SLIT_C04.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > C04.ADU 
q_list_stat SLIT_C05.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > C05.ADU 
q_list_stat SLIT_C06.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > C06.ADU 
q_list_stat SLIT_C07.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > C07.ADU 
q_list_stat SLIT_C08.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > C08.ADU 
q_list_stat SLIT_C09.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > C09.ADU 
q_list_stat SLIT_C10.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > C10.ADU 

    Y OFFSET relative to C01 position
C01 : 0.0  
C02 : 0.0
C03 : +0.5
C04 : +1.5  0.0
C05 : +2.0 -0.5
C06 : +3.0 -1.0
C07 : +3.0 -1.0
C08 : +4.0 -1.5
C09 : +2.0 -1.0
C10 : +3.0 -1.0

q_list_stat NL_OBJ_C04N.fits 1 - 41-120 1 POS1
q_list_stat NL_OBJ_C04N.fits 1 - 157-236 1 NEG1
q_list_stat NL_OBJ_C05N.fits 1 - 41-120 1 POS2
q_list_stat NL_OBJ_C05N.fits 1 - 157-236 1 NEG2
q_list_stat NL_OBJ_C06N.fits 1 - 40-119 1 POS3
q_list_stat NL_OBJ_C06N.fits 1 - 156-235 1 NEG3
q_list_stat NL_OBJ_C07N.fits 1 - 40-119 1 POS4
q_list_stat NL_OBJ_C07N.fits 1 - 156-235 1 NEG4
q_list_stat NL_OBJ_C08N.fits 1 - 40-119 1 POS5
q_list_stat NL_OBJ_C08N.fits 1 - 156-235 1 NEG5
q_list_stat NL_OBJ_C09N.fits 1 - 40-119 1 POS6
q_list_stat NL_OBJ_C09N.fits 1 - 156-235 1 NEG6
q_list_stat NL_OBJ_C10N.fits 1 - 40-119 1 POS7
q_list_stat NL_OBJ_C10N.fits 1 - 156-235 1 NEG7

q_fcombine POS1 POS2 POS3 POS4 POS5 POS6 POS7 ave=POS_AVE
q_fcombine NEG1 NEG2 NEG3 NEG4 NEG5 NEG6 NEG7 ave=NEG_AVE

q_arith POS_AVE + NEG_AVE TEST
q_list_stat TEST 1 - - 1 | awk '{print $2,$3,$5}' > BP_SLIT_C2.TXT
g77 -o test BP_C.f
q_mkimg BP_SLIT_C2.ADU BP_SLIT_C2.fits 320 80

q_arith POS_AVE - NEG_AVE T
q_arith T + BP_SLIT_C2.fits TBPC
q_arith TBPC x 0.5 NL_SLIT_C2.fits

q_arith NL_SLIT_C2.fits x STD_NL_FILTER_320x80_FL.fits NL_SLIT_C2_Wcm-2um-1.fits
q_arith NL_SLIT_C2.fits x STD_NL_FILTER_320x80_FN.fits NL_SLIT_C2_JY.fits 

q_list_stat NL_SLIT_C2_Wcm-2um-1.fits 1 - 27:34 1 | awk '{print $2*0.0198899992+6.94999981,$5*8}' > SLIT_C2_Y27-34_Wcm-2um-1.SPC
q_list_stat NL_SLIT_C2_Wcm-2um-1.fits 1 - 35:38 1 | awk '{print $2*0.0198899992+6.94999981,$5*4}' > SLIT_C2_Y35-39_Wcm-2um-1.SPC
q_list_stat NL_SLIT_C2_Wcm-2um-1.fits 1 - 42:56 1 | awk '{print $2*0.0198899992+6.94999981,$5*15}' > SLIT_C2_Y42-56_Wcm-2um-1.SPC


q_list_stat NL_SLIT_C2_Wcm-2um-1.fits 1 - 15:26 1 | awk '{print $2*0.0198899992+6.94999981,$5*12}' > SLIT_C2_Y15-26_Wcm-2um-1.SPC
q_list_stat NL_SLIT_C2_Wcm-2um-1.fits 1 - 28:33 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_C2_Y28-33_Wcm-2um-1.SPC
q_list_stat NL_SLIT_C2_Wcm-2um-1.fits 1 - 34:39 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_C2_Y34-39_Wcm-2um-1.SPC
q_list_stat NL_SLIT_C2_Wcm-2um-1.fits 1 - 40:45 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_C2_Y40-45_Wcm-2um-1.SPC
q_list_stat NL_SLIT_C2_Wcm-2um-1.fits 1 - 46:51 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_C2_Y46-51_Wcm-2um-1.SPC

q_list_stat SLIT_C05.fits 1 51-150 101-200 1 SLIT_C2.fits 


q_list_stat NL_OBJ_C01N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > C01.DAT
q_list_stat NL_OBJ_C02N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > C02.DAT
q_list_stat NL_OBJ_C03N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > C03.DAT
q_list_stat NL_OBJ_C04N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > C04.DAT
q_list_stat NL_OBJ_C05N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > C05.DAT
q_list_stat NL_OBJ_C06N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > C06.DAT
q_list_stat NL_OBJ_C07N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > C07.DAT
q_list_stat NL_OBJ_C08N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > C08.DAT
q_list_stat NL_OBJ_C09N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > C09.DAT
q_list_stat NL_OBJ_C10N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > C10.DAT





[SLIT D]

q_list_stat SLIT_D01.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D01.ADU 
q_list_stat SLIT_D02.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D02.ADU 
q_list_stat SLIT_D03.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D03.ADU 
q_list_stat SLIT_D04.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D04.ADU 
q_list_stat SLIT_D05.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D05.ADU 
q_list_stat SLIT_D06.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D06.ADU 
q_list_stat SLIT_D07.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D07.ADU 
q_list_stat SLIT_D08.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D08.ADU 
q_list_stat SLIT_D09.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D09.ADU 
q_list_stat SLIT_D10.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D10.ADU 
q_list_stat SLIT_D11.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D11.ADU 
q_list_stat SLIT_D12.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D12.ADU 
q_list_stat SLIT_D13.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D13.ADU 
q_list_stat SLIT_D14.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D14.ADU 
q_list_stat SLIT_D15.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D15.ADU 
q_list_stat SLIT_D16.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D16.ADU 
q_list_stat SLIT_D17.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D17.ADU 
q_list_stat SLIT_D18.fits 1 71:120 101-200 1 | awk '{print $3,$5}' > D18.ADU 

    Y OFFSET relative to C01 position
D01 : 0.0      0.0   Y(NEG)=Y(POS)+114
D02 : -0.25    -1
D03 : +0.25    -3
D04 : +0.5     -3
D05 : +0.5     -4
D06 : +0.25    -4
D14 : +0.25    -6.5
D15 : +0.25    -7
D16 : +0.25    -8
D17 : 0.0      -7


D07 : +1.0     0.0   Y(NEG)=Y(POS)+114
D08 : +1.5     0.0
D09 : +1.75    -1
D10 : +1.5     -1 

D11 : +3.0     0.0   Y(NEG)=Y(POS)+115
D12 : +3.25    0.0	
D13 : +3.0     -1
D18 : +3.0     -3

q_list_stat NL_OBJ_D01N.fits 1 - 41-120 1 POS1
q_list_stat NL_OBJ_D01N.fits 1 - 155-234 1 NEG1
q_list_stat NL_OBJ_D02N.fits 1 - 40-119 1 POS2
q_list_stat NL_OBJ_D02N.fits 1 - 154-233 1 NEG2
q_list_stat NL_OBJ_D03N.fits 1 - 38-117 1 POS3
q_list_stat NL_OBJ_D03N.fits 1 - 152-231 1 NEG3
q_list_stat NL_OBJ_D04N.fits 1 - 38-117 1 POS4
q_list_stat NL_OBJ_D04N.fits 1 - 152-231 1 NEG4
q_list_stat NL_OBJ_D05N.fits 1 - 37-116 1 POS5
q_list_stat NL_OBJ_D05N.fits 1 - 151-230 1 NEG5
q_list_stat NL_OBJ_D06N.fits 1 - 37-116 1 POS6
q_list_stat NL_OBJ_D06N.fits 1 - 151-230 1 NEG6
q_list_stat NL_OBJ_D14N.fits 1 - 34-113 1 POS7
q_list_stat NL_OBJ_D14N.fits 1 - 148-227 1 NEG7
q_list_stat NL_OBJ_D15N.fits 1 - 34-113 1 POS8
q_list_stat NL_OBJ_D15N.fits 1 - 148-227 1 NEG8
q_list_stat NL_OBJ_D16N.fits 1 - 33-112 1 POS9
q_list_stat NL_OBJ_D16N.fits 1 - 147-226 1 NEG9
q_list_stat NL_OBJ_D17N.fits 1 - 34-113 1 POSX
q_list_stat NL_OBJ_D17N.fits 1 - 148-227 1 NEGX

q_fcombine POS1 POS2 POS3 POS4 POS5 POS6 POS7 POS8 POS9 POSX ave=POS_AVE
q_fcombine NEG1 NEG2 NEG3 NEG4 NEG5 NEG6 NEG7 NEG8 NEG9 NEGX ave=NEG_AVE

q_arith POS_AVE + NEG_AVE TEST
q_list_stat TEST 1 - - 1 | awk '{print $2,$3,$5}' > BP_SLIT_D1.TXT
g77 -o test BP_D.f
q_mkimg BP_SLIT_D1.ADU BP_SLIT_D1.fits 320 80

q_arith POS_AVE - NEG_AVE T
q_arith T + BP_SLIT_D1.fits TBPD
q_arith TBPD x 0.5 NL_SLIT_D1_TEST.fits
q_list_stat NL_SLIT_D1_TEST.fits 1 - - 1 | awk '{print $2,$3,$5}' > 
(C³) NL_SLIT_D1_TEST.DAT
paste NL_SLIT_D1_TEST.DAT | awk '{print $3}' > NL_SLIT_D1_TEST.ADU
q_mkimg NL_SLIT_D1_TEST.ADU NL_SLIT_D1.fits 320 80

q_arith NL_SLIT_D1.fits x STD_NL_FILTER_320x80_FL.fits NL_SLIT_D1_Wcm-2um-1.fits
q_arith NL_SLIT_D1.fits x STD_NL_FILTER_320x80_FN.fits NL_SLIT_D1_JY.fits 

q_list_stat NL_SLIT_D1_Wcm-2um-1.fits 1 - 7:16 1 | awk '{print $2*0.0198899992+6.94999981,$5*10}' > SLIT_D1_Y07-16_Wcm-2um-1.SPC
q_list_stat NL_SLIT_D1_Wcm-2um-1.fits 1 - 17:22 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_D1_Y17-22_Wcm-2um-1.SPC
q_list_stat NL_SLIT_D1_Wcm-2um-1.fits 1 - 23:28 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_D1_Y23-28_Wcm-2um-1.SPC
q_list_stat NL_SLIT_D1_Wcm-2um-1.fits 1 - 29:34 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_D1_Y29-34_Wcm-2um-1.SPC
q_list_stat NL_SLIT_D1_Wcm-2um-1.fits 1 - 35:40 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_D1_Y35-40_Wcm-2um-1.SPC
q_list_stat NL_SLIT_D1_Wcm-2um-1.fits 1 - 41:46 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_D1_Y41-46_Wcm-2um-1.SPC
q_list_stat NL_SLIT_D1_Wcm-2um-1.fits 1 - 47:52 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_D1_Y47-52_Wcm-2um-1.SPC
q_list_stat NL_SLIT_D1_Wcm-2um-1.fits 1 - 53:58 1 | awk '{print $2*0.0198899992+6.94999981,$5*6}' > SLIT_D1_Y53-58_Wcm-2um-1.SPC



q_list_stat NL_OBJ_D07N.fits 1 - 37-116 1 POS1
q_list_stat NL_OBJ_D07N.fits 1 - 151-230 1 NEG1
q_list_stat NL_OBJ_D08N.fits 1 - 37-116 1 POS2
q_list_stat NL_OBJ_D08N.fits 1 - 151-230 1 NEG2
q_list_stat NL_OBJ_D09N.fits 1 - 36-115 1 POS3
q_list_stat NL_OBJ_D09N.fits 1 - 150-229 1 NEG3
q_list_stat NL_OBJ_D10N.fits 1 - 36-115 1 POS4
q_list_stat NL_OBJ_D10N.fits 1 - 150-229 1 NEG4

q_list_stat NL_OBJ_D11N.fits 1 - 35-114 1 POS1
q_list_stat NL_OBJ_D11N.fits 1 - 150-229 1 NEG1
q_list_stat NL_OBJ_D12N.fits 1 - 35-114 1 POS2
q_list_stat NL_OBJ_D12N.fits 1 - 150-229 1 NEG2
q_list_stat NL_OBJ_D13N.fits 1 - 34-113 1 POS3
q_list_stat NL_OBJ_D13N.fits 1 - 148-227 1 NEG3
q_list_stat NL_OBJ_D14N.fits 1 - 32-111 1 POS4
q_list_stat NL_OBJ_D14N.fits 1 - 146-225 1 NEG4





q_list_stat NL_OBJ_D01N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D01.DAT
q_list_stat NL_OBJ_D02N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D02.DAT
q_list_stat NL_OBJ_D03N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D03.DAT
q_list_stat NL_OBJ_D04N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D04.DAT
q_list_stat NL_OBJ_D05N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D05.DAT
q_list_stat NL_OBJ_D06N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D06.DAT
q_list_stat NL_OBJ_D14N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D14.DAT
q_list_stat NL_OBJ_D15N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D15.DAT
q_list_stat NL_OBJ_D16N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D16.DAT
q_list_stat NL_OBJ_D17N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D17.DAT

q_list_stat NL_OBJ_D07N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D07.DAT
q_list_stat NL_OBJ_D08N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D08.DAT
q_list_stat NL_OBJ_D09N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D09.DAT
q_list_stat NL_OBJ_D10N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D10.DAT

q_list_stat NL_OBJ_D11N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D11.DAT
q_list_stat NL_OBJ_D12N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D12.DAT
q_list_stat NL_OBJ_D13N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D13.DAT
q_list_stat NL_OBJ_D18N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > D18.DAT




\subsection{XyNgÌØèoµ}
q_list_stat NL_SLIT2_Wcm-2um-1.fits 1 - 84:91 1 | awk '{print $2*0.0198899992+7.25,$5}' > S2_R1_Wcm-2um-1.SPC
paste S2_R1_Wcm-2um-1.SPC SKY_Wcm-2um-1.SPC | awk '{print $1,($2-$4)*8}' > S2_R1_Wcm-2um-1_SS.SPC
q_list_stat NL_SLIT2_Wcm-2um-1.fits 1 - 95:104 1 | awk '{print $2*0.0198899992+7.25,$5}' > S2_R2_Wcm-2um-1.SPC
paste S2_R2_Wcm-2um-1.SPC SKY_Wcm-2um-1.SPC | awk '{print $1,($2-$4)*10}' > S2_R2_Wcm-2um-1_SS.SPC
q_list_stat NL_SLIT2_Wcm-2um-1.fits 1 - 116:130 1 | awk '{print $2*0.0198899992+7.25,$5}' > S2_R3_Wcm-2um-1.SPC
paste S2_R3_Wcm-2um-1.SPC SKY_Wcm-2um-1.SPC | awk '{print $1,($2-$4)*10}' > S2_R3_Wcm-2um-1_SS.SPC


q_list_stat NL_SLIT2_JY.fits 1 - 84:91 1 | awk '{print $2*0.0198899992+7.25,$5}' > S2_R1_JY.SPC
paste S2_R1_JY.SPC SKY_JY.SPC | awk '{print $1,($2-$4)*8}' > S2_R1_JY_SS.SPC
q_list_stat NL_SLIT2_JY.fits 1 - 95:104 1 | awk '{print $2*0.0198899992+7.25,$5}' > S2_R2_JY.SPC
paste S2_R2_JY.SPC SKY_JY.SPC | awk '{print $1,($2-$4)*10}' > S2_R2_JY_SS.SPC
q_list_stat NL_SLIT2_JY.fits 1 - 116:130 1 | awk '{print $2*0.0198899992+7.25,$5}' > S2_R3_JY.SPC
paste S2_R3_JY.SPC SKY_JY.SPC | awk '{print $1,($2-$4)*10}' > S2_R3_JY_SS.SPC
# spec = numpy.loadtxt('S2_R1_Wcm-2um-1.SPC',delimiter=' ')
