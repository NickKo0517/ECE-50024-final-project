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

function load_and_resize_image(filename)
    f = float64(ndimage.imread(filename)) / 255.0

    while maximum(size(f)) > 1300
        f = restrict(f, [1,2])
        f = f[2:end-1,2:end-1,:]
    end
    
    return f
end

function Fig_1_low_pass_gaussian(filenames; σ_s=50.0, σ_r=0.2)
    map(filenames) do filename
        #=println("Filtering $filename...")=#
        #=flush(STDOUT)=#
        f = load_and_resize_image(filename)
        g = ours_filt_image_edge_aware(f, design2Dgaussian, sigma_s=σ_s, sigma_r=σ_r, dt_iterations=3)

        save_and_display_image(filename, "low_pass_gaussian", hcat(f,g))
    end
    nothing
end

function Fig_1_modified_LoG(filenames; σ_s=50.0, σ_r=0.05)
    map(filenames) do filename
        #=println("Filtering $filename...")=#
        #=flush(STDOUT)=#
        f = load_and_resize_image(filename)
        g = ours_filt_image_edge_aware(f, design2Dgaussian2ndderiv, sigma_s=σ_s, sigma_r=σ_r, dt_iterations=1)

        save_and_display_image(filename, "modified_LoG", hcat(f,clamp(f+2.5*g,0,1)));
    end
    nothing
end

function Fig_1_high_pass_enhancer(filenames; σ_s=50.0, σ_r=0.5)
    map(filenames) do filename
        #=println("Filtering $filename...")=#
        #=flush(STDOUT)=#
        f = load_and_resize_image(filename)
        g = ours_filt_image_edge_aware(f, σ->design2Dbutterworth(σ, btype="high"), sigma_s=σ_s, sigma_r=σ_r, dt_iterations=1)

        save_and_display_image(filename, "high_pass_enhancer", hcat(f,clamp(f+2*g,0,1)));
    end
    nothing
end

function Fig_1_band_pass_enhancer(filenames; σ_s=200.0, σ_r=0.2)
    map(filenames) do filename
        #=println("Filtering $filename...")=#
        #=flush(STDOUT)=#
        f = load_and_resize_image(filename)
        
        designfilter(σ) = begin
            # Band-pass Butterworth filter designed using MATLAB
            r = 2*[-31.930970803102763255765239591710 + 1im*192.793031687332728552064509131014, 31.926508144618868101360931177624 + 1im*-259.368208777888980876014102250338 ]
            p = [0.998014316875285967256559160887 + 1im*0.013147111633910892047882867928, 0.997306488798127110939617523400 + 1im*0.017569788661128803858302305230 ]
            k = [1.008925361485778715575634123525 + 1im*0.000000000000000000000000000000 ]
            tf = TransferFunction(r,p,k)
            filt1d = DigitalFilter1D(tf, tf, InSeries)
            filt2d = DigitalFilter2D(filt1d, filt1d, InParallel)
            return filt2d
        end
        
        g = ours_filt_image_edge_aware(f, designfilter, sigma_s=σ_s, sigma_r=σ_r, dt_iterations=1)
        g = ours_filt_image_edge_aware(g, design2Dgaussian, joint=f, sigma_s=10.0, sigma_r=0.05, dt_iterations=2)

        save_and_display_image(filename, "band_pass_enhancer", hcat(f,clamp(f+6e-10*g,0,1)));
    end
    nothing
end

nothing

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
