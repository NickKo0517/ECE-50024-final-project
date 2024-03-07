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

# The code below implements the recursive coefficients for the Gaussian and its
# derivatives as computed by Deriche in the paper:
#
#    Deriche, Rachid. "Recursively implementating the Gaussian and its
#    derivatives." (1993): 24.
#

function deriche_gaussian_4thorder(sigma)
    const a0 = 1.68
    const a1 = 3.735
    const b0 = 1.783
    const w0 = 0.6318
    const c0 = 0.6803
    const c1 = 0.2598
    const b1 = 1.723
    const w1 = 1.997

    const alpha0  = complex(a0, a1)
    const alpha1  = complex(c0, c1)
    const lambda0 = complex(b0, w0)
    const lambda1 = complex(b1, w1)

    A0 = alpha0
    A1 = -alpha1

    B0 = exp( -lambda0 / sigma )
    B1 = exp( -lambda1 / sigma )

    return A0, B0, A1, B1
end

function deriche_gaussian_1st_derivative_4thorder(sigma)
    const a0 = -0.6472
    const a1 = -4.531
    const b0 = 1.527
    const w0 = 0.6719
    const c0 = 0.6494
    const c1 = 0.9557
    const b1 = 1.516
    const w1 = 2.072

    const alpha0  = a0 + a1 * 1im
    const alpha1  = c0 + c1 * 1im
    const lambda0 = b0 + w0 * 1im
    const lambda1 = b1 + w1 * 1im

    A0 = alpha0
    A1 = alpha1

    B0 = exp( -lambda0 / sigma )
    B1 = exp( -lambda1 / sigma )

    return A0, B0, A1, B1
end

function deriche_gaussian_2nd_derivative_4thorder(sigma)
    const a0 = -1.331
    const a1 = +3.661
    const b0 = 1.240
    const w0 = 0.748

    const c0 = +0.3225
    const c1 = -1.738
    const b1 = 1.314
    const w1 = 2.166

    const alpha0  = a0 + a1 * 1im
    const alpha1  = c0 + c1 * 1im
    const lambda0 = b0 + w0 * 1im
    const lambda1 = b1 + w1 * 1im

    A0 = alpha0
    A1 = alpha1

    B0 = exp( -lambda0 / sigma )
    B1 = exp( -lambda1 / sigma )

    return A0, B0, A1, B1
end

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
