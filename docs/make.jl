using Documenter, PortfolioOptimization

makedocs(
    sitename = "PortfolioOptimization.jl",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = ["assets/style.css"],
    )
)

deploydocs(
    repo = "github.com/CiDAMO/PortfolioOptimization.jl.git",
)