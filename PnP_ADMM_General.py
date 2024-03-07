import numpy as np
from scipy.sparse.linalg import lsqr
from skimage.restoration import denoise_nl_means, denoise_tv_chambolle, denoise_bilateral, denoise_wavelet
from RF import RF
from scipy.signal import fftconvolve, convolve2d
from bm3d import bm3d
import matplotlib.pyplot as plt
from PIL import Image
from skimage import restoration
from scipy import ndimage
from utility import proj, psnr
import scipy
import copy

"""Ditch the RF filter as that requires extra adaptation from Matlab to Python"""
def PnP_ADMM_General(noisy_img: np.ndarray, A: np.matrix, lambd: float,
                     method: str, params: dict[str: float])->tuple[float]:
    """
    inputs:
        A: for deblurring, this should be the matrix that adds blurr to the original image
    solves the following iteratively
        f(x) is some (linear transform), so f(x) = Ax
        x^(k+1) = argmin f(x) + (rho/2) ||x - (v^(k) - u^(k))||^2
        v^(k+1) = D_{sigma_k}(x^(k+1) + u^(k)), where sigma_k = sqrt(1/rho_k)
        u^(k+1) = u^(k) + (x^(k+1) - v^(k+1))
    """
    # check for input validity
    if noisy_img is None or A is None or params is None:
        if A is None:
            print('A should be the noise Kernel/matrix describing noise')
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
        denoiser = lambda v_tilde, sigma: bm3d(z=v_tilde, sigma_psd=sigma) 
    elif method == 'TV':
        denoiser = lambda v_tilde: denoise_tv_chambolle(image=v_tilde)
    elif method == 'NLM':
        denoiser = lambda v_tilde: denoise_nl_means(image=v_tilde)
    else:
        raise ValueError('please use one of the following denoisers: \
                         {BM3D, TV, NLM}\n')
    # iteratively compute the desired quantities: returs x in the end
    img_width, img_height = noisy_img.shape
    N                     = img_width * img_height
    Hty                   = convolve2d(noisy_img, A, mode='circular')                    # should be a convolution and outputs a matrix
    eigHtH                =
    return 
