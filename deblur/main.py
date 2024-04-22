from PnP_ADMM_deblur import PnP_ADMM_Deblur
from utils import *
# import matplotlib.pyplot as plt
from PIL import Image
import numpy as np
from scipy.ndimage import correlate
from scipy.signal import fftconvolve, convolve2d
from gaussian_filter_gen import gaus_fiter_gen
# import cv2

if __name__ == '__main__':
    """wrapper that determines blur kernel and store it as a separate file in dir"""
    h_width, h_height = 27, 27
    kernelName = estimate_kernel()
    """section that 1. reads in the kernel and 2. convert it into np.array"""
    h = Image.open(kernelName)
    h = np.asanyarray(h)
    print(h.shape)
    

    # set up parameters for ADMM
    # method = 'NLM'
    # if method == 'RF':
    #     lambd = 0.0005
    # elif method == 'NLM':
    #     lambd = 0.0005
    # elif method == 'BM3D':
    #     lambd = 0.001
    # else: #if input is something not supported by the file, use TV as default denoiser
    #     method = 'TV'
    #     lambd = 0.01

    # # optional parameters
    # opts = {
    #     'rho': 1,
    #     'gamma': 1,
    #     'max_itr': 20,
    #     'print': True
    # }

    # # main routine
    # out = PnP_ADMM_Deblur(noisy_img=y, A=h, lambd=lambd, method=method, params=opts)

    # #Debugging: Issue is that the "restored/filtered out" image has values that are too small
    # #which leads to a blacked out image as a whole
    # print('output from ADMM')
    # print(out[:5, :5])
    # # display
    # PSNR_output = cv2.PSNR(y, out)
    # print(f'PSNR = {PSNR_output:3.2f} dB \n')

    # # save the two images: convert them into greyscale
    # Image.fromarray((y*255).astype(np.uint8)).save('demo/noisy_input.png')
    # Image.fromarray((out*255).astype(np.uint8)).save('demo/deblurred_img.png')
