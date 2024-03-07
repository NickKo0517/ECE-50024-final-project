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

function reconstruct_ab(ab_sampled, L; s=1000.0, r=3.0, n=3)
    w = (ab_sampled .!= 0) |> (_->any(_,3)) |> float64
    w = w + 1e-5

    k = ours_filt_image_edge_aware(cat(3, ab_sampled, w), design2Dgaussian, sigma_s=s, sigma_r=r, joint=L, dt_iterations=n)
    ab = k[:,:,1:2] ./ k[:,:,3]
    
    return ab
end

function L_ab_to_RGB(L, ab)
    return convert(Image{RGB}, colorim(cat(3, L, ab), "Lab")) |> imtoarray
end

function sample_ab(f; Nsamples=201)
    lab = convert(Image{Lab}, f) |> imtoarray

    dx, dy = imgradients(lab[:,:,1], "sobel")
    gradmag = sum(magnitude(dx, dy),3)[:,:,1]
    x = cumsum(gradmag, 2)
    x = x ./ x[:,end]

    sample_pos = linspace(0, 1, Nsamples)
    x = x .* Nsamples |> round
    x = diff(x,2)
    x = hcat(zeros(height(x)), x)

    delta = round(Int, height(x) / Nsamples)
    x[setdiff(collect(1:end),collect(1:delta:end)),:] = 0.0
    
    ab_sampled = copy(lab[:,:,2:3] .* x)
    
    perc = 100 * sum(x[:]) / width(f) / height(f)
    @printf "Kept only %.2f percent of samples.\n" perc
    flush(STDOUT)
    sleep(0.1)
    
    return ab_sampled, lab[:,:,1]
end

function plot_non_uniform_samples(ab_sampled)
    
    w = size(ab_sampled,2)
    h = size(ab_sampled,1)
    
    dpi = 96
    fig = figure(figsize=(w/dpi,h/dpi), dpi=dpi)

    idx = find(any(ab_sampled.!=0,3))
    Y, X = ind2sub( size(ab_sampled), idx )

    p(c) = sub(f,:,:,c)[idx][:]

    C = hcat(p(1), p(2), p(3))

    ioff()
    scatter(X, Y, c=C, lw=0, marker=".", s=5^2)
    xlim(0, w)
    ylim(h, 0)
    xticks([],[])
    yticks([],[])
    axis(:off)
    axis(:tight)
    tight_layout(pad=-2, rect=(-21/w,0,1+21/w,1))

    data = fig2data.fig2data(fig)
    data = float64(data[:,:,1:3])/255
    
    clf()
    ion()
    
    return data
end

# Load the image
filename = "images/DSC00497.jpg"
println("Filtering $filename...")
f = float64(ndimage.imread(filename)) / 255.0

# Convert the image to the Lab colorspace and perform NON-uniform
# sampling on its pixels based on the image's gradient magnitude.
ab_sampled, L = sample_ab(f, Nsamples=187)

# Reconstruct the image only from the non-uniform samples and
# the original Lightness channel
ab_rec = reconstruct_ab(ab_sampled, L, s=100.0, r=3.0)
g = L_ab_to_RGB(L, ab_rec)

# Compute the reconstruction PSNR
thepsnr = psnr(f,g,1.0)
@printf "Reconstruction PSNR: %.2f dB\n" thepsnr
flush(STDOUT)
sleep(0.1)

# Display the resulting image
normalize(x) = (x - minimum(x))/(maximum(x) - minimum(x))
non_uniform_samples = plot_non_uniform_samples(ab_sampled)
L3 = normalize(L)
L3 = cat(3, L3,L3,L3)
grid = vcat(hcat(f, L3), hcat(non_uniform_samples, g))

save_and_display_image(filename, "data_aware_interpolation", grid)

nothing

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
