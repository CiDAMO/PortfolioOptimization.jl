export cvar_model, cvar_model_min_risk, cvar_model_mixed

"""
    cvar_model_min_risk(df; options...)

Solve the CVaR model minimizing the risk, i.e.,

    min  CVaR(x)
    s.to μᵀx ≥ μmin + λ * (μmax - μmin)
         ∑ᵢ xᵢ = 1, x ≥ 0,

where `λ` is a keyword argument (defaults to 0.0).
"""
cvar_model_min_risk(df::DataFrame; kwargs...) = cvar_model(:min_risk, df, λ=0.0; kwargs...)

"""
    cvar_model_mixed(df; options...)

Solve the CVaR model minimizing a combination of the risk and return, i.e.,

    min  λ * CVaR(x) - (1 - λ) * μᵀx
    s.to ∑ᵢ xᵢ = 1, x ≥ 0,

where `λ` is a keyword argument (defaults to 0.5).
"""
cvar_model_mixed(df::DataFrame; kwargs...) = cvar_model(:mixed, df, λ=0.5; kwargs...)

"""
    cvar_model(objective_type, df; options...)
    cvar_model_min_risk(df; options...)
    cvar_model_mixed(df; options...)

Solve the CVaR model with objective type given by `objective_type`. See the
specific functions for more details.
- `:min_risk` = `cvar_model_min_risk`
- `:mixed` = `cvar_model_mixed`
"""
function cvar_model(objective_type::Symbol,
    df::DataFrame;
    num_assets::Integer = 0,
    min_percentage::Float64 = 0.0,
    λ::Float64 = 0.5,
    β::Float64 = 0.95,
    optimizer = if num_assets == 0
        optimizer_with_attributes(Clp.Optimizer, "LogLevel" => 0)
    else
        optimizer_with_attributes(Cbc.Optimizer, "LogLevel" => 0)
    end
)
    @assert 0 ≤ λ ≤ 1
    μ = mean.(eachcol(df))
    n = length(μ) # Number of assets
    m = size(df, 1) # number of days

    model = Model(optimizer)
    μmin, μmax = extrema(μ)

    @variable(model, α)
    @variable(model, x[1:n] ≥ 0)
    @variable(model, u[1:m] ≥ 0)
    if objective_type == :mixed
        @objective(model, Min, λ * α + sum(u) / m / (1 - β) - (1 - λ) * dot(x, μ))
    elseif objective_type == :min_risk
        @objective(model, Min, α + sum(u) / m / (1 - β))
        @constraint(model, dot(x, μ) ≥ μmin + (μmax - μmin) * λ)
    else
        throw(ArgumentError("Unexpected objective_type = `:$objective_type`"))
    end
    @constraint(model, sum(x) == 1)
    @constraint(model, [i=1:m], u[i] + α - sum(df[i,j] * x[j] for j = 1:n) ≥ 0)
    if num_assets > 0
        @variable(model, y[1:n], Bin)
        @constraint(model, [i=1:n],  x[i] <= y[i])
        @constraint(model, [j=1:n],  x[j] >= min_percentage * y[j])
        @constraint(model, sum(y) == num_assets)
    end
    optimize!(model)

    return value.(x)
end
