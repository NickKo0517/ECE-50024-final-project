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

groundtruth_brute_force_impulse_response{TData <: Real, TCoef <: Number}(
    t :: Vector{TData},
    a :: TCoef,
    b :: TCoef
) = begin

    # Alloc output buffer
    odata = similar(t, TCoef)
    zero!(odata)

    # Compute the impulse response 
    for i = 1:length(t)
        odata[i] = a * b.^t[i]
    end

    return odata
end

groundtruth_brute_force_impulse_response{TData <: Real}(
    t  :: Vector{TData},
    tf :: TransferFunction{TData}
) = begin

    # Get the filter's partial-fraction expansion (§ 3.2.1)
    r, p, k = tf.rpk

    # Alloc output buffer
    odata = similar(t)
    zero!(odata)

    # Perform all filters in parallel
    for i = 1:length(r)
        odata += real( groundtruth_brute_force_impulse_response(t, r[i], p[i]) )
    end

    # Perform the FIR filter
    odata += filter_fir([1.0; zeros(length(t) - 1)], real(k))

    return odata
end

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
