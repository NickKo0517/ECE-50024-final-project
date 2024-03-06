import numpy as np
from scipy.sparse.linalg import lsqr
from skimage.restoration import denoise_nl_means, denoise_tv_chambolle, denoise_bilateral, denoise_wavelet
from scipy.signal import fftconvolve, convolve2d
from bm3d import bm3d
import matplotlib.pyplot as plt
from PIL import Image
from skimage import restoration
from scipy import ndimage
from utility import proj, psnr
import scipy
import copy

def PnP_ADMM_General(noisy_img: np.ndarray, A: np.matrix, lambd: float,
                     method: str, params: dict[str: float])->tuple[float]:
    """
    solves the following iteratively
        f(x) is some (linear transform), so f(x) = Ax
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

    # set up denoiser according to input string
    # assigning addr of filter wrappers to variable denoiser, when want to use it, 
    # type denoiser(arg1, arg2, ...)
    if method == 'BM3D':
        denoiser = bm3d     
    elif method == 'TV':
        denoiser = denoise_tv_chambolle
    elif method == 'NLM':
        denoiser = denoise_nl_means
    elif method == 'RF':
        pass
    else:
        raise ValueError('please use one of the following denoisers: \
                         {BM3D, TV, NLM, RF}\n')
    # iteratively compute the desired quantities: returs x in the end
    
    return 
