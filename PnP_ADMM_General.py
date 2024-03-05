import numpy as np
from scipy.sparse.linalg import lsqr
from skimage.restoration import denoise_nl_means, denoise_tv_chambolle, denoise_bilateral, denoise_wavelet
import numpy as np
from scipy.signal import fftconvolve
from skimage.restoration import denoise_nl_means, denoise_tv_chambolle, denoise_wavelet
from bm3d import bm3d
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from scipy.signal import convolve2d
from skimage import restoration
from scipy import ndimage
from utility import proj, psnr
import scipy
import copy

"""lets fix the deblurring/filtering method to a simple one"""
def PnP_ADMM_General(noisy_img: np.ndarray, A: np.matrix, lambd: float,
                     method: str, params: dict[str: float])->tuple[float]:
    """
    solves the following iteratively
        x^(k+1) = argmin f(x) + (rho/2) ||x - (v^(k) - u^(k))||^2
        v^(k+1) = D_{sigma_k}(x^(k+1) + u^(k)), where sigma_k = sqrt(1/rho_k)
        u^(k+1) = u^(k) + (x^(k+1) - v^(k+1))
    """
    # check for input validity
    if noisy_img is None or A is None or params is None:
        raise ValueError('please at least provide parameter noisy_img, A, and lambd\
                          to this function\n')

    # if no user defined input, use default parameters for ADMM
    if 'rho' not in params:
        params['rho'] = 1
    
    if 'max_itr' not in params:
        params['max_itr'] = 20
    
    if 'tol' not in params:
        params['tol'] = 1e-4
    
    if 'gamma' not in params:
        params['gamma'] = 1
    
    # loop parameters setup
    rho = params['rho']
    max_itr = params['max_itr']
    tol = params['tol']
    gamma = params['gamma']

    # iteratively compute the desired quantities x
    
    return 

print('hello')