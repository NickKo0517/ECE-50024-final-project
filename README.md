# ECE-50024-final-project 


## Implementation of PnP-ADMM according to Dr.Stanley. H. Chan's paper
reference: https://doi.org/10.48550/arXiv.1605.01710 

## Running the Code
* Go to the deblur folder for deblur demo 
* Assume python intalled on local machine with all relevant libraries, run
```bash
 python3 main.py
```
* If executed successfully, there will be 2 images in the demo folder

## Plan 3/3/2024: (Done)
~~implement only image deblurring for Thursday Deadline (see section 2.1 in attached pdf (user_guide_v1.pdf))~~

## Project Goal:
~~* Translate Matlab implementation from Dr.Stanley Chan to Python (3/3/2024)~~
### (Checkpoint 5)
- What's a more "general" problem to solve?  

    > ANS: Image Deblurring (read from a blurry image and try to restore the "sharper" original)
- Where are the dataset(s) of this problem?  

    > ANS: See section (Sample datasets to use)
- (Is current implementation enough to solve this problem?)  

    > ANS: No, needs to figure out how to deduce the blur kernel in the given image
- What is the intended result after the application of our Python implementation?  

    > ANS: cleaner image than input  
#### Tips from Dr.Stanley Chan: 
* We are solving a difficult problem called blind deconvolution. It requires finding an estimate of the blur kernel then deblur with ADMM deblur. 
##### Tasks:
1. Find a reliable deblur estimation algorithm, implement in python if neccessary
2. Write Python Code that generates PSNR vs iteration number plot for (at least 2) different denoisers. 

### Blur Estimation/Detection Demo/Resource 
* this is in general a CNN problem/task, but our goal is not just detection: still have to deduce the kernel (the first link would be more helpful in my opinion)
* https://www.kaggle.com/code/valentinld/blurdetection#Train
* https://www.kaggle.com/code/michaelcripman/blurred-image-classification

~~* Translate relevant Matlab modules to Python if they exist, else implement it with Python library~~

## Progress Thus Far:
* Reading/annotating user_guide_v1 with relevant information
* Write functions to add noise (blurring) via convolution
* Syncing up all existing branches (all branches have the same info for now)
* Successful implementation of deblurring, about to work on a more general case

## Recommendation on Getting Started/Working:
* Spend 15 minutes daily in this repo to see if any changes are pushed
* Understand the user guide well (it's fine if you write a little code but have a good understanding)
* If you annotate (add more comments/info) to user_guide_v1, it is okay to push to main branch
* If write code, it is recommended that you push it to your own branch

## Sample datasets to use:
https://www.kaggle.com/datasets/kwentar/blur-dataset
