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

include("deriche.jl")

# Filter design functions

function designgaussian(sigma::Real)
    # Compute filter coefficients
    a0, b0, a1, b1 = deriche_gaussian_4thorder(sigma)

    # Normalize filter to unit gain at zero frequency
    const gain0 = a0 / (one(b0) - b0)
    const gain1 = a1 / (one(b1) - b1)
    gain  = real(gain0 + gain1)
    gain += real(gain0*b0 + gain1*b1)
    a0 /= gain
    a1 /= gain

    r = [a0,a1] :: Vector{Complex128}
    p = [b0,b1] :: Vector{Complex128}
    k = Complex128[]
    tf = TransferFunction(r,p,k)

    return DigitalFilter1D(tf, tf, InParallel)
end

function design2Dgaussian(sigma::Real)
    filt1d = designgaussian(sigma)
    filt2d = DigitalFilter2D(filt1d, filt1d, InSeries)
    return filt2d
end

@pyimport scipy.optimize as optimize

# for a complex sequence h, compute the DTFT of real(h), which is equal to
# (H(z) + H*(z*)) / 2 where z = exp(1im*ω) and H = Z-transform{h} in residue
# (r,p,k) form. See scipy.signal.residuez for definition of this residue form.
function DTFTofrealpart(ω, r, p, k)
    @assert length(r) == length(p)

    h_hat(ω) = begin
        z = exp(1im*ω)
        s = complex(0.0)
        for i = 1:length(r)
            s += r[i] / (one(p[i]) - p[i]/z)
        end
        for i = 1:length(k)
            s += k[i] * z^(i - 1)
        end
        return s
    end

    return 0.5*( h_hat(ω) + conj(h_hat(-ω)) )
end

# Find frequency where Fourier transform hits maximum absolute value.
function DTFTmaximum(r, p, k, composition::FilterComposition)
    ϵ = 1e-6
    if composition === InSeries
        objective = ω->-abs(DTFTofrealpart(ω, r, p, k))
    else # if composition === InParallel
        objective = ω->-abs(DTFTofrealpart(ω, r, p, k) + DTFTofrealpart(ω, r.*p, p, k))
    end
    opt = optimize.minimize_scalar(objective, bounds=[ϵ,Float64(π)])
    ω = opt["x"] :: Float64
    return ω
end

# Normalize Causal+Anticausal filter to unit gain at ω frequency.
function DTFTnormalize(ω, r, p, k, composition::FilterComposition)
    gain = DTFTofrealpart(ω, r, p, k) |> abs
    if composition === InParallel
        gain += DTFTofrealpart(ω, r.*p, p, k) |> abs
    end
    r /= gain
    return r, p, k
end

function designgaussian1stderiv(sigma::Real)
    # Compute filter coefficients
    a0, b0, a1, b1 = deriche_gaussian_1st_derivative_4thorder(sigma)

    # Normalize filter to unit gain at π frequency
    r = [a0,a1] :: Vector{Complex128}
    p = [b0,b1] :: Vector{Complex128}
    k = Complex128[]

    const RT = Vector{Complex128}
    r, p, k = DTFTnormalize(π, r, p, k, InParallel) :: Tuple{RT,RT,RT}
    tf = TransferFunction(r,p,k)
    return DigitalFilter1D(tf, tf, InParallel)
end

function designgaussian2ndderiv(sigma::Real)
    # Compute filter coefficients
    a0, b0, a1, b1 = deriche_gaussian_2nd_derivative_4thorder(sigma)

    # Normalize filter to unit gain at its maximum
    r = [a0,a1] :: Vector{Complex128}
    p = [b0,b1] :: Vector{Complex128}
    k = Complex128[]

    ω = DTFTmaximum(r, p, k, InParallel)

    const RT = Vector{Complex128}
    r, p, k = DTFTnormalize(ω, r, p, k, InParallel) :: Tuple{RT,RT,RT}
    tf = TransferFunction(r,p,k)
    return DigitalFilter1D(tf, tf, InParallel)
end

function design2Dgaussian2ndderiv(sigma::Real)
    filt1d = designgaussian2ndderiv(sigma)
    filt2d = DigitalFilter2D(filt1d, filt1d, InParallel)
    return filt2d
end

sigma2cutoff(sigma::Real) = 1.0 / (abs(sigma) + 1.0)

function designbutterworth(sigma::Real; order::Int = 4, btype = "low")
    numz, denz = signal.butter(order, sigma2cutoff(sigma), btype=btype)
    # Already normalized
    tf1 = TransferFunction(numz, denz)
    tf2 = TransferFunction(numz, denz)
    const RT = Vector{Complex128}
    return DigitalFilter1D(tf1, tf2, InSeries)
end

function design2Dbutterworth(sigma::Real; order::Int = 4, btype = "low")
    filt1d1 = designbutterworth(sigma; order=order, btype=btype)
    filt1d2 = designbutterworth(sigma; order=order, btype=btype)
    filt2d = DigitalFilter2D(filt1d1, filt1d2, btype == "low" ? InSeries : InParallel)
    return filt2d
end

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
