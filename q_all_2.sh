
# coding: utf-8

# Once q_all.sh and q_iraf_all are finished, please run this!
# This script picks up after the sky subtraction and bad pixel correction,
# and proceeds with the FLUX calibration.
# These steps partly require the rbin C codes, and partly depend
# on the fortran codes provided by Sakon-san

# In[1]:

q_list_stat NL_STD_A01N.fits 1 - 53-77 1 STD1P.fits
q_list_stat NL_STD_A01N.fits 1 - 166-190 1 STD1N.fits
q_arith STD1P.fits - STD1N.fits S1
q_arith S1 x 0.5 STD_NL.fits


# In[2]:

q_list_stat STD_NL.fits 1 - : : | awk '{print $2,$5*25.0}' > STD_NL.ADU


# In[3]:

g77 -o test_fc FC_STD.f
./test_fc


# In[4]:

g77 -o test_fc_320x80 FC_STD_320x80.f
./test_fc_320x80


# OUTPUT FILE; STD_NL_FILTER_FL.TXT
# IN UNITS OF "W cm-2 um-1 / SLIT WIDTH (pixel)"

# In[6]:

q_mkimg STD_NL_FILTER_FL.TXT STD_NL_FILTER_FL.fits 320 240 > /dev/null
q_mkimg STD_NL_FILTER_320x80_FL.TXT STD_NL_FILTER_320x80_FL.fits 320 80 > /dev/null


# In[8]:

q_list_stat NL_SLIT1_interp_hotfix.fits 1 - - 1 | awk '{print $2,$3,$5}' > NL_SLIT1.TXT
paste NL_SLIT1.TXT | awk '{print $3}' > NL_SLIT1.ADU
q_mkimg NL_SLIT1.ADU NL_SLIT1_320x80.fits 320 80 > /dev/null


# In[9]:

q_arith NL_SLIT1_320x80.fits x STD_NL_FILTER_320x80_FL.fits NL_SLIT1_320x80_Wcm-2um-1.fits 
q_arith NL_SLIT1_320x80.fits x STD_NL_FILTER_320x80_FN.fits NL_SLIT1_320x80_JY.fits 


# In[10]:

q_list_stat NL_SLIT1_320x80_Wcm-2um-1.fits 1 - 35:48 1 | awk '{print $2*0.0198899992+6.94999981,$5*14}' > SLIT1_Y35-48_Wcm-2um-1.SPC
q_list_stat NL_SLIT1_320x80_Wcm-2um-1.fits 1 - 16:30 1 | awk '{print $2*0.0198899992+6.94999981,$5*15}' > SLIT1_Y16-30_Wcm-2um-1.SPC


# In[ ]:



#####Now, since we have two slit positions for our current data-set, we re-run the above steps for the 2nd position
##### There aren't an comments for this next part, since the steps in this script are identical for both positons
##### Additionally, the lines where we dealt with the Standard Star data and calibration? We don't need to do that again.
##### We use the same standard star data to calibrate both positions.
##### POSITION B: Go!


q_list_stat NL_SLIT2_interp_hotfix.fits 1 - - 1 | awk '{print $2,$3,$5}' > NL_SLIT2.TXT
paste NL_SLIT2.TXT | awk '{print $3}' > NL_SLIT2.ADU
q_mkimg NL_SLIT2.ADU NL_SLIT2_320x80.fits 320 80 > /dev/null
q_arith NL_SLIT2_320x80.fits x STD_NL_FILTER_320x80_FL.fits NL_SLIT2_320x80_Wcm-2um-1.fits 
q_arith NL_SLIT2_320x80.fits x STD_NL_FILTER_320x80_FN.fits NL_SLIT2_320x80_JY.fits 
q_list_stat NL_SLIT2_320x80_Wcm-2um-1.fits 1 - 35:48 1 | awk '{print $2*0.0198899992+6.94999981,$5*14}' > SLIT2_Y35-48_Wcm-2um-1.SPC
q_list_stat NL_SLIT2_320x80_Wcm-2um-1.fits 1 - 16:30 1 | awk '{print $2*0.0198899992+6.94999981,$5*15}' > SLIT2_Y16-30_Wcm-2um-1.SPC

