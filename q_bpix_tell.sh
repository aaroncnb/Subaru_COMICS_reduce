### These commands were just a check to see if the Y-positions were offset, between the 1st and 16th exposures
### If they were, we'd need additional corrections- but it would also make the bad-pixel correction process easier
### however, for IRAS18434- we found no significant offset betweent the exposures (both for pos A and pos B)
#q_list_stat NL_OBJ_A16N.fits 1 87:88 - - | awk '{print $3,$5}' > A16_TEST.TXT
#q_list_stat NL_OBJ_A01N.fits 1 87:88 - - | awk '{print $3,$5}' > A01_TEST.TXT
#q_list_stat NL_OBJ_B16N.fits 1 87:88 1-240 1 | awk '{print $3,$5}' > B16_TEST.TXT
#q_list_stat NL_OBJ_B01N.fits 1 87:88 1-240 1 | awk '{print $3,$5}' > B01_TEST.TXT

#Combine the individual exposures to maximize the signal to noise ratio (Slit Position A)
#q_fcombine NL_OBJ_A01N.fits NL_OBJ_A02N.fits NL_OBJ_A03N.fits NL_OBJ_A04N.fits NL_OBJ_A05N.fits NL_OBJ_A06N.fits NL_OBJ_A07N.fits NL_OBJ_A08N.fits NL_OBJ_A09N.fits NL_OBJ_A10N.fits NL_OBJ_A11N.fits NL_OBJ_A12N.fits NL_OBJ_A13N.fits NL_OBJ_A14N.fits NL_OBJ_A15N.fits NL_OBJ_A16N.fits ave=NL_SLIT1.fits

#Combine the individual exposures to maximize the signal to noise ratio (Slit Position B)
#q_fcombine NL_OBJ_B01N.fits NL_OBJ_B02N.fits NL_OBJ_B03N.fits NL_OBJ_B04N.fits NL_OBJ_B05N.fits NL_OBJ_B06N.fits NL_OBJ_B08N.fits NL_OBJ_B09N.fits NL_OBJ_B10N.fits NL_OBJ_B11N.fits NL_OBJ_B12N.fits NL_OBJ_B13N.fits NL_OBJ_B14N.fits NL_OBJ_B15N.fits NL_OBJ_B16N.fits ave=NL_SLIT2.fits


## We need to isolate and subtract the telluric (sky) line emission
##    Have a look at the "top" of the image (~y=200). This region shouldn't contain much of our target's emission data
##    BUT it must contain emission from the sky- so based on the pixels in this pixel-region, we'll estimate the telluric profile
##       First we break the area up into "slices" about 5 pixels high and then take their median, to deal with bad pixels,
#Position A
q_list_stat NL_SLIT1_interp_hotfix.fits 1 1-320 186-190 1 TEST1_S1tell.fits
q_list_stat NL_SLIT1_interp_hotfix.fits 1 1-320 191-195 1 TEST2_S1tell.fits
q_list_stat NL_SLIT1_interp_hotfix.fits 1 1-320 196-200 1 TEST3_S1tell.fits
q_list_stat NL_SLIT1_interp_hotfix.fits 1 1-320 201-205 1 TEST4_S1tell.fits
q_list_stat NL_SLIT1_interp_hotfix.fits 1 1-320 206-210 1 TEST5_S1tell.fits
q_list_stat NL_SLIT1_interp_hotfix.fits 1 1-320 211-215 1 TEST6_S1tell.fits
q_list_stat NL_SLIT1_interp_hotfix.fits 1 1-320 216-220 1 TEST7_S1tell.fits
q_list_stat NL_SLIT1_interp_hotfix.fits 1 1-320 221-225 1 TEST8_S1tell.fits
q_list_stat NL_SLIT1_interp_hotfix.fits 1 1-320 226-230 1 TEST9_S1tell.fits

#Position B
q_list_stat NL_SLIT2.fits 1 1-320 186-190 1 TEST1_S2tell.fits
q_list_stat NL_SLIT2.fits 1 1-320 191-195 1 TEST2_S2tell.fits
q_list_stat NL_SLIT2.fits 1 1-320 196-200 1 TEST3_S2tell.fits
q_list_stat NL_SLIT2.fits 1 1-320 201-205 1 TEST4_S2tell.fits
q_list_stat NL_SLIT2.fits 1 1-320 206-210 1 TEST5_S2tell.fits
q_list_stat NL_SLIT2.fits 1 1-320 211-215 1 TEST6_S2tell.fits
q_list_stat NL_SLIT2.fits 1 1-320 216-220 1 TEST7_S2tell.fits
q_list_stat NL_SLIT2.fits 1 1-320 221-225 1 TEST8_S2tell.fits
q_list_stat NL_SLIT2.fits 1 1-320 226-230 1 TEST9_S2tell.fits

 
## By taking the median-combination of all of those individual slices from above, we get a pretty good isolation of the telluric lines
#Position A
q_fcombine TEST1_S1tell.fits TEST2_S1tell.fits TEST3_S1tell.fits TEST4_S1tell.fits TEST5_S1tell.fits TEST6_S1tell.fits TEST7_S1tell.fits TEST8_S1tell.fits TEST9_S1tell.fits med=TEST__S1tell_MED.fits
#Position B
q_fcombine TEST1_S2tell.fits TEST2_S2tell.fits TEST3_S2tell.fits TEST4_S2tell.fits TEST5_S2tell.fits TEST6_S2tell.fits TEST7_S2tell.fits TEST8_S2tell.fits TEST9_S2tell.fits med=TEST__S2tell_MED.fits

## From the narrow TEST_MED.fits image, we put the telluric line pattern into a 1-D spectrum
#Position A
q_list_stat TEST_S1tell_MED.fits 1 1-320 1:5 1 | awk '{print $2,$5}' > SKY_RES_S1.TXT
##This simple fortran code (Perhaps I can make it in Python later..?) 
## makes an ASCII table from the 1-D SKY spectrum above.
## It eseentially copies the 1-D SKY profile accross all of the Y-rows.
## Each Y-position should be affected -generally- to the same extend by the telluric lines
g77 -o test SKY_RES_S1.f
./test
## After running the fortran code and getting the table, we convert it into a FITS image file
q_mkimg SKY_RES_MAP_S1.TXT SKY_RES_MAP_S1.fits 320 240

#Position B
#q_list_stat TEST_S2tell_MED.fits 1 1-320 1:5 1 | awk '{print $2,$5}' > SKY_RES.TXT
#g77 -o test SKY_RES.f
#./test
## After running the fortran code and getting the table, we convert it into a FITS image file
#q_mkimg SKY_RES_MAP.TXT SKY_RES_MAP_S2.fits 320 240

##   This file has the same dimensions of the science image, so we just subtract it qith q_arith
#Pos A
q_arith NL_SLIT1_interp_hotfix.fits - SKY_RES_MAP_S1.fits NL_SLIT1_skysub.fits #Now we have  a sky-subtracted image!
#Pos B
#q_arith NL_SLIT2.fits - SKY_RES_MAP_S2.fits NL_SLIT2_skysub.fits 

## to search through the bad-pixels, we can compare the image made above with its ASCII counterpart...
#Pos A
q_list_stat NL_SLIT1_skysub.fits 1 1-320 1-240 1 | awk '{print $2,$3,$5}' > NL_SLIT1_skysub.TXT 
#Pos B
#q_list_stat NL_SLIT2_skysub.fits 1 1-320 1-240 1 | awk '{print $2,$3,$5}' > NL_SLIT2_skysub.TXT 
####In the TXT file generated above, we can search for bad pixels (having negative values)
####   and "hot" pixels (having much higher values than their neighbors)

## From here, we can either manually identify the bad pixels and correct them by rough interpolation
##  or we can try to write a program that finds the bad values, and then uses the nearest "non-bad" 
##  pixels to interpolate. (the bad pixels typically appear in 2x2 pixel blocks)


