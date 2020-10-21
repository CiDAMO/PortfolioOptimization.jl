function cvar()
    m = 100
    df = DataFrame(
        :A => range(-0.01, 0.01, length=m),
        :B => range(-0.01, 0.03, length=m)
    )

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
end

cvar()