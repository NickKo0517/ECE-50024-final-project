import numpy as np
from scipy import ndimage
from scipy.signal import fftconvolve, convolve2d
from gaussian_filter_gen import gaus_fiter_gen

kernel = np.array(([1, 2],
                  [3, 4]))

A = np.array(([1, 2, 3],
              [4, 5, 6],
              [7, 8, 9]))

print(ndimage.convolve(A, kernel))
print('convolve2d')
print(convolve2d(A, kernel, mode='valid'))      #convolve2d is the one we are looking for()