# ECE-50024-final-project 


## Implementation of PnP-ADMM according to Dr.Stanley. H. Chan's paper
reference: https://doi.org/10.48550/arXiv.1605.01710 

## Running the Code
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
- Where are the dataset(s) of this problem?
- (Is current implementation enough to solve this problem?)
- What is the intended result after the application of our Python implementation
* Translate relevant Matlab modules to Python if they exist, else implement it with Python library

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
