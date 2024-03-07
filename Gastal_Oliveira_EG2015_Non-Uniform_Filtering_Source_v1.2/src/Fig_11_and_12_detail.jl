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

function lowpassfilter!(odata, idata, Δt, filt)
    const rc, pc, kc = filt.tf_causal.rpk
    const ra, pa, ka = filt.tf_anticausal.rpk
    for i = 1:length(rc)
        ours_1storder!(pointer(odata),
                       pointer(idata),
                       pointer(Δt),
                       rc[i], pc[i],
                       length(idata),
                       Causal,
                       Replicated)
        
        ours_1storder!(pointer(odata),
                       pointer(idata),
                       pointer(Δt),
                       ra[i], pa[i],
                       length(idata),
                       AnticausalInParallel,
                       Replicated)
    end
end

function filter_percluster(f::Array{Float64,3}, labels; sigma = 5.0)
    N = width(f)*height(f)
    Y, X = ind2sub(size_spatial(f), 1:N)
    
    X = reshape(X, size_spatial(f)) |> float64
    
    filt = designgaussian(sigma)

    g = similar(f)

    num_clusters = maximum(labels[:]) + 1
    
    buf = Array(Float64, (maximum(size_spatial(f)),))
    
    for row = 1:height(f)
        for i = 0:num_clusters - 1
            labelsrow = labels[row,:]
            cols = find(labelsrow .== i)
            t = X[row,cols] |> vec
            Δt = [1; diff(t)]::Vector{Float64}
            for c = 1:size(f,3)
                idata = f[row,cols,c] |> vec
                odata = similar(idata)
                zero!(odata)
                lowpassfilter!(odata, idata, Δt, filt)
                g[row,cols,c] = odata
            end
        end
    end
    
    return g
end

function filter2d_percluster(f, labels; sigma=4.0)
    g = filter_percluster(f, labels, sigma=sigma)
    g = transpose_image(g)
    l = transpose_image(labels)
    g = filter_percluster(g, l, sigma=sigma)
    g = transpose_image(g)
    return g
end

function apply_colormap(cmapname, labels)
    const cmap = get_cmap(cmapname)[:__call__]
    T = Float64
    const num_clusters = maximum(labels) + 1
    cmaptable = Array(Tuple{T,T,T,T}, (num_clusters,)) :: Vector{Tuple{T,T,T,T}}
    for i = 1:num_clusters
        cmaptable[i] = cmap( (i-1)/(num_clusters-1) )
    end
    local cmapped_labels = Array(Float64, (height(labels),width(labels),3))
    const cstride = stride(cmapped_labels,3)
    @inbounds for i = 1:length(labels)
        const cmapped_val = cmaptable[labels[i]+1]
        cmapped_labels[i + cstride*0] = cmapped_val[1]
        cmapped_labels[i + cstride*1] = cmapped_val[2]
        cmapped_labels[i + cstride*2] = cmapped_val[3]
    end
    return cmapped_labels
end

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
