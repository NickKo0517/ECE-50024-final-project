from PnP_ADMM_deblur import PnP_ADMM_Deblur
import matplotlib.pyplot as plt
from PIL import Image
import numpy as np
from scipy.ndimage import correlate
from scipy.signal import fftconvolve, convolve2d
from gaussian_filter_gen import gaus_fiter_gen
import cv2

if __name__ == '__main__':
    img = Image.open('complex_img.jpg')
    img = np.array(img) 
    img = img / 255

    h = gaus_fiter_gen(sigma=1, size=(9,9))

    # set noise level
    noise_level = 10/255

    # calculate observed image
    y_with_blur =  correlate(img, h, mode='wrap')
    width, height = y_with_blur.shape

    y = y_with_blur + noise_level*np.random.randn(width, height)    #this is taking long...
    y = np.clip(y,a_min=0, a_max=1)

    # set up parameters
    method = 'BM3D'
    if method == 'RF':
        lambd = 0.0005
    elif method == 'NLM':
        lambd = 0.0005
    elif method == 'BM3D':
        lambd = 0.001
    elif method == 'TV':
        lambd = 0.01

    # optional parameters
    opts = {
        'rho': 1,
        'gamma': 1,
        'max_itr': 20,
        'print': True
    }

    # main routine
    out = PnP_ADMM_General(noisy_img=y, A=h, lambd=lambd, method=method, params=opts)

    #Debugging: Issue is that the "restored/filtered out" image has values that are too small
    #which leads to a blacked out image as a whole
    print('output from ADMM')
    print(out[:5, :5])
    # display
    PSNR_output = cv2.PSNR(y, out)
    print(f'PSNR = {PSNR_output:3.2f} dB \n')

    # save the two images: convert them into greyscale
    Image.fromarray((y*255).astype(np.uint8)).save('demo/noisy_input.png')
    Image.fromarray((out*255).astype(np.uint8)).save('demo/deblurred_img.png')
