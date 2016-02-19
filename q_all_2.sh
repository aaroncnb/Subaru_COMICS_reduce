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

q_mkimg STD_NL_FILTER_FL.TXT STD_NL_FILTER_FL.fits 320 240
#q_mkimg STD_NL_FILTER_320x80_FL.TXT STD_NL_FILTER_320x80_FL.fits 320 80

q_mkimg STD_NL_FILTER_FN.TXT STD_NL_FILTER_FN.fits 320 240
#q_mkimg STD_NL_FILTER_320x80_FN.TXT STD_NL_FILTER_320x80_FN.fits 320 80





q_arith NL_SLIT1.fits x STD_NL_FILTER_FL.fits NL_SLIT1_Wcm-1.fits
q_arith NL_SLIT2.fits x STD_NL_FILTER_FL.fits NL_SLIT2_Wcm-1.fits

q_arith NL_SLIT1.fits x STD_NL_FILTER_FN.fits NL_SLIT1_JY.fits
q_arith NL_SLIT2.fits x STD_NL_FILTER_FN.fits NL_SLIT2_JY.fits

ds9 -scale mode zscale NL_SLIT1_Wcm-1.fits NL_SLIT2_Wcm-1.fits NL_SLIT1_JY.fits NL_SLIT2_JY.fits &
