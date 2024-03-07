import numpy as np
from numpy import fft
from scipy.sparse.linalg import lsqr
from skimage.restoration import denoise_nl_means, denoise_tv_chambolle, denoise_bilateral, denoise_wavelet
from scipy.signal import fftconvolve, convolve2d
from scipy import fftpack, ndimage
from bm3d import bm3d
from PIL import Image
from skimage import restoration
from scipy import ndimage
import scipy
import copy

"""Ditch the RF filter as that requires extra adaptation from Matlab to Python"""
def PnP_ADMM_General(noisy_img: np.ndarray, A: np.matrix, lambd: float,
					 method: str, params: dict[str: float])->np.ndarray:
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
    dim = noisy_img.shape
    N   = dim[0] * dim[1]
    Hty = convolve2d(noisy_img, A, boundary='wrap') # convolution of the noise matrix and the original matrix
    eigHtH = np.abs(np.fft2(noisy_img))**2
    v           = 0.5*np.ones(dim)
    x           = v
    u           = np.zeros(dim)
    residual    = np.inf

    itr = 1
	one_div_sqrtN = 1/np.sqrt(N)
    while residual>tol and itr<=max_itr:
        # store x, v, u from previous iteration for psnr residual calculation
        x_old = x
        v_old = v
        u_old = u
        
        # inversion step
        xtilde = v - u
        rhs    = np.fft2(Hty+rho*xtilde)
        x      = np.real(np.ifft2(rhs/(eigHtH+rho)))
        
        # denoising step
        vtilde = x+u
        vtilde = np.clip(vtilde, [0,1])		#map all values of vtilde to interval [0,1]
        sigma  = np.sqrt(lambd /rho)
        if method == 'BM3D':
            v  = denoiser(vtilde, sigma)
        else:
            v  = denoiser(vtilde)
        
        # update langrangian multiplier
        u      = u + (x-v)
        
        # update rho
        rho = rho*gamma 
        
        # calculate residual
        residualx = one_div_sqrtN*np.linalg.norm(x - x_old)
        residualv = one_div_sqrtN*np.linalg.norm(v - v_old)
        residualu = one_div_sqrtN*np.linalg.norm(u - u_old)
        
        residual = residualx + residualv + residualu

        print('{} \t {} \t {} \t {} \n'.format(itr, residualx, residualv, residualu))
        
        itr = itr+1

    return x
