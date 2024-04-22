from PnP_ADMM_deblur import PnP_ADMM_Deblur
from utils import *
from PIL import Image, ImageOps
import numpy as np
from scipy.ndimage import correlate
from scipy.signal import fftconvolve, convolve2d
from gaussian_filter_gen import gaus_fiter_gen
from skimage import metrics         #for psnr computation

if __name__ == '__main__':
    h_width = int(input("input desired kernel width: "))
    h_height = int(input("input desired kernel height: ")) 
    if h_width <= 0:
        h_width = 27
    if h_height <= 0:
        h_height = 27

    """ask for noisy image name"""
    imgName = input('Enter image name: ')
    while os.path.exists(imgName) == False:
        imgName = input("previous entry does not exist, enter again: ")

    """wrapper that determines blur kernel and store it as a separate file in dir"""
    kernelName = estimate_kernel(h_width=h_width, h_height=h_height, imgName=imgName)

    """section that 1. reads in the kernel and 2. convert it into np.array"""
    h = Image.open(kernelName)
    h = ImageOps.grayscale(h)
    h = np.asanyarray(h)
    print(h.shape)
    
    # set up parameters for ADMM
    method = 'NLM'
    if method == 'RF':
        lambd = 0.0005
    elif method == 'NLM':
        lambd = 0.0005
    elif method == 'BM3D':
        lambd = 0.001
    else: #if input is something not supported by the file, use TV as default denoiser
        method = 'TV'
        lambd = 0.01

    # optional parameters
    opts = {
        'rho': 1,
        'gamma': 1,
        'max_itr': 20,
        'print': True
    }

    # main routine
    y = Image.open(imgName)
    y = ImageOps.grayscale(y)
    y = np.asanyarray(y)
    out = PnP_ADMM_Deblur(noisy_img=y, A=h, lambd=lambd, method=method, params=opts)

    #Debugging: Issue is that the "restored/filtered out" image has values that are too small
    #which leads to a blacked out image as a whole
    print('output from ADMM')
    print(out[:5, :5])
    # display
    print(f'y is {type(y)}, dimension {y.shape}')
    print(f'out is {type(out)}, dimension {out.shape}')
    PSNR_output = metrics.peak_signal_noise_ratio(y, out)
    print(f'PSNR = {PSNR_output:3.2f} dB \n')

    # save the two images: convert them into greyscale
    Image.fromarray((out*255).astype(np.uint8)).save('demo/deblurred_img.png')
