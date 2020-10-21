function cvar_test()
    m = 100
    df = DataFrame(
        :A => range(-0.01, 0.01, length=m),
        :B => range(-0.01, 0.03, length=m)
    )

    @testset "CVaR" begin
        x = cvar_model_min_risk(df)
        @test x ≈ [1.0; 0.0]
        x = cvar_model_min_risk(df, λ = 1.0)
        @test x ≈ [0; 1]

        x = cvar_model_mixed(df, λ = 0.5)
        @test x ≈ [1.0; 0.0]
        x = cvar_model_mixed(df, λ = 0.0)
        @test x ≈ [0.0; 1.0]
        x = cvar_model_mixed(df, λ = 1.0)
        @test x ≈ [1.0; 0.0]

        x = cvar_model(:mixed, df, num_assets=2, min_percentage=0.1, λ = 0.5)
        @test x ≈ [0.9; 0.1]

        @test_throws ArgumentError("Unexpected objective_type = `:none`") cvar_model(:none, df)
    end
end

cvar_test()