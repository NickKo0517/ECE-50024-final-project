#
#  The core equations of our method are implemented in the file
#  'our_method.jl'.  Please see the README.txt file for instructions.
#

#  This code is part of the reference implementation of the paper
#
#    "High-Order Recursive Filtering of Non-uniformly Sampled Signals
#     for Image and Video Processing"
#    Eduardo S. L. Gastal  and  Manuel M. Oliveira
#    Computer Graphics Forum. Volume 34 (2015), Number 2.
#    Proceedings of Eurographics 2015, pp. 81-93.
# 
#  Please refer to the publication above if you use this software. For an
#  up-to-date version go to:
#  
#            http://inf.ufrgs.br/~eslgastal/NonUniformFiltering/
#
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY EXPRESSED OR IMPLIED WARRANTIES
#  OF ANY KIND, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THIS SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THIS SOFTWARE.
#
#  Version 1.2 - November 17, 2015.

# Packages

using Colors
using PyCall
using PyPlot
using Images
using StatsBase

@pyimport scipy
@pyimport numpy as np
@pyimport scipy.misc as misc
@pyimport scipy.ndimage as ndimage
@pyimport scipy.signal as signal
@pyimport scipy.cluster as cluster
@pyimport IPython.display as ipdisplay
@pyimport skimage.filters as skfilter
@pyimport skimage.feature as skfeature

unshift!(PyVector(pyimport("sys")["path"]), dirname(@__FILE__))
@pyimport fig2data

include("matplotlib_settings.jl")

# In julia 0.4: float64(x::AbstractArray) is deprecated, use map(Float64,x) instead
float64(x::AbstractArray) = map(Float64, x)

# Includes
include("types.jl")
include("utils.jl")
include("filters.jl")
include("analytic.jl")
include("our_method.jl")
include("domain_transform.jl")
include("compute_non_local_means_basis.jl")

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
