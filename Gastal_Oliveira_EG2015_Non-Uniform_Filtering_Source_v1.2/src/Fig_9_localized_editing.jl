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

# Load input image and user scribbles
filename = "images/DSC02190.jpg"
imgname  = (filename |> basename |> splitext)[1]
imgext   = ".jpg"

println("Filtering $filename...")

scribbles_filename = joinpath(filename|>dirname, imgname * "_scribbles.png")

f = float64(ndimage.imread(filename)) / 255.0
m = float64(ndimage.imread(scribbles_filename)) / 255.0

# Extract the user scribbles into two images
m0 = (m[:,:,1].==1) & (m[:,:,2].!=1) & (m[:,:,3].!=1) & all(m.!=f,3)[:,:,1] |> float64
m1 = (m[:,:,1].!=1) & (m[:,:,2].!=1) & (m[:,:,3].==1) & all(m.!=f,3)[:,:,1] |> float64

# Convert the image to HSV colorspace, and perform
# a low-pass edge-aware Butterworth filter on the
# Value channel. 
hsv = convert(Image{HSV}, f)
value = imtoarray(hsv)[:,:,3]
j = ours_filt_image_edge_aware(value, design2Dbutterworth, sigma_s=20.0, sigma_r=0.2, dt_iterations=2)
j = clamp(j,0,1)

# Filter the user scribbles to generate two influence maps,
# one for each region of interest in the image.
s = 10.0
r = 0.2

m0g = ours_filt_image_edge_aware(m0, design2Dgaussian, joint=j,
                                 sigma_s=s, sigma_r=r, dt_iterations=2)

m1g = ours_filt_image_edge_aware(m1, design2Dgaussian, joint=j,
                                 sigma_s=s, sigma_r=r, dt_iterations=2)

# Use the influence maps to create a soft segmentation mask
mask = m0g ./ (m0g + m1g)
mask = clamp(mask,0,1)

# Change the hue color of the statue
hsv = Images.separate(hsv)
V = sub(hsv, :,:,1)
V[:] += 200
V[V .> 360] -= 360

# Change specularity of the statue
tmp = copy(hsv[:,:,3])
tmp /= tmp[79,799]
hsv[:,:,3] = clamp(tmp.^6 + hsv[:,:,3], 0, 1)
hsv[:,:,3] = clamp(hsv[:,:,3], 0, 1)

f_edited = convert(Image{RGB}, hsv) |> imtoarray

# Composite the final result using the mask
composite = broadcast(.*, mask, f_edited) + broadcast(.*, 1-mask, f)

# Save to disk and display the image
save_and_display_image(filename, "recoloring", hcat(m,composite))

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
