from PnP_ADMM_deblur import PnP_ADMM_Deblur
from utils import *
from PIL import Image, ImageOps
import numpy as np
from scipy.ndimage import correlate
from scipy.signal import fftconvolve, convolve2d
import cv2

if __name__ == '__main__':
    """ask for image name"""
    imgName = input('Enter image name: ')
    while os.path.exists(imgName) == False:
        imgName = input("previous entry does not exist, enter again: ")

    """ask for kernel name"""
    kernelName = input('Enter kernelName name: ')
    while os.path.exists(kernelName) == False:
        kernelName = input("previous entry does not exist, enter again: ")

    """read in kernel"""
    h = Image.open(kernelName)
    h = np.array(ImageOps.grayscale(h))
    h = h / float(255)

    """read in image"""
    y = ImageOps.grayscale(Image.open(imgName))
    y = np.array(y).astype(float)
    y_original = y.copy()

    """ADMM setup"""
    iter = 20
    method = 'TV'
    lamda = 0.01
    opts = {
        'rho': 1,
        'gamma': 1,
        'max_itr': iter,
        'print': True 
    }

    # out = PnP_ADMM_Deblur(y, h, lamda, method, opts)
    # out = (out * 255).astype(np.uint8)
    # Image.fromarray(out).save('deblurrredPicasso.png')

    """repeatedly apply ADMM to extract noise and store the final result at the end"""
    noise = np.zeros(y.shape)
    iterADMM = 10
    for i in range(iterADMM):
        print(f'ADMM: {i+1}-th iteration')
        y -= noise
        noise = PnP_ADMM_Deblur(y, h, lamda, method, opts)

    """Compute PSNR"""
    output = (y_original - noise)
    PSNR_output = cv2.PSNR(output, y_original)
    print(f'PSNR = {PSNR_output:3.2f} dB \n')

    output = (y - noise)
    output = output.astype(np.uint8)
    """saving results and compute PSNR"""
    print(output[:3,:3])
    Image.fromarray(output).save("ADMM_deblur.png")

