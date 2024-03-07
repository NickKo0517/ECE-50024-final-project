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

# Type definitions

abstract FilteringDirection
abstract Causal               <: FilteringDirection
abstract AnticausalInSeries   <: FilteringDirection
abstract AnticausalInParallel <: FilteringDirection

abstract BoundaryCondition
abstract Relaxed    <: BoundaryCondition
abstract Replicated <: BoundaryCondition

type TransferFunction{T<:Real}
    rpk :: Tuple{Vector{Complex{T}}, Vector{Complex{T}}, Vector{Complex{T}}}
end

TransferFunction(r,p,k) = TransferFunction( (copy(r),copy(p),copy(k)) )

function TransferFunction{T<:Real}( rpk::Tuple{Vector{T},Vector{T},Vector{T}} )
    TOut = Vector{Complex{T}}
    rpk = convert( Tuple{TOut,TOut,TOut}, rpk )
    return TransferFunction(rpk)
end

function TransferFunction{T<:Real}(numz::Vector{T}, denz::Vector{T})
    # Decompose the filter using partial-fraction expansion (§ 3.2.1)
    TOut = Vector{Complex128}
    r, p, k = signal.residuez(numz, denz) # TODO: rationalize
    rpk = convert( Tuple{TOut,TOut,TOut}, (r,p,k)) :: Tuple{TOut,TOut,TOut}
    return TransferFunction(rpk)
end

abstract InSeries
abstract InParallel
typealias FilterComposition Union{Type{InSeries},Type{InParallel}}

type DigitalFilter1D{T<:Real}
    tf_causal     :: TransferFunction{T}
    tf_anticausal :: TransferFunction{T}
    composition   :: FilterComposition
end

type DigitalFilter2D{T<:Real}
    filt_horz   :: DigitalFilter1D{T}
    filt_vert   :: DigitalFilter1D{T}
    composition :: FilterComposition
end

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
