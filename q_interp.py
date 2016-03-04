import pyfits
import numpy as np

## After applying 'q_badpix' to a map with a very generous threshold (only extremely $
##  we multiply the mask (the output from q_badpix) by the original image.
## This gives us an image where all of the 'really bad' pixels are set to 0.
## Then, we do a "first-pass# of interpolation: interpolate all of the 'lone bad pixe$
## This translates to zeroe'd pixels, whose neighbors are all non-zero.


## Give the fits file name:
masked_map = 'NL_OBJ_A01N_masked_test.fits'
interpolated_map = 'NL_OBJ_A01N_1pix_int.fits'

## Load the fits file into Python:
hdulist = pyfits.open(masked_map)

## Get the file's data from the "HDU" structure, using the '.data' attribute:
data = hdulist[0].data

## Print the dimensions for confirmation:
print data.shape
print data.dtype.name

##
print data[0,55,55]


for x in range(0,320):
        for y in range(0,240):
                if (data[0,y,x]=='nan' and data[0,y-1,x] !='nan' and
data[0,y+1,x]
!='nan'):

                        data[0,y,x] = (data[0,y-1,x] + data[0,y+1,x])/ 2

## Write the interpolated array to a file (keeping the header info):
hdulist.writeto(interpolated_map, output_verify='ignore',clobber=True)
