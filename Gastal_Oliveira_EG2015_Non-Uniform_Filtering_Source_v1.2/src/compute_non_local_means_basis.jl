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

function compute_non_local_means_basis(I; radius = 1, pca_outdim = 0)

@assert radius > 0
@assert pca_outdim >= 0

h, w, nc = size(I)

nneighbors = (2*radius + 1)^2

H = zeros(h, w, nneighbors*nc)

n = 1

I = broadcast(-, I, mean(I, [1,2]))

for i = -radius:radius
    for j = -radius:radius
        dist2  = i^2 + j^2
        weight = exp(-dist2 / 2 / (radius / 2))
        C = circshift(I, [i j])
        H[:,:, nc*(n-1)+1:nc*n] = C * weight
        n = n + 1
    end
end

Eval = []
C    = []

if pca_outdim > 0
    H = reshape(H, (h*w, nneighbors*nc))
    H = broadcast(-, H, mean(H,1))
    
    Eval, Evec = eig( H'*H )

    Evec = flipdim(Evec, 2)

    Eval = flipdim(diagm(Eval),1)'
    Eval = Eval[1:pca_outdim]

    C = reshape( H, (h,w,nneighbors*nc) )
    H = reshape( H*Evec[:,1:pca_outdim], (h,w,pca_outdim) )
end

return H, Eval, C

end

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
