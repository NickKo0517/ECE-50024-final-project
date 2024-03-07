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

function Fig_12_stylization()
    # Load image
    filename = "images/ku.png"
    f = float64(ndimage.imread(filename))/255.0
    println("Filtering $filename...")

    # Perform clustering in RGB colorspace
    V = hcat( f[:,:,1][:], f[:,:,2][:], f[:,:,3][:] )

    num_clusters = 4
    centroids, labels = cluster.vq[:kmeans2](V, num_clusters)

    labels = reshape(labels, size_spatial(f))

    # Perform filtering only among pixels belonging to the same clusters
    g = filter2d_percluster(f, labels, sigma=4.0)

    # Compute canny edges
    tmin = 0.1
    tmax = 0.3
    edges = skfeature.canny(sum(g,3)[:,:,1], sigma=3.0,
                            low_threshold=tmin,
                            high_threshold=tmax) |> np.float64
    edges = imfilter_gaussian(edges, [1,1])
    edges = edges / maximum(edges)
    edges = 1.0 - 2.5*edges
    edges = clamp(edges,0,1)

    # Overlay edges in the image
    g = clamp(g .* edges, 0,1)

    # Apply colormap to visualize k-means clusters
    cmapped_labels = apply_colormap(:jet, labels)

    # Display images
    grid = vcat(hcat(f,g), hcat(cmapped_labels,ones(size(f))))
    save_and_display_image(filename, "stylization", grid, filetype = ".png")
end

Fig_12_stylization()

nothing

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
