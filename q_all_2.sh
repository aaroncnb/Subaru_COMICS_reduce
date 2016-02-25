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
#### Please carefully check the .FITS output! There are a few things
#### Which can go wrong in the transformation process - try to catch them early!


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

#  OUTPUT FILE; STD_NL_FILTER_FL.TXT
#  IN UNITS OF "W cm-2 um-1 / SLIT WIDTH (pixel)"
q_mkimg STD_NL_FILTER_FL.TXT STD_NL_FILTER_FL.fits 320 240
q_mkimg STD_NL_FILTER_320x80_FL.TXT STD_NL_FILTER_320x80_FL.fits 320 80

#  OUTPUT FILE; STD_NL_FILTER_FN.TXT
#  IN UNITS OF "Jy / SLIT WIDTH (pixel)"
 q_mkimg STD_NL_FILTER_FN.TXT STD_NL_FILTER_FN.fits 320 240
 q_mkimg STD_NL_FILTER_320x80_FN.TXT STD_NL_FILTER_320x80_FN.fits 320 80

#[SLIT POSITION #A]
### I guess that the point here is to make analyze the data from each exposure,
#### as well as looking at the combined image ???
q_list_stat NL_OBJ_A01N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A01.DAT
q_list_stat NL_OBJ_A02N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A02.DAT
q_list_stat NL_OBJ_A03N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A03.DAT
q_list_stat NL_OBJ_A04N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A04.DAT
q_list_stat NL_OBJ_A05N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A05.DAT
q_list_stat NL_OBJ_A06N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A06.DAT
q_list_stat NL_OBJ_A07N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A07.DAT
q_list_stat NL_OBJ_A08N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A08.DAT
q_list_stat NL_OBJ_A09N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A09.DAT
q_list_stat NL_OBJ_A10N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A10.DAT
q_list_stat NL_OBJ_A11N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A11.DAT
q_list_stat NL_OBJ_A12N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A12.DAT
q_list_stat NL_OBJ_A13N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A13.DAT
q_list_stat NL_OBJ_A14N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A14.DAT
q_list_stat NL_OBJ_A15N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A15.DAT
q_list_stat NL_OBJ_A16N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > A16.DAT



### this "plot" commands seems to be run from the terminal but, what program is it calling?
##### Perhaps it's a macro used in Sakon-san's environment, calling gnuplot or something like that.
# plot "A01.DAT" u 1:2 w l, "A02.DAT" u ($1+1):($2*1.2) w l, "A01.DAT" u ($1-117):($2*(-1.1)) w l

q_list_stat NL_OBJ_A01N.fits 1 - 33-112 1 POS
q_list_stat NL_OBJ_A01N.fits 1 - 150-229 1 NEG
q_arith POS - NEG TEST
q_arith TEST x 0.5 NL_SLIT_A.fits

q_list_stat NL_SLIT_A.fits 1 - - 1 | awk '{print $2,$3,$5}' > NL_SLIT_A_BPC.TXT
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


#Y OFFSET relative to B01 position
#B01: 0
#B02: 0
#plot "B01.DAT" u 1:($2-1700) w l, "B02.DAT" u 1:($2*0.8) w l , "B01.DAT" u ($1-116):(($2-1750)*(-1.16)) w l

q_list_stat NL_OBJ_B01N.fits 1 - 41-120 1 POS1
q_list_stat NL_OBJ_B01N.fits 1 - 157-236 1 NEG1
q_list_stat NL_OBJ_B02N.fits 1 - 41-120 1 POS2
q_list_stat NL_OBJ_B02N.fits 1 - 157-236 1 NEG2
q_arith POS1 - NEG1 TEST1
q_arith POS2 - NEG2 TEST2
q_arith TEST1 x 0.5 T1
q_arith TEST2 x 0.5 T2
q_fcombine T1 T2 ave=NL_SLIT_B1.fits

q_list_stat NL_SLIT_B1.fits 1 - - 1 | awk '{print $2,$3,$5}' >  NL_SLIT_B1_BPC.TXT
paste NL_SLIT_B1_BPC.TXT | awk '{print $3}' > NL_SLIT_B1_BPC.ADU
q_mkimg NL_SLIT_B1_BPC.ADU NL_SLIT_B1_BPC.fits 320 80

q_arith NL_SLIT_B1_BPC.fits x STD_NL_FILTER_320x80_FL.fits NL_SLIT_B1_Wcm-2um-1.fits 
q_arith NL_SLIT_B1_BPC.fits x STD_NL_FILTER_320x80_FN.fits NL_SLIT_B1_JY.fits 

q_list_stat NL_SLIT_B1_Wcm-2um-1.fits 1 - 34:53 1 | awk '{print $2*0.0198899992+6.94999981,$5*20}' > SLIT_B1_Y34-53_Wcm-2um-1.SPC
q_list_stat NL_SLIT_B1_Wcm-2um-1.fits 1 - 16:30 1 | awk '{print $2*0.0198899992+6.94999981,$5*15}' > SLIT_B1_Y16-30_Wcm-2um-1.SPC


#6.95 13.314
#Y OFFSET relative to B01 position
#B03: -4.5  0.0
#B04: -5.5 -1.0 #
#B05: -5.0  0.0
#B06: -5.0 -0.5
##B07: -4.5  0.0
#B08: -5.0 -1.0 # 
#B09: -4.5 -0.5
#B10: -4.0  0.0
#B11: -4.5 -1.0 # 
#B15: -4.0 +0.5
#B16: -5.0 +0.5


#plot "B03.DAT" u 1:2 w l, "B03.DAT" u ($1-116):($2*(-1.16)) w l, "B04.DAT" u ($1+1):($2*1.3) w l

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
q_list_stat NL_OBJ_B03N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B03.DAT
q_list_stat NL_OBJ_B04N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B04.DAT
q_list_stat NL_OBJ_B05N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B05.DAT
q_list_stat NL_OBJ_B06N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B06.DAT
q_list_stat NL_OBJ_B07N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B07.DAT
q_list_stat NL_OBJ_B08N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B08.DAT
q_list_stat NL_OBJ_B09N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B09.DAT
q_list_stat NL_OBJ_B10N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B10.DAT
q_list_stat NL_OBJ_B11N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B11.DAT
q_list_stat NL_OBJ_B12N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B12.DAT
q_list_stat NL_OBJ_B13N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B13.DAT
q_list_stat NL_OBJ_B14N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B14.DAT
q_list_stat NL_OBJ_B15N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B15.DAT
q_list_stat NL_OBJ_B16N.fits 1 101:105 41-240 1 | awk '{print $3,$5}' > B16.DAT


q_list_stat SLIT_B03.fits 1 71-170 86-185 1 SLIT_B2.fits



#\subsection{XyNgÌØèoµ}
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
