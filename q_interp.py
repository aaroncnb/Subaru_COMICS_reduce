
# coding: utf-8

# In[1]:

import pyfits
import numpy as np
# Set up matplotlib and use a nicer set of plot parameters
get_ipython().magic(u'config InlineBackend.rc = {}')
import matplotlib
import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')
from astropy.io import fits


# In[2]:
####The 'helper function' suggestion, below, comes from the follwing very helpful Stack Exchange answer:
#########http://stackoverflow.com/questions/6518811/interpolate-nan-values-in-a-numpy-array  -by user "eat"
def nan_helper(row):
    """Helper to handle indices and logical indices of NaNs.

    Input:
        - y, 1d numpy array with possible NaNs
    Output:
        - nans, logical indices of NaNs
        - index, a function, with signature indices= index(logical_indices),
          to convert logical indices of NaNs to 'equivalent' indices
    Example:
        >>> # linear interpolation of NaNs
        >>> nans, x= nan_helper(y)
        >>> y[nans]= np.interp(x(nans), x(~nans), y[~nans])
    """

    return np.isnan(row), lambda z: z.nonzero()[0]
########################
#######################
# In[3]:

## Give the fits file name:
input_map = 'NL_SLIT1.fits'
#interpolated_map_deadfix = 'NL_SLIT1_interp_deadfix.fits'
interpolated_map_hotfix = 'NL_SLIT1_interp_hotfix.fits'

## Load the fits file into Python:
hdulist = pyfits.open(input_map)

## Get the file's data from the "HDU" structure, using the '.data' attribute:
data = hdulist[0].data

## Print the dimensions for confirmation:
print data.shape
print data.dtype.name


# In[4]:

data_dead = np.copy(data[0])

for y in range(0,240):
        row = data_dead[y,:]
        row_bad = np.where(row < -130.)
        row[row_bad] = np.nan
        nans, x= nan_helper(row)
        row[nans]= np.interp(x(nans), x(~nans), row[~nans])
        data_dead[y,:] = row


# In[5]:

plt.imshow(data_dead, cmap='gray')
plt.colorbar()


# In[6]:

data_hot = np.copy(data_dead)
for y in range(0,240):
        for x in range(0,320):
                if 74 < y < 116 and 273 < x < 284: #This is to ignore the Y-range where the strong line emission appears
                    continue
                if data_hot[y,x] > 4000.:
                        data_hot[y,x] = np.nan
        row = data_hot[y,:]
        nans, x= nan_helper(row)
        row[nans]= np.interp(x(nans), x(~nans), row[~nans])
        data_hot[y,:] = row


# In[7]:

plt.imshow(data_hot, cmap='gray')
plt.colorbar()


# In[8]:

## Second pass of hot pixel interpolation - this time completely
## excluding the bright source regions and line emission.
## The process is the same as above, but with a lower threshold.
## This should interpolate all of the bad pixels which are outside of the bright regions

data_hot_2 = np.copy(data_hot)
for y in range(0,240):
        for x in range(0,320):
                if 78 < y < 113 or 271 < x < 289: #This is to ignore the Y-range where the strong line emission appears
                    continue
                if data_hot_2[y,x] > 1000.:
                        data_hot_2[y,x] = np.nan
        row = data_hot_2[y,:]
        nans, x= nan_helper(row)
        row[nans]= np.interp(x(nans), x(~nans), row[~nans])
        data_hot_2[y,:] = row


# In[10]:

plt.imshow(data_hot_2, cmap='gray')
plt.colorbar()


# In[17]:

## Second pass of hot pixel interpolation - this time completely
## excluding the bright source regions and line emission.
## The process is the same as above, but with a lower threshold.
## This should interpolate all of the bad pixels which are outside of the bright regions

data_hot_3 = np.copy(data_hot_2)
for y in range(0,240):
        for x in range(0,320):
                if (78 < y < 113) or (0 < x < 41) or (270 < x < 289): #This is to ignore the Y-range where the strong line emission appears
                    continue
                if data_hot_3[y,x] > 600.:
                        data_hot_3[y,x] = np.nan
        row = data_hot_3[y,:]
        nans, x= nan_helper(row)
        row[nans]= np.interp(x(nans), x(~nans), row[~nans])
        data_hot_3[y,:] = row


# In[19]:

plt.imshow(data_hot_3, cmap='gray')
plt.colorbar()


# In[21]:

## Write the interpolated array to a file (keeping the header info):
data[0] = data_hot_3

#hdulist.writeto(interpolated_map_deadfix, output_verify='ignore',clobber=True)
hdulist.writeto(interpolated_map_hotfix, output_verify='ignore',clobber=True)


# In[ ]:



