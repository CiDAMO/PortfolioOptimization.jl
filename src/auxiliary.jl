export returns

"""
    r = returns(p)

Computes the returns of the asset(s) in `p`, one asset per column.
For each asset/column `j` and each instant/row `i`, we define
```math
rᵢⱼ = (pᵢ₊₁,ⱼ - pᵢⱼ) / pᵢⱼ.
```
"""
function returns(p :: AbstractVector)
    r = (p[2:end] .- p[1:end-1]) ./ p[1:end-1]
end

function returns(p :: AbstractMatrix)
    r = (p[2:end,:] .- p[1:end-1,:]) ./ p[1:end-1,:]
end