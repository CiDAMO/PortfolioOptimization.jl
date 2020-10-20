@testset "Auxiliary" begin
    price = [1.0; 1.0; 2.0; 1.0]
    r = [0.0; 1.0; -0.5]
    @test returns(price) ≈ r
    prices = [price 2price]
    @test returns(prices) ≈ [r r]
end