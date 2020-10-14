using JuMP, Cbc, Clp, Ipopt, CSV
using DataFrames
using Dates
using Statistics
using LinearAlgebra
using Gurobi

export Model, IniciateModel

#função só com o modelo
function Model(matrixCovar::AbstractMatrix, meanAssets::AbstractArray, allAssets::Integer, choiceAssets::Integer, minPerc::Float64, λ::Float64)
    
    model = Model(optimizer_with_attributes(() -> Gurobi.Optimizer(GRB_ENV), "OutputFlag" => 0))

    @variable(model, x[1:allAssets] ≥ 0)
    @variable(model, y[1:allAssets], Bin )  
 
    @objective(model, Min, λ * x' * matrixCovar * x - (1 - λ) * x' * meanAssets)

    @constraint(model, [i=1:allAssets],  x[i] <= y[i])
    @constraint(model, [j=1:allAssets],  x[j] >= minPerc * y[j])

    @constraint(model, sum(x) == 1)
    @constraint(model, sum(y) == choiceAssets)

    optimize!(model);

    return  value.(x),  value.(y)

end 

"""
Nessa função temos a inicialização de todas as variaveis (colocar numa struct??), aplicamos o modelo n vezes,
e criamos os vetores de retorno de cada portfolio e risco, assim como uma matiz com o nome dos ativos criados
e a porcentagem de capital alocado para cada ação.

Preciso criar tambem valores inicias para o caso do usuario não informar (esqueci como faz :( ))


"""
function IniciateModel(matrixReturn::AbstractMatrix , allAssets::Integer, asset::AbstractString, iteration::Integer, choiceAssets::Integer, percmin::Float64)

    meanAssets  = [mean(col) for col in eachcol(matrixReturn)]
    matrixCovar = cov( Matrix(matrixReturn) )

    λ           = range(0, 1, length = iteration)

    ret_data  = zeros(iteration)
    risk_data = zeros(iteration)
    sharpe    = zeros(iteration)

    matrixWeight  = zeros(allAssets, iteration)

    assetsPortfolio  = Matrix{Union{Nothing, String}}(nothing, choiceAssets, iteration)
    weightPortfolio  = zeros(choiceAssets, iteration)

    valor = 0
    cont2 = 1

    GRB_ENV = Gurobi.Env() 

    for k = 1:iteration

        x, y = Model(matrixCovar, meanAssets, allAssets, choiceAssets, percmin, λ[k])

        matrixWeight[:, k] = x

        ret_data[k]  = meanAssets' * x
        risk_data[k] = sqrt(x' * matrixCovar*x)
        sharpe[k]    =  ret_data[k] / risk_data[k]

        cont = 1

        for j = 1:allAssets
            
            if y[j] >=  0.9
                assetsPortfolio[cont,k] = asset[j]
                weightPortfolio[cont,k] = round(x[j]*100)
                cont = cont + 1
            end
        end

    end

    return ret_data, risk_data, assetsPortfolio, weightPortfolio

end
