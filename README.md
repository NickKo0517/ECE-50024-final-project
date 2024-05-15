# ECE-50024-final-project 

# Blind Deconvolution Attempt Using HQ-Deblur and PnP-ADMM
 
## Executing Python Code
* Go to the deblur folder for deblur demo
* Interpret/compile with Python 3.11.0. Using basic packages like Numpy, SciPy, and SciKit-Learn
* Assume all relevant packages installed properly, go to deblur/ folder and run
```bash
python3 main.py
```
* Adjustments (modifying certain lines of code) might be needed before executing.
* If executed successfully, the deblurred image would be saved in the deblur/ folder with name "ADMM_deblur.png"

### **IMPORTANT: kernel_estimation only works on x86 machines**


## Project Goal:
* Given an image with motion blur, restore the "clean" image "hidden" under the blur.
* Blur kernel, an essential parameter for restoration, is unknown when the image is read-in by the program
* Blur kernel would be estimated using methods and executable provided by the authors of HQ-Deblur
### Blur Estimation/Detection Demo/Resource 
* https://www.kaggle.com/datasets/kwentar/blur-dataset
* https://www.kaggle.com/code/valentinld/blurdetection#Train
* https://www.kaggle.com/code/michaelcripman/blurred-image-classification

## References
Chan, S. H., Wang, X., and Elgendy, O. A. Plug-and-play
 admm for image restoration: Fixed-point convergence
 and applications. IEEE Transactions on Computational
 Imaging, 3(1):84–98, 2016.  
 https://doi.org/10.48550/arXiv.1605.01710  
Shan, Q., Jia, J., and Agarwala, A. High-quality motion deblurring from a single image. ACM Transactions on
 Graphics (SIGGRAPH), 2008.  
 https://www.cse.cuhk.edu.hk/~leojia/projects/motion_deblurring/index.html
