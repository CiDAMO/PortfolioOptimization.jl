
function markowitz_test()
    μ = [0.0; 1.0]
    Σ = [0.5 0; 0 1]

    @testset "Markowitz" begin
        x = markowitz_min_risk(μ, Σ)
        @test x ≈ [2 / 3; 1 / 3]
        x = markowitz_min_risk(μ, Σ, λ = 1.0)
        @test x ≈ [0; 1]

        x = markowitz_max_returns(μ, Σ)
        @test x ≈ [0.0; 1.0]
        x = markowitz_max_returns(μ, Σ, λ = 0.0)
        @test x ≈ [1 / 3; 2 / 3]
        x = markowitz_max_returns(-μ, Σ)
        @test x ≈ [1.0; 0.0]

        x = markowitz_mixed(μ, Σ)
        @test x ≈ [1 / 3; 2 / 3]
        x = markowitz_mixed(μ, Σ, λ = 0.0)
        @test x ≈ [0.0; 1.0]
        x = markowitz_mixed(μ, Σ, λ = 1.0)
        @test x ≈ [2 / 3; 1 / 3]

        x = markowitz(:mixed, μ, Σ, num_assets=2, min_percentage=0.1, λ = 0.0)
        @test x ≈ [0.1; 0.9]

        @test_throws ArgumentError("Unexpected objective_type = `:none`") markowitz(:none, μ, Σ)
    end
end

markowitz_test()