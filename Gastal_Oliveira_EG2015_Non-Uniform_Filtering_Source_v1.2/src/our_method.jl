#
#  This file 'our_method.jl' implements the core equations of our discrete-time
#  formulation for applying arbitrary recursive digital filters to non-uniformly
#  sampled signals. The code is commented with pointers to the equations of our
#  paper.  Please see the README.txt file for instructions.
#

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


# This function implements Eq. 8 of our paper: it applies a 1st-order digital
# filter to a non-uniformly sampled signal. To apply arbitrary high-order digital
# filters, see the function 'ours_highorder' below.
#
# The applied digital filter depends on the Direction parameter as shown
# on the table below:
#
#      Causal         |  AnticausalInSeries  |  AnticausalInParallel
#                     |                      |
#            a        |              a       |             a*b*z     
# H(z) = ----------   |   H(z) = ---------   |    H(z) = ---------
#        1 - b*z^-1   |           1 - b*z    |            1 - b*z
#                     |                      |
#
ours_1storder!{
    TData <: Real,
    TCoef <: Number,
    Direction <: FilteringDirection,
    BoundaryCond <: BoundaryCondition
}(
    # Outputs
    odata :: Ptr{TData}, # Output samples. The result is **added** to the odata
                         # array, so it must be zeroed before calling this
                         # function.
    # Inputs
    idata :: Ptr{TData}, # Input samples
    Δt    :: Ptr{TData}, # Sampling position deltas
    a     :: TCoef, # Filter numerator coefficient
    b     :: TCoef, # Filter pole, must satisfy abs(b) < 1
    N     :: Int64, # Number of input samples
          :: Type{Direction}, # One of: Causal, AnticausalInSeries, AnticausalInParallel
          :: Type{BoundaryCond} # One of: Relaxed, Replicated
) = @inbounds begin

    # Some precomputed values from Eq. 10
    const one_over_r0 = (one(TCoef) / ( (b - one(TCoef))*(b - one(TCoef)) / (a*b) )) :: TCoef
    const r1 = (a / (b - one(TCoef))) :: TCoef

    # Compute initial conditions
    if Direction === Causal || Direction === AnticausalInSeries
        const β = (a / (one(TCoef) - b)) :: TCoef;
    else
        const β = (b * a / (one(TCoef) - b)) :: TCoef;
    end

    if BoundaryCond === Relaxed
        f_k_minus_1 = zero(TData) :: TData
        g_k_minus_1 = zero(TCoef) :: TCoef
    else
        f_k_minus_1 = idata[Direction === Causal ? 1 : N] :: TData
        g_k_minus_1 = β * convert(TCoef, f_k_minus_1) :: TCoef
    end

    if Direction === Causal
        datarange = 1:1:N
    else
        datarange = N:-1:1
    end

    # Main filtering loop
    for i = datarange
        if Direction === Causal
            const Δt_k = Δt[i] :: TData
        else
            if i+1 <= N # Avoid reading out-of-bounds value
                const Δt_k = Δt[i+1] :: TData
            else
                const Δt_k = one(TData) :: TData
            end
        end

        const b_exp_Δt = (b ^ Δt_k) :: TCoef
        const f_k = idata[i] :: TData
        # The following two lines implement Eq. 10
        const Q_k = (b_exp_Δt - one(TCoef)) * one_over_r0 * (one(TCoef) / Δt_k) :: TCoef
        const Φ_k = ((Q_k - r1*b)*f_k - (Q_k - r1*b_exp_Δt)*f_k_minus_1) :: TCoef

        if Direction === Causal || Direction === AnticausalInSeries
            # Eq. 8
            const g_k = a*f_k + b_exp_Δt*g_k_minus_1 + Φ_k :: TCoef
        else
            # Eq. 19 with normalization term ϕ_k
            const g_k = a*b_exp_Δt*f_k_minus_1 + b_exp_Δt*g_k_minus_1 + Φ_k :: TCoef
        end

        # Drop the imaginary part and write output sample
        odata[i] += real(g_k) :: TData

        f_k_minus_1 = f_k :: TData
        g_k_minus_1 = g_k :: TCoef
    end
end


# This function implements Eq. 5 of our paper: it applies a high-order digital
# filter to a non-uniformly sampled signal by decomposing it into 1st-order
# filters. The partial-fraction decomposition is computed in the file
# 'types.jl', line 18, using SciPy's residuez() routine.
#
ours_highorder{
    TData <: Real,
    Direction <: FilteringDirection,
    BoundaryCond <: BoundaryCondition
}(
    idata :: Vector{TData},
    Δt    :: Vector{TData},
    tf    :: TransferFunction{TData};
    ######################
    direction         :: Type{Direction}    = Causal,
    boundarycondition :: Type{BoundaryCond} = Relaxed
) = begin

    # Get the filter's partial-fraction expansion (§ 3.2.1)
    r, p, k = tf.rpk

    # Allocate output buffer
    odata = similar(idata)
    fill!(odata, zero(TData))

    # Perform all filters in parallel (Eq. 5 of our paper)
    psrc = pointer(idata)
    pdst = pointer(odata)
    pΔt  = pointer(Δt)
    N    = length(idata)
    @inbounds for i = 1:length(r)
        ours_1storder!(pdst, psrc, pΔt, r[i], p[i], N, Direction, BoundaryCond)
    end

    # Perform the FIR filter
    odata += filter_fir(idata, real(k))

    return odata
end

# Independently apply a digital filter to all columns of an image
ours_filt_cols!{
    TData <: Real,
    NDims
}(
    # Outputs
    odata :: Array{TData,NDims},
    # Inputs
    idata :: Array{TData,NDims},
    Δt    :: Array{TData,2},
    filt  :: DigitalFilter1D{TData}
) = @inbounds begin

    zero!(odata)

    const w = width(idata)
    const h = height(idata)
    const hstride_in_bytes = stride(idata,2) * sizeof(TData)
    const num_channels = size(idata,3)

    buffer = Array(TData, (h,))

    psrc = pointer(idata)
    pdst = pointer(odata)
    pbuf = pointer(buffer)

    for c = 1:num_channels
        pΔt = pointer(Δt)
        for col = 1:w
            ##### Causal pass
            begin
                const r, p, k = filt.tf_causal.rpk
                for i = 1:length(r)
                    ours_1storder!(pdst, psrc, pΔt, r[i], p[i], h, Causal, Replicated)
                end
                if length(k) > 0
                    const kr = real(k[1])::TData
                    for row = 1:h
                        pdst[row] += psrc[row] * kr
                    end
                end
            end

            ##### Anticausal pass
            if filt.composition === InParallel
                const r, p, k = filt.tf_anticausal.rpk
                for i = 1:length(r)
                    ours_1storder!(pdst, psrc, pΔt, r[i], p[i], h, AnticausalInParallel, Replicated)
                end
            else # filt.composition === InSeries
                const r, p, k = filt.tf_anticausal.rpk
                zero!(buffer)
                for i = 1:length(r)
                    ours_1storder!(pbuf, pdst, pΔt, r[i], p[i], h, AnticausalInSeries, Replicated)
                end
                if length(k) > 0
                    const kr = real(k[1])::TData
                    for row = 1:h
                        pbuf[row] += pdst[row] * kr
                    end
                end
                for i = 1:h
                    pdst[i] = pbuf[i]
                end
            end
            psrc += hstride_in_bytes
            pdst += hstride_in_bytes
            pΔt  += hstride_in_bytes
        end
    end
end

# Filters 2D images using left+right followed by top+bottom filtering
ours_filt_image{
    TData <: Real,
    NDims
}(
    idata :: Array{TData,NDims},
    Δt_x  :: Array{TData,2},
    Δt_y  :: Array{TData,2},
    filt  :: DigitalFilter2D{TData}
) = @inbounds begin

    const h = size(idata,1)
    const w = size(idata,2)
    const num_channels = size(idata,3)

    # Alloc output
    buffer = similar(idata)
    if NDims == 3
        odata = Array(TData, (w,h,num_channels)) # odata is built transposed
    else
        odata = Array(TData, (w,h)) # odata is built transposed
    end

    # Vertical filter
    ours_filt_cols!(buffer, idata, Δt_y, filt.filt_vert)

    # Horizontal filter (along rows) is performed by tranposing the image and
    # filtering again along columns. Note that a specialized implementation of
    # a horizontal-along-rows filter is much faster than this lazy implementation.
    Δt_x = transpose_image(Δt_x)
    if filt.composition === InSeries
        buffer = transpose_image(buffer)
        ours_filt_cols!(odata, buffer, Δt_x, filt.filt_horz)
        odata = transpose_image(odata)
    else # filt.composition === InParallel
        idata = transpose_image(idata)
        ours_filt_cols!(odata, idata, Δt_x, filt.filt_horz)
        odata = transpose_image(odata)
        odata += buffer
    end

    return odata
end

# This function implements edge-aware evaluation of arbitrary recursive digital
# filters. Non-uniform sampling positions are computed using the domain
# transform~[GO11] described in Eq. 21 of our paper.
ours_filt_image_edge_aware{
    TData <: Real,
    NDims,
    NDimsJoint
}(
    idata        :: Array{TData,NDims},
    designfilter :: Function;
    ######################
    joint :: Array{TData,NDimsJoint} = idata,
    ######################
    sigma_s :: TData = 10.0,
    sigma_r :: TData = 0.1,
    ######################
    dt_iterations :: Int64 = 3
) = @inbounds begin

    odata = copy(idata)

    # Precompute the domain transform (Eq. 21 of our paper)
    const σ_s = sigma_s
    const σ_r = sigma_r
    const Σ = diagm([σ_s; σ_s; repmat([σ_r],size(joint,3))].^2)
    const Δt_x, Δt_y = domain_transform(joint, Σ)[3:4]

    # Perform filtering
    for i = 0:dt_iterations - 1
        # See the original work of Gastal and Oliveira 2011~[GO11] for
        # details on this filtering loop and equation:
        #
        #   Domain Transform for Edge-Aware Image and Video Processing
        #   Eduardo S. L. Gastal  and  Manuel M. Oliveira
        #   ACM Transactions on Graphics. Volume 30 (2011), Number 4.
        #   Proceedings of SIGGRAPH 2011, Article 69.
        #
        const σ_H_i = σ_s * sqrt(3) * 2^(dt_iterations - (i + 1)) / sqrt(4^dt_iterations - 1)

        # Compute filter coefficients.
        filt2d = designfilter(σ_H_i) :: DigitalFilter2D{TData}

        # Perform filtering
        odata = ours_filt_image(odata, Δt_x, Δt_y, filt2d)
    end

    return odata
end

# vim: set tabstop=4 shiftwidth=4 expandtab foldmethod=manual :
