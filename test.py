import numpy as np
from numpy import fft
from scipy import ndimage
from scipy.signal import fftconvolve, convolve2d
from gaussian_filter_gen import gaus_fiter_gen

kernel = np.array(([1, 2],
                  [3, 4]))

A = np.array(([1, 2, 3],
              [4, 5, 6],
              [7, 8, 9]))

print(A)
print(np.sum(A))

print(ndimage.convolve(A, kernel))
print('convolve2d')
print(convolve2d(A, kernel, mode='valid'))      #convolve2d is the one we are looking for()

# print("fft on A")
# print(fft.fftn(A, A.shape))

# print("ifft on A")
# print(fft.fftn(A, A.shape))
print('testing np.sum')
print(A)
print(np.sum(A, axis=0))    #add up each column
print(np.sum(A, axis=1))    #add up each row
print(np.sum(A, axis=None)) #add up each element in the matrix
