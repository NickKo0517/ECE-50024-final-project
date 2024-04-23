import numpy as np
from PIL import Image

def gaus_fiter_gen(sigma, size):
    x = np.arange(-size[0]//2 + 1., size[0]//2 + 1.)
    y = np.arange(-size[1]//2 + 1., size[1]//2 + 1.)
    x, y = np.meshgrid(x, y)
    h = np.exp(-(x**2 + y**2) / (2. * sigma**2))
    h = h / np.sum(h)  # Normalize
    return h

h = gaus_fiter_gen(1, (9,9))
Image.fromarray((h*255).astype(np.uint8)).save('gaus_kernel.png')