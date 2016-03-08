###################Once q_all.sh and q_iraf_all are finished, please run this!##########
#### This script picks up after the IRAF/GEOMAP and GEOTRAN processes,
#### and proceeds with the FLUX calibration.
#### These steps partly require the rbin C codes, and partly depend
#### on the fortran codes provided by Sakon-san


####################FLUX CALIBRATION START!!!#########################

##These steps should take place after the bad-pixel correction and telluric-pattern subtraction

###########ACTUAL FLUX CALIBRATION##################################
echo "Preparing the Standard Star data for the flux calibration..."

q_list_stat NL_STD_A01N.fits 1 - 53-77 1 STD1P.fits
q_list_stat NL_STD_A01N.fits 1 - 166-190 1 STD1N.fits
q_arith STD1P.fits - STD1N.fits S1
q_arith S1 x 0.5 STD_NL.fits
#ds9 -scale mode zscale NL_STD_A01N.fits STD1P.fits STD1N.fits STD_NL.fits &

echo "Creating the ADU table for the Standard Star.."
q_list_stat STD_NL.fits 1 - : : | awk '{print $2,$5*25.0}' > STD_NL.ADU
#cat STD_NL.ADU

#####Now we run the FOTRAN code 'FC_STD.f', by Sakon-san#####
# Compile the code - to make sure we're using the latest version

g77 -o test_fc FC_STD.f
# Run the code
./test_fc
g77 -o test_fc_320x80 FC_STD_320x80.f
# Run the code
./test_fc_320x80
 #
echo "Finished flux calibration comparison (FC_STD.f)"

#  OUTPUT FILE; STD_NL_FILTER_FL.TXT
#  IN UNITS OF "W cm-2 um-1 / SLIT WIDTH (pixel)"
q_mkimg STD_NL_FILTER_FL.TXT STD_NL_FILTER_FL.fits 320 240
q_mkimg STD_NL_FILTER_320x80_FL.TXT STD_NL_FILTER_320x80_FL.fits 320 80

#  OUTPUT FILE; STD_NL_FILTER_FN.TXT
#  IN UNITS OF "Jy / SLIT WIDTH (pixel)"
 q_mkimg STD_NL_FILTER_FN.TXT STD_NL_FILTER_FN.fits 320 240
 q_mkimg STD_NL_FILTER_320x80_FN.TXT STD_NL_FILTER_320x80_FN.fits 320 80




q_list_stat NL_SLIT1_interp_hotfix.fits 1 - - 1 | awk '{print $2,$3,$5}' > NL_SLIT1.TXT
paste NL_SLIT1.TXT | awk '{print $3}' > NL_SLIT1.ADU
q_mkimg NL_SLIT1.ADU NL_SLIT1_80.fits 320 80

q_arith NL_SLIT1_80.fits x STD_NL_FILTER_320x80_FL.fits NL_SLIT_A_Wcm-2um-1.fits 
q_arith NL_SLIT1_80.fits x STD_NL_FILTER_320x80_FN.fits NL_SLIT_A_JY.fits 

q_list_stat NL_SLIT1_Wcm-2um-1.fits 1 - 35:48 1 | awk '{print $2*0.0198899992+6.94999981,$5*14}' > SLIT_A_Y35-48_Wcm-2um-1.SPC
q_list_stat NL_SLIT1_Wcm-2um-1.fits 1 - 16:30 1 | awk '{print $2*0.0198899992+6.94999981,$5*15}' > SLIT_A_Y16-30_Wcm-2um-1.SPC



q_mkimg NL_SLIT_B1_BPC.ADU NL_SLIT_B1_BPC.fits 320 80

q_arith NL_SLIT_B1_BPC.fits x STD_NL_FILTER_320x80_FL.fits NL_SLIT_B1_Wcm-2um-1.fits 
q_arith NL_SLIT_B1_BPC.fits x STD_NL_FILTER_320x80_FN.fits NL_SLIT_B1_JY.fits 

q_list_stat NL_SLIT_B1_Wcm-2um-1.fits 1 - 34:53 1 | awk '{print $2*0.0198899992+6.94999981,$5*20}' > SLIT_B1_Y34-53_Wcm-2um-1.SPC
q_list_stat NL_SLIT_B1_Wcm-2um-1.fits 1 - 16:30 1 | awk '{print $2*0.0198899992+6.94999981,$5*15}' > SLIT_B1_Y16-30_Wcm-2um-1.SPC




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
