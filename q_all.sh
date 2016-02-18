##Imaging

##Darks for N11.7
q_list_stat COMA00089023.fits 1 - - : m89023
q_list_stat COMA00089025.fits 1 - - : m89025
q_list_stat COMA00089025.fits 1 - - : m89027
q_list_stat COMA00089025.fits 1 - - : m89029

q_fcombine m89023 m89025 m89027 m89029 ave=DI30_1_1_ave

q_arith DI30_1_1_ave / 16.0 DI30_1_1

##Darks for N8.8
q_list_stat COMA00089031.fits 1 - - : m89031
q_list_stat COMA00089033.fits 1 - - : m89033

q_fcombine m89031 m89033 ave=DI50_1_1_ave

q_arith DI50_1_1_ave / 9.0 DI50_1_1

##Darks Q18.8
####It turns out that the Q18.8 band data was either not taken or not stored...somehow
#### We don't know if it is an archival issue or something that happened on the night of observation
### Anyhow, life goes on! We'll skip the Q18.8 band processing!
#q_list_stat COMA00089019.fits 1 - - : m89019
#q_list_stat COMA00089021.fits 1 - - : m89021

q_fcombine m89019 m89021 ave=DI30_120_1_ave

q_arith DI30_120_1_ave / 16.0 DI30_120_1

##Q24.5- Same as N11.7!
#q_list_stat COMA00089023.fits 1 - - : m89023
#q_list_stat COMA00089025.fits 1 - - : m89025
#q_list_stat COMA00089025.fits 1 - - : m89027
#q_list_stat COMA00089025.fits 1 - - : m89029

#q_fcombine m89023 m89025 m89027 m89029 ave=DI30_1_1_ave

#q_arith DI30_1_1_ave / 16.0 DI30_1_1

##Spectroscopy
##NL
q_list_stat COMA00089052.fits 1 - - : m89052
q_list_stat COMA00089054.fits 1 - - : m89054

q_fcombine m89052 m89054 ave=DS150_1_1_ave

q_arith DS150_1_1_ave / 32.0 DS150_1_1

###FLAT####

q_list_stat COMA00089040.fits 1 - - : m89040
q_list_stat COMA00089042.fits 1 - - : m89042
q_list_stat COMA00089044.fits 1 - - : m89044
q_list_stat COMA00089046.fits 1 - - : m89046

##Make the FLATs averaged Dark, from the individual dark frames

q_fcombine m89040 m89042 m89044 m89046 ave=DS50_1_1_ave

##Get the typical value "per Nexp" (in this case, 98)

q_arith DS50_1_1_ave / 98.0 DS50_1_1

#Now that we have the flat's dark, subtract it from the flat, itself


# We have to refer to the 2nd frame in the COMA flat file- this contains the "actual" flat information
# the first frame should contain only the read-out noise + possibly some second order light
q_list_stat COMA00088272.fits 1 - - : DOMEFLAT_NL_STD_READ #This isolates the "read-out noise" pattern- 
#some pattern from the scattered light should also be visible in this image!


q_list_stat COMA00088272.fits 2 - - : DOMEFLAT_NL_STD_DATA  #This isolates the "actual" FLAT data


##First you have to scale the dark up to the same Nexp as the flat

q_arith DS50_1_1 \* 9.0 FDARK1

##Now you can actually subtract it

q_arith DOMEFLAT_NL_STD_DATA - FDARK1 FLAT_NL_TEST_STD

##Now we're gonna get the average value of the flat, so that we can
##normalize it
echo "Don't forget to put these numbers into the next command!"
echo "This is the average value for the NL Standard Star Obs.'s FLAT"
q_list_stat FLAT_NL_TEST_STD 1 1:320 32:240 1 | awk '{print $5}'

##Taking the value output by q_list_stat, we do the actual noramlization
##(In this case, it was 5.368803e+03)
## "OBJ1" is IRAS18434

q_arith FLAT_NL_TEST_STD / 1.554999e+05 FLAT_NL_STD

###Done!#
###Actually we're not done yet: Our observation set contains TWO flats
### One is for the standard star observation
### The other is for our target observation
### So we need to repeat the flat steps above for the target
### See 5.1.4 in the COMICS Cookbook: 



##88380 is the target's FLAT file: Repeating the steps above!

#Readout noise!
q_list_stat COMA00088380.fits 1 - - : DOMEFLAT_NL_OBJ_READ
#Flat!
q_list_stat COMA00088380.fits 2 - - : DOMEFLAT_NL_OBJ_DATA


q_arith DOMEFLAT_NL_OBJ_DATA - FDARK1 FLAT_NL_TEST_OBJ
echo "This is the average value for the NL Target Obs.'s FLAT"
q_list_stat FLAT_NL_TEST_OBJ 1 1:320 32:240 1 | awk '{print $5}'

## In the Object-Flat case, the average is 5.421052e+03

q_arith FLAT_NL_TEST_OBJ / 1.561373e+05 FLAT_NL_OBJ



######Actually Done!! (With Treating the Flats)#######


###Next: A different kind of noise reduction, "Redout Noise Pattern Correction
## First, we make "COMQ" files from the "COMA" files.
## The COMA files have two frames- one's the spectral data, the other's just a "guide 
## image"
## The guide image isn't really needed, BUT- the cool thing is, it has the same
## noise pattern as the spectral data. So we can easily extract the readout noise 
## pattern from the guide image, and then subtract this pattern from the spectral data

###First, we'll do it for the standard star observations (just one exposure)
###aftr that, we'll do it for the IRAS18434 target observations 
###(there's 16 exposures total), This means 8 of position b, 8 pos. a


####Starting Standard Star Flat correction:
#######Part A: Subtracting the readout noise with 'q_arith' and 'q_subch'


q_list_stat COMQ00088270.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088270.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_STD.REF
q_arith DATA.fits - NC_STD.REF COMQ_NL_STD_A01_NC.fits



###Starting position A
q_list_stat COMQ00088316.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088316.fits 1	- - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A01_NC.fits
q_list_stat COMQ00088318.fits 2	- - 1 DATA.fits
q_list_stat COMQ00088318.fits 1 - - 1 REF.fits
q_subch	REF.fits REF NC_OBJ.REF
q_arith	DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A02_NC.fits
q_list_stat COMQ00088320.fits 2	- - 1 DATA.fits
q_list_stat COMQ00088320.fits 1 - - 1 REF.fits
q_subch	REF.fits REF NC_OBJ.REF
q_arith	DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A03_NC.fits
q_list_stat COMQ00088322.fits 2	- - 1 DATA.fits
q_list_stat COMQ00088322.fits 1 - - 1 REF.fits
q_subch	REF.fits REF NC_OBJ.REF
q_arith	DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A04_NC.fits
q_list_stat COMQ00088324.fits 2	- - 1 DATA.fits
q_list_stat COMQ00088324.fits 1 - - 1 REF.fits
q_subch	REF.fits REF NC_OBJ.REF
q_arith	DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A05_NC.fits
q_list_stat COMQ00088326.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088326.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A06_NC.fits
q_list_stat COMQ00088328.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088328.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A07_NC.fits
q_list_stat COMQ00088330.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088330.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A08_NC.fits
q_list_stat COMQ00088332.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088332.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A09_NC.fits
q_list_stat COMQ00088334.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088334.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A10_NC.fits
q_list_stat COMQ00088336.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088336.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A11_NC.fits
q_list_stat COMQ00088338.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088338.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A12_NC.fits
q_list_stat COMQ00088340.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088340.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A13_NC.fits
q_list_stat COMQ00088342.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088342.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A14_NC.fits
q_list_stat COMQ00088344.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088344.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A15_NC.fits
q_list_stat COMQ00088346.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088346.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_A16_NC.fits



########Subtracting read-out noise for position B

q_list_stat COMQ00088348.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088348.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B01_NC.fits
q_list_stat COMQ00088350.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088350.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B02_NC.fits
q_list_stat COMQ00088352.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088352.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B03_NC.fits
q_list_stat COMQ00088354.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088354.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B04_NC.fits
q_list_stat COMQ00088356.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088356.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B05_NC.fits
q_list_stat COMQ00088358.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088358.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B06_NC.fits
q_list_stat COMQ00088360.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088360.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B07_NC.fits
q_list_stat COMQ00088362.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088362.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B08_NC.fits
q_list_stat COMQ00088364.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088364.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B09_NC.fits
q_list_stat COMQ00088366.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088366.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B10_NC.fits
q_list_stat COMQ00088368.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088368.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B11_NC.fits
q_list_stat COMQ00088370.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088370.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B12_NC.fits
q_list_stat COMQ00088372.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088372.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B13_NC.fits
q_list_stat COMQ00088374.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088374.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B14_NC.fits
q_list_stat COMQ00088376.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088376.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B15_NC.fits
q_list_stat COMQ00088378.fits 2 - - 1 DATA.fits
q_list_stat COMQ00088378.fits 1 - - 1 REF.fits
q_subch REF.fits REF NC_OBJ.REF
q_arith DATA.fits - NC_OBJ.REF COMQ_NL_OBJ_B16_NC.fits


#############Now that the COMQs and Flats prepared
############ we can finally divide the COMQs by the flats

##Standard Star Flat Correction
q_arith COMQ_NL_STD_A01_NC.fits / FLAT_NL_STD NL_4
q_chgaxis 3 NL_4 NL_STD_NC_FC_A01.fits
#Wondering if we need a 'q_chgaxis' here?

##Observation Flat Correction: Position A
q_arith COMQ_NL_OBJ_A01_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A01.fits
q_arith COMQ_NL_OBJ_A02_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A02.fits
q_arith COMQ_NL_OBJ_A03_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A03.fits
q_arith COMQ_NL_OBJ_A04_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A04.fits
q_arith COMQ_NL_OBJ_A05_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A05.fits
q_arith COMQ_NL_OBJ_A06_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A06.fits
q_arith COMQ_NL_OBJ_A07_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A07.fits
q_arith COMQ_NL_OBJ_A08_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A08.fits
q_arith COMQ_NL_OBJ_A09_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A09.fits
q_arith COMQ_NL_OBJ_A10_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A10.fits
q_arith COMQ_NL_OBJ_A11_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A11.fits
q_arith COMQ_NL_OBJ_A12_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A12.fits
q_arith COMQ_NL_OBJ_A13_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A13.fits
q_arith COMQ_NL_OBJ_A14_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A14.fits
q_arith COMQ_NL_OBJ_A15_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A15.fits
q_arith COMQ_NL_OBJ_A16_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_A16.fits

##Observation Flat Correction: Positon B
q_arith COMQ_NL_OBJ_B01_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B01.fits
q_arith COMQ_NL_OBJ_B02_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B02.fits
q_arith COMQ_NL_OBJ_B03_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B03.fits
q_arith COMQ_NL_OBJ_B04_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B04.fits
q_arith COMQ_NL_OBJ_B05_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B05.fits
q_arith COMQ_NL_OBJ_B06_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B06.fits
q_arith COMQ_NL_OBJ_B07_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B07.fits
q_arith COMQ_NL_OBJ_B08_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B08.fits
q_arith COMQ_NL_OBJ_B09_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B09.fits
q_arith COMQ_NL_OBJ_B10_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B10.fits
q_arith COMQ_NL_OBJ_B11_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B11.fits
q_arith COMQ_NL_OBJ_B12_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B12.fits
q_arith COMQ_NL_OBJ_B13_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B13.fits
q_arith COMQ_NL_OBJ_B14_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B14.fits
q_arith COMQ_NL_OBJ_B15_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B15.fits
q_arith COMQ_NL_OBJ_B16_NC.fits / FLAT_NL_OBJ NL_4
q_chgaxis 3 NL_4 NL_OBJ_NC_FC_B16.fits



########Next we make the sky images

##Extract the SKY frame ('q_bsep' may be needed here...)

#Scale the dark up to the NL Observervations Q_CHEB value (which can be found in the FITS header)
q_arith DS150_1_1 \* 3.0 FDARK1
#This same "FDARK1" file will be used for the remaining NL SKY-making commands


#Q_BSEP seprates ON from OFF - in terms of image chopping...
# We use the OFF (beam B) data to make the SKY image for beam A (ON)

echo "Making SKY images for the Standard Star"
q_bsep COMA00088270.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_STD SKY_NL_STD.fits


##Observation: Position A
echo "Making SKY images for Target A"

q_bsep COMA00088316.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A01.fits

q_bsep COMA00088318.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A02.fits

q_bsep COMA00088320.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A03.fits

q_bsep COMA00088322.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A04.fits

q_bsep COMA00088324.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A05.fits

q_bsep COMA00088326.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A06.fits

q_bsep COMA00088328.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A07.fits

q_bsep COMA00088330.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A08.fits

q_bsep COMA00088332.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A09.fits

q_bsep COMA00088334.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A10.fits

q_bsep COMA00088336.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A11.fits

q_bsep COMA00088338.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A12.fits

q_bsep COMA00088340.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A13.fits

q_bsep COMA00088342.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A14.fits

q_bsep COMA00088344.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A15.fits

q_bsep COMA00088346.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_A16.fits


##Observation: Position B
echo "Making SKY images for Target B"
q_bsep COMA00088348.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B01.fits

q_bsep COMA00088350.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B02.fits

q_bsep COMA00088352.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B03.fits

q_bsep COMA00088354.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B04.fits

q_bsep COMA00088356.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B05.fits

q_bsep COMA00088358.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B06.fits

q_bsep COMA00088360.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B07.fits

q_bsep COMA00088362.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B08.fits

q_bsep COMA00088364.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B09.fits

q_bsep COMA00088366.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B10.fits

q_bsep COMA00088368.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B11.fits

q_bsep COMA00088370.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B12.fits

q_bsep COMA00088372.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B13.fits

q_bsep COMA00088374.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B14.fits

q_bsep COMA00088376.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B15.fits

q_bsep COMA00088378.fits COMA_A COMA_B
q_list_stat COMA_B 2 - - : COMA_SKY_FOR_A
q_arith COMA_SKY_FOR_A - FDARK1 COMA_SKY_FOR_A_UFC
q_arith COMA_SKY_FOR_A_UFC / FLAT_NL_OBJ SKY_NL_OBJ_B16.fits


### Next let's obtain the spatially constant axis
# This part just scales the values by 100, so that the next 
# step runs faster..or so I think
q_arith COMQ_NL_STD_A01_NC.fits / 100.0 SCALE1
#q_startrace doesn't do the 2D function fitting...
# it just finds the peak position
q_startrace SCALE1 1 1-320 170:194 1 | awk '{print $2,$10}' > SPATIAL_CONST_STD_A01.DAT

###################################################################################
######################RUN SPATIAL_FIT_2DFUNC.f#####################################
#################################################################################

###Standard Star: Find the wavelength/pixel relationship!
### This process is basically independent from the Spatially-Constant Axis Fitting step :) 

#First step is to run 'q_sky_nlow'

# I was running it in the following way:
#q_sky_nlow SKY_NL_STD_A01.fits 1 - default 1 2 > SKY_NL_STD_A01.res
# but this turns out to be different from Sakon-san's notes. We'll follow his example instead:

##Standard Star:
#Scale by 100 for housekeeping purposes
echo "Running Q_SKY_NLOW for the Standard Star"
q_arith SKY_NL_STD.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_STD.TXT

#Position A:
echo "Running Q_SKY_NLOW for Target A"
q_arith SKY_NL_OBJ_A01.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A01.TXT
q_arith SKY_NL_OBJ_A02.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A02.TXT
q_arith SKY_NL_OBJ_A03.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A03.TXT
q_arith SKY_NL_OBJ_A04.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A04.TXT
q_arith SKY_NL_OBJ_A05.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A05.TXT
q_arith SKY_NL_OBJ_A06.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A06.TXT
q_arith SKY_NL_OBJ_A07.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A07.TXT
q_arith SKY_NL_OBJ_A08.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A08.TXT
q_arith SKY_NL_OBJ_A09.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A09.TXT
q_arith SKY_NL_OBJ_A10.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A10.TXT
q_arith SKY_NL_OBJ_A11.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A11.TXT
q_arith SKY_NL_OBJ_A12.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A12.TXT
q_arith SKY_NL_OBJ_A13.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A13.TXT
q_arith SKY_NL_OBJ_A14.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A14.TXT
q_arith SKY_NL_OBJ_A15.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A15.TXT
q_arith SKY_NL_OBJ_A16.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_A16.TXT

#Position B:
echo "Running Q_SKY_NLOW for Target B"
q_arith SKY_NL_OBJ_B01.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B01.TXT
q_arith SKY_NL_OBJ_B02.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B02.TXT
q_arith SKY_NL_OBJ_B03.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B03.TXT
q_arith SKY_NL_OBJ_B04.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B04.TXT
q_arith SKY_NL_OBJ_B05.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B05.TXT
q_arith SKY_NL_OBJ_B06.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B06.TXT
q_arith SKY_NL_OBJ_B07.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B07.TXT
q_arith SKY_NL_OBJ_B08.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B08.TXT
q_arith SKY_NL_OBJ_B09.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B09.TXT
q_arith SKY_NL_OBJ_B10.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B10.TXT
q_arith SKY_NL_OBJ_B11.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B11.TXT
q_arith SKY_NL_OBJ_B12.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B12.TXT
q_arith SKY_NL_OBJ_B13.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B13.TXT
q_arith SKY_NL_OBJ_B14.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B14.TXT
q_arith SKY_NL_OBJ_B15.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B15.TXT
q_arith SKY_NL_OBJ_B16.fits / 100.0 TEST1
q_sky_nlow TEST1 1 - default 1 2 | awk '{print $3,$6,$8}' > SKYFIT_NL_OBJ_B16.TXT






