using CSV, Dates, DataFrames

#Essa função aqui me ajuda a testar. Ela vai sumir

function start()

    caminho = joinpath(@__DIR__, "..", "data", "b3-2015-2019.csv")
    base = CSV.read(caminho)

    date_start_treino = "2015-01-01"
    date_start_teste  = "2019-01-01"

    #eliminando as colunas com missing
    base = base[:, (eltype.(eachcol(base)) .== Float64) .| (eltype.(eachcol(base)) .== Date)]

    treino_assets = base[(base.Date .>= Date(date_start_treino)) .& (base.Date .< Date(date_start_teste)) , Not([:IBOV,:Date])]
    teste_assets = base[(base.Date .>= Date(date_start_teste)) , Not([:IBOV,:Date])]

    treino_ibov = base[(base.Date .>= Date(date_start_treino)) .& (base.Date .< Date(date_start_teste)) , :IBOV]
    teste_ibov = base[(base.Date .>= Date(date_start_teste)) , :IBOV]

    # Usando aquela função em auxiliary
    Matriz_Retorno = returns(Matrix(treino_assets))

    return Matriz_Retorno, ncol(treino_assets), names(treino_assets)


end

