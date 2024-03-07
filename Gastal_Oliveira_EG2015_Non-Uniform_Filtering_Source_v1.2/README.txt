These supplementary materials and source code are part of the reference
implementation of the paper

  "High-Order Recursive Filtering of Non-uniformly Sampled Signals
   for Image and Video Processing"
  Eduardo S. L. Gastal  and  Manuel M. Oliveira
  Computer Graphics Forum. Volume 34 (2015), Number 2.
  Proceedings of Eurographics 2015, pp. 81-93.

Please refer to the publication above if you use this software. For an
up-to-date version go to:

          http://inf.ufrgs.br/~eslgastal/NonUniformFiltering/

Version 1.2 - November 17, 2015.


In this folder you will find a "Supplementary.html" file which can be opened in
any web browser.  This file contains various examples illustrating some of the
possible applications of our discrete-time formulation for applying arbitrary
recursive digital filters to non-uniformly sampled signals.

Important: These materials are best viewed in a web browser that is *not*
Internet Explorer (IE), since it cannot resize the images properly. We
recommend the latest version of Firefox or Google Chrome.

This folder also includes the full source code of our method, implemented in
the Julia[1] programming language. This source code was used to generate all
the images in the paper and in the "Supplementary.html" file.  If you wish to
run our code and re-generate our results in your machine, you must install
SciPy[2], the Julia[1] language, and the IJulia[3] notebook programming
environment. You must then open the "Supplementary.ipynb" notebook file with
IJulia. See the next sections of this README.txt file on how to do this.

[1]: http://julialang.org/
[2]: http://scipy.org/
[3]: https://github.com/JuliaLang/IJulia.jl

The remaining sections in this README.txt file provide instructions for
installing these software packages on a computer running Ubuntu Linux. Our code
works under Windows. Our code has been tested in the following environments:

   Ubuntu 64-bit version 14.04.3:
      Python v2.7.6
      jupyter v4.0.6
      matplotlib v1.5.0
      numpy v1.10.1
      scikit-image v0.11.3
      scipy v0.16.1
      ----
      Julia v0.4.0
      IJulia v1.1.8
      Colors v0.6.0
      PyCall v1.2.0
      PyPlot v2.1.1
      Images v0.5.0
      StatsBase v0.7.4

=== Information about or source code
===============================================

** All files under "src/" are UTF-8 encoded **

Our source code is all whitin the "src/" directory.  You should probably look
at the file "our_method.jl".  This file implements the core equations of our
discrete-time formulation for applying arbitrary recursive digital filters to
non-uniformly sampled signals. The code is commented with pointers to the
equations of our paper.


=== Running our code using IJulia
===============================================

Open your command prompt and navigate to the folder which contains the
"Supplementary.ipynb" notebook file (ie, the folder of this README.txt):

   user@ubuntu$ cd /home/user/Documents/Gastal_Oliveira_EG2015_Non-Uniform_Filtering_Source_v1.1/

Run "jupyter notebook" in your command prompt:

   user@ubuntu$ jupyter notebook

   [I 17:35:48.404 NotebookApp] Serving notebooks from local directory: /home/user/Documents/Gastal_Oliveira_EG2015_Non-Uniform_Filtering_Source_v1.1/
   [I 17:35:48.404 NotebookApp] 0 active kernels 
   [I 17:35:48.404 NotebookApp] The IPython Notebook is running at: http://localhost:8888/
   [I 17:35:48.404 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).

A web browser should open automatically at the address http://localhost:8888.
From this interface, select the "Supplementary.ipynb" and open it.  Inside the
notebook, follow our text which guides you through the applications of our
method for non-uniform filtering.

To re-run all of our examples in your machine, in the top menu select "Cell >
Run All". This will re-execute all cells in the notebook, and may take a few
minutes. Otherwise, each cell can be executed independently: click on a code
cell to select it, and in the top menu select "Cell > Run". Note that the cells
in our notebook must be executed in order (top to bottom) due to code
dependencies.


=== Installing SciPy and dependencies
===============================================

   sudo apt-get install python-pip python-dev libblas-dev liblapack-dev gfortran libpng12-dev libfreetype6-dev pkg-config
   sudo pip install jupyter
   sudo pip install scipy numpy matplotlib scikit-image

See: http://scipy.org/install.html


=== Installing the Julia programming language
===============================================

   sudo apt-get install software-properties-common
   sudo add-apt-repository ppa:staticfloat/juliareleases
   sudo add-apt-repository ppa:staticfloat/julia-deps
   sudo apt-get update
   sudo apt-get install julia
   
See: http://julialang.org/downloads/#Ubuntu


=== Installing IJulia notebook and dependencies
===============================================

Run "julia" in your command prompt, you should see this:

   user@ubuntu$ julia

      _       _ _(_)_     |  A fresh approach to technical computing
     (_)     | (_) (_)    |  Documentation: http://docs.julialang.org
      _ _   _| |_  __ _   |  Type "?help" for help.
     | | | | | | |/ _` |  |
     | | |_| | | | (_| |  |  Version 0.4.0 (2015-10-08 06:20 UTC)
    _/ |\__'_|_|_|\__'_|  |  Official http://julialang.org release
   |__/                   |  x86_64-linux-gnu
   

Then, in the "julia>" prompt, run the following commands:

   julia> Pkg.add("IJulia")
   julia> Pkg.add("Colors")
   julia> Pkg.add("PyCall")
   julia> Pkg.add("PyPlot")
   julia> Pkg.add("Images")
   julia> Pkg.add("StatsBase")


=== Changelog
================================================================================

Version 1.2 - November 17, 2015:
  - Bugfix: fixed "@pyimport fig2data" not working when including "src/main.jl"
    from outside of the root directory of our package. Thanks to Raymond Lo.

Version 1.1 - Nov 2015:
  - Compatibility with Julia v0.4.

Version 1.0 - May 2015:
  - Initial release.
