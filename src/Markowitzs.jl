using JuMP, Cbc, Clp, Ipopt, CSV
using DataFrames
using Dates
using Statistics
using LinearAlgebra
using Gurobi

include("settings.jl")

matrixReturn, allAssets, asset = start()

meanAssets  = [mean(col) for col in eachcol(matrixReturn)]
matrixCovar = cov( Matrix(matrixReturn) )

iteration    = 10
choiceAssets = 5
λ            = range(0, 1, length = iteration)

ret_data  = zeros(iteration)
risk_data = zeros(iteration)
sharpe    = zeros(iteration)

matrixWeight  = zeros(allAssets, iteration)

assetsPortfolio  = Matrix{Union{Nothing, String}}(nothing, choiceAssets, iteration)
weightPortfolio  = zeros(choiceAssets, iteration)

valor = 0
cont2 = 1

const GRB_ENV = Gurobi.Env() 

for k = 1:iteration

    model = Model(optimizer_with_attributes(() -> Gurobi.Optimizer(GRB_ENV), "OutputFlag" => 0))

    @variable(model, x[1:allAssets] ≥ 0)
    @variable(model, y[1:allAssets], Bin )  
 
    @objective(model, Min, λ[k] * x' *matrixCovar*x - (1 - λ[k])* x' *meanAssets)

    @constraint(model, [i=1:allAssets],  x[i] <= y[i])
    @constraint(model, [j=1:allAssets],  x[j] >= 0.1*y[j])

    @constraint(model, sum(x) == 1)
    @constraint(model, sum(y) == choiceAssets)

    optimize!(model);

    matrixWeight[:,k] = value.(x)

    x = value.(x)
    y = value.(y)
    
    ret_data[k]  = meanAssets' * x
    risk_data[k] = sqrt(x' * matrixCovar*x)
    sharpe[k]    =  ret_data[k] / risk_data[k]
    
    cont = 1

    for j = 1:allAssets
        
        if y[j] >=  0.9

            assetsPortfolio[cont,k] = assets[j]
            weightPortfolio[cont,k] = round(x[j]*100)
            cont = cont + 1
        end
    end
    
    #if sharpe[k] > valor
    #    valor = sharpe[k]
    #    cont2 = k
    #end 
 
    
    
end