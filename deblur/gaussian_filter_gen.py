import numpy as np

def gaus_fiter_gen(sigma, size):
    x = np.arange(-size[0]//2 + 1., size[0]//2 + 1.)
    y = np.arange(-size[1]//2 + 1., size[1]//2 + 1.)
    x, y = np.meshgrid(x, y)
    h = np.exp(-(x**2 + y**2) / (2. * sigma**2))
    h = h / np.sum(h)  # Normalize
    return h