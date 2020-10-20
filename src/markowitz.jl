export markowitz, markowitz_min_risk, markowitz_max_returns, markowitz_mixed

"""
    markowitz_min_risk(μ, Σ; options...)

Solve the Markowitz mean-variance model minimizing the risk, i.e.,

    min  xᵀΣx
    s.to μᵀx ≥ μmin + λ * (μmax - μmin)
         ∑ᵢ xᵢ = 1, x ≥ 0,

where `λ` is a keyword argument (defaults to 0.0).
"""
markowitz_min_risk(μ::AbstractArray, Σ::AbstractMatrix; kwargs...) = markowitz(:min_risk, μ, Σ, λ=0.0; kwargs...)

"""
    markowitz_max_returns(μ, Σ; options...)

Solve the Markowitz mean-variance model maximizing the returns, i.e.,

    max  μᵀx
    s.to xᵀΣx ≤ σmin + λ * (σmax - σmin)
         ∑ᵢ xᵢ = 1, x ≥ 0,

where `λ` is a keyword argument (defaults to 1.0).
"""
markowitz_max_returns(μ::AbstractArray, Σ::AbstractMatrix; kwargs...) = markowitz(:max_returns, μ, Σ, λ=1.0; kwargs...)

"""
    markowitz_mixed(μ, Σ; options...)

Solve the Markowitz mean-variance model with the a mixed objective, i.e.,

    min  λ xᵀΣx / Σscale - (1 - λ) μᵀx / μscale
    s.to ∑ᵢ xᵢ = 1, x ≥ 0,

where `λ` is a keyword argument (defaults to 0.5).
"""
markowitz_mixed(μ::AbstractArray, Σ::AbstractMatrix; kwargs...) = markowitz(:mixed, μ, Σ, λ=0.5; kwargs...)

"""
    markowitz(objective_type, μ, Σ; options...)
    markowitz_max_returns(μ, Σ; options...)
    markowitz_min_risk(μ, Σ; options...)
    markowitz_mixed(μ, Σ; options...)

Solve the Markowitz mean-variance model with objective type given by `objective_type`. See the
specific functions for more details.
- `:max_returns` = `markowitz_max_returns`
- `:min_risk` = `markowitz_min_risk`
- `:mixed` = `markowitz_mixed`
"""
function markowitz(objective_type::Symbol,
    μ::AbstractArray,
    Σ::AbstractMatrix;
    num_assets::Integer = 0,
    min_percentage::Float64 = 0.0,
    λ::Float64 = 0.5,
    optimizer = num_assets == 0 ? Ipopt.Optimizer : Cbc.Optimizer
)
    @assert 0 ≤ λ ≤ 1
    n = length(μ) # Number of assets

    model = Model(optimizer)
    μmin, μmax = extrema(μ)
    σmin, σmax = extrema(diag(Σ))

    @variable(model, x[1:n] ≥ 0)
    if objective_type == :mixed
        @objective(model, Min, λ * dot(x, Σ, x) - (1 - λ) * dot(x, μ))
    elseif objective_type == :min_risk
        @objective(model, Min, dot(x, Σ, x))
        @constraint(model, dot(x, μ) ≥ μmin + (μmax - μmin) * λ)
    elseif objective_type == :max_returns
        @objective(model, Max, dot(x, μ))
        @constraint(model, dot(x, Σ, x) ≤ σmin + (σmax - σmin) * λ)
    else
        throw("Unexpected objective_type = $objective_type")
    end
    @constraint(model, sum(x) == 1)
    if num_assets > 0
        @variable(model, y[1:n], Bin)
        @constraint(model, [i=1:n],  x[i] <= y[i])
        @constraint(model, [j=1:n],  x[j] >= min_percentage * y[j])
        @constraint(model, sum(y) == num_assets)
    end
    optimize!(model)

    return value.(x)
end

# """
# Nessa função temos a inicialização de todas as variaveis (colocar numa struct??), aplicamos o modelo n vezes,
# e criamos os vetores de retorno de cada portfolio e risco, assim como uma matiz com o nome dos ativos criados
# e a porcentagem de capital alocado para cada ação.

# Preciso criar tambem valores inicias para o caso do usuario não informar (esqueci como faz :( ))


# """
# function IniciateModel(matrixReturn::AbstractMatrix , allAssets::Integer, asset::AbstractString, iteration::Integer, choiceAssets::Integer, percmin::Float64)

#     μ  = [mean(col) for col in eachcol(matrixReturn)]
#     Σ = cov( Matrix(matrixReturn) )

#     λ           = range(0, 1, length = iteration)

#     ret_data  = zeros(iteration)
#     risk_data = zeros(iteration)
#     sharpe    = zeros(iteration)

#     matrixWeight  = zeros(allAssets, iteration)

#     assetsPortfolio  = Matrix{Union{Nothing, String}}(nothing, choiceAssets, iteration)
#     weightPortfolio  = zeros(choiceAssets, iteration)

#     valor = 0
#     cont2 = 1

#     GRB_ENV = Gurobi.Env()

#     for k = 1:iteration

#         x, y = Model(μ, Σ, allAssets, choiceAssets, percmin, λ[k])

#         matrixWeight[:, k] = x

#         ret_data[k]  = μ' * x
#         risk_data[k] = sqrt(x' * Σ*x)
#         sharpe[k]    =  ret_data[k] / risk_data[k]

#         cont = 1

#         for j = 1:allAssets

#             if y[j] >=  0.9
#                 assetsPortfolio[cont,k] = asset[j]
#                 weightPortfolio[cont,k] = round(x[j]*100)
#                 cont = cont + 1
#             end
#         end

#     end

#     return ret_data, risk_data, assetsPortfolio, weightPortfolio

# end
