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

function plot_impulse_response_with_psnr(
    name,
    tf::TransferFunction,
    xmax; Nsamples=div(xmax,4)
)
    # Create random sampling positions in [0:N-1]
    t = 1 + (xmax-2)*rand(Nsamples-2) # Create Nsamples positions in the range [2:N]
    t = [0.0; 1.0; t] # Fix the impulse position
    t = t |> sort |> unique # Remove repeated positions
    f_non_uniform = zeros(size(t))
    f_non_uniform[1] = 1.0
    
    # Compute the distances between subsequent samples
    Δt = [1.0; diff(t)] :: Vector{Float64}
    
    # Perform filtering using our approach
    g = ours_highorder(f_non_uniform, Δt, tf,
                       direction=Causal,
                       boundarycondition=Relaxed)
    
    # Compute ground-truth brute-force impulse response at uniform positions
    # for plotting
    a = groundtruth_brute_force_impulse_response(collect(0.0:xmax-1), tf)
    
    # Plot the results
    figure(figsize=(8,1))
    axhline(0, color="black")
    axvline(0, color="black", ymin=0)
    plot(0:xmax-1, a, color="royalblue")
    plot(t, g, color="orange", marker="o", ls="", markersize=6)
    xlim(xmin=-1)
    yticks([])
    xticks(t, [])
    
    # Compute ground-truth brute-force impulse response at NON-uniform
    # positions for computing the accuracy of our approach.
    a = groundtruth_brute_force_impulse_response(t, tf)
    
    maxval = max(maximum(a),maximum(g))
    thepsnr = psnr( a, g, maxval )
    title(@sprintf "%s, PSNR %.2f dB" name thepsnr)
end

σ = 20.0

gaussian = designgaussian(σ)
plot_impulse_response_with_psnr("Gaussian", gaussian.tf_causal, 100)

gaussianderiv = designgaussian1stderiv(σ)
plot_impulse_response_with_psnr("Gaussian 1st derivative", gaussianderiv.tf_causal, 100)

log = designgaussian2ndderiv(σ)
plot_impulse_response_with_psnr("Laplacian of Gaussian", log.tf_causal, 100)

plot_impulse_response_with_psnr("Decaying exponential", TransferFunction([1.0], [1.0, -0.95]), 100)

tf = TransferFunction(signal.cheby1(8, 5, 0.1)...)
plot_impulse_response_with_psnr("Chebyshev Type I low-pass", tf, 200)

# Band-pass Butterworth designed with MATLAB
r = [-1801.059770790529228179366327822208 + 1im*-904.148432321337622852297499775887, -1801.059770854720682109473273158073 + 1im*904.148432347037214640295132994652, -2554.067114208371094719041138887405 + 1im*914.061768128862922822008840739727, -2554.067114313411366310901939868927 + 1im*-914.061768132487713955924846231937, 1243.840599652786977458163164556026 + 1im*5286.160866626520146382972598075867, 1243.840599652786977458163164556026 + 1im*-5286.160866626520146382972598075867, 3111.091754444928028533468022942543 + 1im*-5311.610888351207904634065926074982, 3111.091754432160087162628769874573 + 1im*5311.610888194429207942448556423187, ]
p = [0.930791459319175729092421534006 + 1im*0.305831140263320089278664681842, 0.930791459319175729092421534006 + 1im*-0.305831140263320089278664681842, 0.882790368404198000362725906598 + 1im*0.408768268188834882348459132118, 0.882790368404198000362725906598 + 1im*-0.408768268188834882348459132118, 0.891387984990748893920908813016 + 1im*0.319561016135798792170419346803, 0.891387984990748893920908813016 + 1im*-0.319561016135798792170419346803, 0.868578425037465073899056733353 + 1im*0.359606979068075038874496840435, 0.868578425037465073899056733353 + 1im*-0.359606979068075038874496840435, ]
k = [1.389061890196454651658086731913 + 1im*0.000000000000000000000000000000, ]
tf = TransferFunction(r,p,k)
plot_impulse_response_with_psnr("Butterworth band-pass", tf, 200)

tf = TransferFunction(signal.ellip(8, 5, 40, 1/20, btype="high")...)
plot_impulse_response_with_psnr("Cauer high-pass", tf, 100)

nothing

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
