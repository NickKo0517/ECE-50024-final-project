import numpy as np
from numpy import fft
from scipy.sparse.linalg import lsqr
from skimage.restoration import denoise_nl_means, denoise_tv_chambolle, denoise_bilateral, denoise_wavelet
from scipy.signal import fftconvolve, convolve2d
from scipy import fftpack, ndimage
from bm3d import bm3d
from scipy.ndimage import correlate
import cv2
import copy

def PnP_ADMM_Super(y: np.matrix, h: np.matrix, K: int, lamda: float, method: str, 
                   opts: dict[str: float]):
    """
    Input:           
        y       -  the observed gray scale image
        h       -  blur kernel
        K       -  downsampling factor
        lambda  -  regularization parameter
        method  -  denoiser, e.g., 'BM3D'
        opts.rho       -  internal parameter of ADMM {1}
        opts.gamma     -  parameter for updating rho {1}
        opts.maxitr    -  maximum number of iterations for ADMM {20}
        opts.tol       -  tolerance level for residual {1e-4}
    Output: recovered grayscale image
    """
    if y is None or h is None or K is None or opts is None:
        raise ValueError('provide y(image to do super-resolution), h: blur kernel, K: down-sampling factor,\
                        lamda: regularization term, method: name of denoiser')
    # Set parameters
    max_itr   = opts['max_itr'] if 'max_iter' in opts else 20
    tol       = opts['tol'] if 'tol' in opts else 1e-4
    gamma     = opts['gamma'] if 'gamma' in opts else 1
    rho       = opts['rho'] if 'rho' in opts  else 1
    # Select denoiser
    if method == 'BM3D':
        denoiser = lambda v_tilde, sigma: bm3d(z=v_tilde, sigma_psd=sigma)
    elif method == 'TV':
        denoiser = lambda v_tilde, sigma: denoise_tv_chambolle(image=v_tilde, weight=sigma)
    elif method == 'NLM':
        denoiser = lambda v_tilde, sigma: denoise_nl_means(image=v_tilde, h=sigma)
    else:
        raise ValueError('this function only supports the following denoisers for now:\
                         {BM3D, TV, NLM}\n')

    print('Plug-and-Play ADMM --- super-resolution')
    print('Denoiser = %s' % method)
    print('')
    print('itr \t ||x-xold|| \t ||v-vold|| \t ||u-uold||')

    # Initialize variables
    rows_in, cols_in = y.shape
    # these three are the dimension of the final image
    rows      = rows_in*K;  
    cols      = cols_in*K;
    N         = rows*cols;
    
    itr = 1

    # main loop
