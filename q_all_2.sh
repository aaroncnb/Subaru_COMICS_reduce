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

q_fcombine NL_OBJ_B01N.fits NL_OBJ_B02N.fits NL_OBJ_B03N.fits NL_OBJ_B04N.fits NL_OBJ_B05N.fits NL_OBJ_B06N.fits NL_OBJ_B08N.fits NL_OBJ_B09N.fits NL_OBJ_B10N.fits NL_OBJ_B11N.fits NL_OBJ_B12N.fits NL_OBJ_B13N.fits NL_OBJ_B14N.fits NL_OBJ_B15N.fits NL_OBJ_B16N.fits ave=NL_SLIT1.fits
