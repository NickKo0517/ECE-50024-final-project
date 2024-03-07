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

PyDict(matplotlib["rcParams"])["font.size"        ] = 14
PyDict(matplotlib["rcParams"])["font.family"      ] = "serif"
PyDict(matplotlib["rcParams"])["lines.linewidth"  ] = 2.0
PyDict(matplotlib["rcParams"])["patch.linewidth"  ] = 1.0
PyDict(matplotlib["rcParams"])["axes.color_cycle" ] = ["#4c72b0", "#55a868", "#c44e52", "#8172b2", "#ccb974", "#64b5cd"]
PyDict(matplotlib["rcParams"])["axes.grid"        ] = true
PyDict(matplotlib["rcParams"])["axes.axisbelow"   ] = true
PyDict(matplotlib["rcParams"])["axes.facecolor"   ] = "#f7f7f7"
PyDict(matplotlib["rcParams"])["axes.edgecolor"   ] = "#bcbcbc"
PyDict(matplotlib["rcParams"])["axes.labelsize"   ] = "medium"
PyDict(matplotlib["rcParams"])["axes.titlesize"   ] = "large"
PyDict(matplotlib["rcParams"])["xtick.major.size" ] = 0
PyDict(matplotlib["rcParams"])["xtick.minor.size" ] = 0
PyDict(matplotlib["rcParams"])["xtick.major.pad"  ] = 10
PyDict(matplotlib["rcParams"])["xtick.minor.pad"  ] = 10
PyDict(matplotlib["rcParams"])["xtick.direction"  ] = "out"
PyDict(matplotlib["rcParams"])["xtick.color"      ] = "#555555"
PyDict(matplotlib["rcParams"])["xtick.labelsize"  ] = "x-small"
PyDict(matplotlib["rcParams"])["ytick.major.size" ] = 0
PyDict(matplotlib["rcParams"])["ytick.minor.size" ] = 0
PyDict(matplotlib["rcParams"])["ytick.major.pad"  ] = 10
PyDict(matplotlib["rcParams"])["ytick.minor.pad"  ] = 10
PyDict(matplotlib["rcParams"])["ytick.direction"  ] = "out"
PyDict(matplotlib["rcParams"])["ytick.color"      ] = "#555555"
PyDict(matplotlib["rcParams"])["ytick.labelsize"  ] = "x-small"
PyDict(matplotlib["rcParams"])["figure.figsize"   ] = (12,4)
PyDict(matplotlib["rcParams"])["figure.facecolor" ] = "#ffffff"
PyDict(matplotlib["rcParams"])["legend.fontsize"  ] = "small"

nothing

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
