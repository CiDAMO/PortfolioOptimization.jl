export returns

"""
    r = returns(p)

Computes the returns of the asset(s) in `p`, one asset per column.
For each asset/column `j` and each instant/row `i`, we define
```math
r_{ij} = \\frac{p_{i+1,j} - p_{ij}}{p_{ij}}.
```
"""
function returns(p :: AbstractVector)
    r = (p[2:end] .- p[1:end-1]) ./ p[1:end-1]
end

function returns(p :: AbstractMatrix)
    r = (p[2:end,:] .- p[1:end-1,:]) ./ p[1:end-1,:]
end