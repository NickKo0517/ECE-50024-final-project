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

include("Fig_11_and_12_detail.jl")

function Fig_11_denoising()
    # Load noisy image
    filename = "images/ku.png"
    f = float64(ndimage.imread(filename))/255.0
    println("Denoising $filename...")

    # Compute non-local means basis
    N = width(f)*height(f)
    Y, X = ind2sub(size_spatial(f), 1:N)
    X = reshape(X, size_spatial(f))
    Y = reshape(Y, size_spatial(f))
    maxwh = maximum(widthheight(f))

    # The parameter alpha controls the spatial regularity of the clusters
    alpha = 1.0
    F = cat(3, f, alpha*X/maxwh, alpha*Y/maxwh)
    H, Eval, C = compute_non_local_means_basis(F, radius=1, pca_outdim=6)

    V = H[:,:,1][:]

    for d = 2:size(H,3)
        V = hcat(V, H[:,:,d][:])
    end

    # Perform clustering in the non-local means space using k-means
    num_clusters = 30
    centroids, labels = cluster.vq[:kmeans2](V, num_clusters)

    labels = reshape(labels, size_spatial(f))

    # Perform filtering only among pixels belonging to the same clusters
    g = filter2d_percluster(f, labels, sigma=4.0)

    # Final low-pass filter on the whole image to remove
    # the discrete clustering quantization artifacts
    h = ours_filt_image_edge_aware(g, design2Dgaussian, sigma_s=10.0, sigma_r=0.2, joint=f)
    h = clamp(h,0,1)

    # Apply colormap to visualize k-means clusters
    cmapped_labels = apply_colormap(:jet, labels)

    # Display images
    grid = vcat(hcat(f,clamp(h,0,1)), hcat(cmapped_labels,ones(size(f))))
    save_and_display_image(filename, "denoising", grid, filetype = ".png")
end

Fig_11_denoising()

nothing

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
