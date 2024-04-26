import subprocess
import os

def estimate_kernel(h_width: int, h_height: int, imgName: str)->str:
    """this function performs blind deconvolution and returns path to the deblurred image"""
    exe_name = r"..\hq_deblur\deblur.exe"
    deblurred_name = 'deblurred.png'
    shellCommand = f"{exe_name} {imgName} {deblurred_name} {h_width} {h_height} 0.008 0.2 1 0 0 0 0 0"
    try:
        subprocess.run(shellCommand, shell=True)
    except FileNotFoundError:
        print("Executable not found.")
    except Exception as e:
        print(f"An error occurred: {e}")
    kernelName = imgName.replace('.png', "_kernel.png")
    return kernelName