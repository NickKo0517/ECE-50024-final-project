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

# Image transposes
transpose_image{T}(X::Array{T,3}) = permutedims(X, [2,1,3])
transpose_image{T}(X::Array{T,2}) = permutedims(X, [2,1])

# Fill array with zeros
zero!{T,N}(x::Array{T,N}) = fill!(x, zero(T))

# Perform FIR filtering
function filter_fir{T<:Real}(idata::Vector{T}, k::Vector{T})
    @assert length(k) <= 1
    if length(k) == 1
        odata = k[1] .* idata
    else
        odata = similar(idata)
        zero!(odata)
    end
    return odata
end

# We work directly on pointers since they are faster than julia's Arrays.
import Base.getindex
import Base.setindex!
getindex{T}(p::Ptr{T}, i::Integer) = unsafe_load(p, i)
setindex!{T}(p::Ptr{T}, x::T, i::Integer) = unsafe_store!(p, x, i)

# Convert Image representation to plain old array
imtoarray(img) = convert(Array{Float64}, separate(img).data)

# Save an image to disk and display it inside the notebook using HTML
function save_and_display_image(filename, id, img; filetype = ".jpg")
    imgname = (filename |> basename |> splitext)[1]
    outdir  = "filtered_images"
    @assert filetype == ".jpg" || filetype == ".png"
    imgext  = filetype

    outname = imgname * "_" * id * imgext
    outpath = joinpath(outdir, outname)
    outurl  = outdir * "/" * outname

    misc.imsave(outpath, img)

    # See http://stackoverflow.com/questions/126772/how-to-force-a-web-browser-not-to-cache-images
    t = time_ns()
    display("text/html",
        ipdisplay.HTML("""
            <a href="$outurl?$t" target="_blank"><img src="$outurl?$t" width="100%" /></a>
        """))

    nothing
end

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
