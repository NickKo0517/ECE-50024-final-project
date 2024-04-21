import subprocess
import os

def estimate_kernel()->str:
    exe_name = "./hq_deblur/deblur.exe"
    imgName = input('Enter image name: ')
    while os.path.exists(imgName) == False:
        imgName = input("previous entry does not exist, enter again: ")
    kernel_name = 'kernel.png'
    shellCommand = "{} {} {} 27 27 0.008 0.2 1 0 0 0 0 0".format(exe_name, imgName, kernel_name)
    try:
        subprocess.run(shellCommand, shell=True)
    except FileNotFoundError:
        print("Executable not found.")
    except Exception as e:
        print(f"An error occurred: {e}")
    return kernel_name