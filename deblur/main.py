from PnP_ADMM_deblur import PnP_ADMM_Deblur
from utils import *
from PIL import Image, ImageOps
import numpy as np
from scipy.ndimage import correlate
from scipy.signal import fftconvolve, convolve2d
import cv2

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

    print(f'kernelName = {kernelName}')
    """section that 1. reads in the kernel and 2. convert it into np.array"""
    h = Image.open(kernelName)
    h = ImageOps.grayscale(h)
    h = np.array(h)
    h = h / float(255)
    print(h.shape)
    print(h[:3, :3])
    
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
    iter = 20
    opts = {
        'rho': 1,
        'gamma': 1,
        'max_itr': iter,
        'print': False
    }

    # main routine
    y = Image.open(imgName)
    y = ImageOps.grayscale(y)
    y = np.array(y).astype(float)

    original_y = y.copy()   #y would be updated in the ADMM cycle, so keep a copy

    """ repetitively apply ADMM to generate "noise" """
    ADMMIter = 15
    out = np.zeros(y.shape)
    for i in range(ADMMIter):
        #ADMM gives out "noise" of the input image, so subtract from it
        print(f'ADMM for the {i+1} time')
        y -= out
        out = PnP_ADMM_Deblur(y, h, lambd, method, opts)

    """Compute PSNR"""
    out = y - out
    PSNR_output = cv2.PSNR(out, original_y)
    print(f'PSNR = {PSNR_output:3.2f} dB \n')

    """remove "noise" obtained from ADMM"""
    #ADMM gives out "noise" of the input image, so subtract from y
    out = out.astype(np.uint8) #convert as uint8 before saving as png
    print(out[:3,:3])
    Image.fromarray(out).save("ADMM_deblur.png")

