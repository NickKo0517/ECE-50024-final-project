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

using Images

import Base.LinAlg.diff
diff{T<:Number}(x::Array{T,3}, dim) = cat(3, Any[diff(sub(x,:,:,c), dim) for c = 1:size(x,3)]...)

vector_norms(X, dim, p) = begin
    local Norms

    if p == Inf
        Norms = maximum(abs(X), dim)
    elseif p == -Inf
        Norms = minimum(abs(X), dim)
    else
        Norms = sum(abs(X).^p, dim).^inv(p)
    end

    return Norms
end

# The code below implements the Domain Transform for edge-aware filtering
# described in the following paper:
#
#   Domain Transform for Edge-Aware Image and Video Processing
#   Eduardo S. L. Gastal  and  Manuel M. Oliveira
#   ACM Transactions on Graphics. Volume 30 (2011), Number 4.
#   Proceedings of SIGGRAPH 2011, Article 69.
#

domain_transform{TData <: Real, Ndims}(
    idata :: Array{TData,Ndims},
    Σ     :: Matrix{TData};
    p     :: TData = 2*one(TData)
) = begin

    h, w = size(idata)[1:2]
    num_joint_channels = size(idata, 3)

    dx = diff(idata,2)
    dy = diff(idata,1)

    dx = padarray(dx, [0,1,0], [0,0,0], "value", 0)
    dy = padarray(dy, [1,0,0], [0,0,0], "value", 0)

    if Ndims === 3
        dx = permutedims(dx, [3,1,2])
        dy = permutedims(dy, [3,1,2])
    end
    dx = reshape(dx, num_joint_channels, h*w)
    dy = reshape(dy, num_joint_channels, h*w)

    Σ_x = Σ[[1;3:end], [1;3:end]]
    Σ_y = Σ[[2;3:end], [2;3:end]]

    dx = padarray(dx, [1,0], [0,0], "value", 1)
    dy = padarray(dy, [1,0], [0,0], "value", 1)

    dx = sqrt(inv(Σ_x)) * dx
    dy = sqrt(inv(Σ_y)) * dy

    σ_H_x = sqrt(Σ[1,1])
    σ_H_y = sqrt(Σ[2,2])

    dx = σ_H_x * vector_norms(dx, 1, p)
    dy = σ_H_y * vector_norms(dy, 1, p)

    dx = reshape(dx, h, w)
    dy = reshape(dy, h, w)

    pack(dx, dy) = (cumsum(dx,2), cumsum(dy,1), dx, dy)
    return pack(dx, dy)
end

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
