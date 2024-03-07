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

@pyimport video

function bgr2rgb!(frame)
    frame[:,:,1], frame[:,:,3] = frame[:,:,3], frame[:,:,1]
end

function video_high_pass_enhancement(;
    input_filename::String=""
)
    @assert length(input_filename) > 0

    vid = pycall(video.InOutVideo, PyAny, input_filename)
    num_frames = vid[:num_frames]
    w = vid[:w]

    i = 0
    while vid[:isOpened]()
        i += 1
        @printf "\nProcessing frame %d of %d..." i num_frames
        flush(STDOUT)

        input_frame = vid[:read]()
        bgr2rgb!(input_frame)

        frame = float64( copy(input_frame) )/255

        frame += 1.0*ours_filt_image_edge_aware(frame, σ->design2Dbutterworth(σ, btype="high"),
                                                sigma_s=50.0, sigma_r=0.5, dt_iterations=1)
        frame = clamp(frame,0,1)
        frame = uint8(frame*255|>floor)

        outname = @sprintf "videos/filtered_frame_%04d.jpg" i
        misc.imsave(outname, frame)

        dx = 1
        outname = @sprintf "videos/side_by_side_%04d.jpg" i
        m = div(w,2)
        frame[:,1:m,:] = input_frame[:,1:m,:]
        frame[:,m-dx:m+dx,:] = 255
        misc.imsave(outname, frame)
    end
    vid[:release]()
end

function video_encode(;
    filtered_filename::String="",
    sidebyside_filename::String=""
)
    @assert length(filtered_filename) > 0
    @assert length(sidebyside_filename) > 0

    @printf "Encoding filtered video using avconv...\n"
    run(`avconv -v quiet -y -r 24 -i videos/filtered_frame_%04d.jpg -c:v libvpx -crf 4 -b:v 20M -r 24 -an $filtered_filename`)

    @printf "Encoding side-by-side video using avconv...\n"
    fps = vid[:fps]
    run(`avconv -v quiet -y -r 24 -i videos/side_by_side_%04d.jpg   -c:v libvpx -crf 4 -b:v 20M -r 24 -an $sidebyside_filename`)
end

nothing
