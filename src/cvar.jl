using JuMP, Cbc, Clp, Ipopt, CSV
using DataFrames
using Dates
using Statistics
using LinearAlgebra
using Gurobi

matrixReturn, allAssets, assets = start()

meanAssets = [mean(col) for col in eachcol(matrixReturn)]

iteration    = 10
numDays      = size(matrixReturn)[1]
choiceAssets = 5

λ            = range(0, 1, length = iteration)
β            = 0.95

matrixWeight  = zeros(allAssets, iteration)

assetsPortfolio  = Matrix{Union{Nothing, String}}(nothing, choiceAssets, iteration)
weightPortfolio  = zeros(choiceAssets, iteration)

valor = 0
cont  = 1
cont2 = 1

ret_data  = zeros(iteration)
risk_data = zeros(iteration)

const GRB_ENV = Gurobi.Env()

for k = 1:iteration
    
    
    #model = Model(Gurobi.Optimizer)
    model = Model(optimizer_with_attributes(() -> Gurobi.Optimizer(GRB_ENV), "OutputFlag" => 0))

    @variable(model, u[1:numDays] ≥ 0)
    @variable(model, x[1:allAssets] ≥ 0)
    @variable(model, y[1:allAssets], Bin)

    
    @variable(model, α )  

    @objective(model, Min,  ( α + ( 1 / ( numDays * ( 1 - β ))) * sum(u) )) 
    
    @constraint(model, [j = 1:numDays],  u[j] + α + x' * matrixReturn[j,:] >= 0)
    
    @constraint(model,  x' * meanAssets >= λ[k] * maximum(meanAssets) )

    @constraint(model, sum(x) == 1)
    @constraint(model, sum(y) == choiceAssets)
    
    @constraint(model, [i = 1:allAssets],  x[i] <= y[i])
    @constraint(model, [l = 1:allAssets],  x[l] >= 0.1*y[l])

    optimize!(model)

    x = value.(x)
    y = value.(y)
    
    ret_data[k]     = meanAssets' * x
    risk_data[k]   =  objective_value(model)

    cont = 1

    matrixWeight[:,k] = x

    for m = 1:allAssets

        if y[m] >=  0.9
            assetsPortfolio[cont, k]  = assets[m]
            weightPortfolio[cont, k]  = round(x[m]*100)
            cont = cont + 1
        end
    end
end
