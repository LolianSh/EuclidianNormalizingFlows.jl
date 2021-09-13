using EuclidianNormalizingFlows
using Test

using Distributions, ForwardDiff

using EuclidianNormalizingFlows: JohnsonSU, JohnsonTrafo, JohnsonTrafoInv, johnsontrafo, johnsontrafo_inv, johnsontrafo_ladj, johnsontrafo_inv_ladj


@testset "JohnsonSU" begin
    K = rand(Normal(), 10^6)
    K_joh = johnsontrafo_inv.(K, -15,6.5,0,2.5);
    X = rand(JohnsonSU(-15,6.5,0,2.5), 10^6);

    @test isapprox(sum(abs.(sort(K_joh)))/10^6, sum(abs.(sort(X)))/10^6, rtol = 0.01)
    
    @test @inferred(johnsontrafo(0.5, 1, 2, 3, 4)) isa Float64
    @test @inferred(johnsontrafo_inv(0.5, 1, 2, 3, 4)) isa Float64

    @test johnsontrafo(0.3, 1, 3, -4, 0.5) ≈ 9.544817734776984
    @test johnsontrafo_inv(0.3, 1, 3, -4, 0.5) ≈ -4.1177281942392545

    Z = johnsontrafo_inv.(K, -2, 1, 0, 2.5)
    Z_reco = johnsontrafo.(Z, -2, 1, 0, 2.5)
    @test K ≈ Z_reco

    @test isapprox(@inferred(johnsontrafo_ladj(0.5, 4.2, 4, 2, 3)), log(abs(ForwardDiff.derivative(x -> johnsontrafo(x, 4.2, 4, 2, 3), 0.5))), rtol = 0.01)
    @test isapprox(@inferred(johnsontrafo_inv_ladj(0.5, 4.2, 4, 2, 3)), log(abs(ForwardDiff.derivative(x -> johnsontrafo_inv(x, 4.2, 4, 2, 3), 0.5))), rtol = 0.01)

    @test @inferred(JohnsonSU(4, 2, 3, 1)) isa JohnsonSU
    
    @test @inferred(JohnsonTrafo(4, 2, 3, 1)) isa JohnsonTrafo
    trafo = JohnsonTrafo(4, 2, 3, 1)
    @test @inferred(inv(trafo)) isa JohnsonTrafoInv
    @test @inferred(inv(inv(trafo))) === trafo
    
    @test @inferred(trafo(4.2)) == johnsontrafo(4.2, 4, 2, 3, 1)
    
    @test @inferred(JohnsonTrafo([4.0, 4.1], [3.0, 3.1], [2.0, 2.1], [1.0, 1.1])([0.5, 0.6], WithLADJ())) == (
        johnsontrafo.([0.5, 0.6], [4.0, 4.1], [3.0, 3.1], [2.0, 2.1], [1.0, 1.1]),
        sum(johnsontrafo_ladj.([0.5, 0.6], [4.0, 4.1], [3.0, 3.1], [2.0, 2.1], [1.0, 1.1])),
    )
    
    @test @inferred(JohnsonTrafoInv([4.0, 4.1], [3.0, 3.1], [2.0, 2.1], [1.0, 1.1])([0.5, 0.6], WithLADJ())) == (
        johnsontrafo_inv.([0.5, 0.6], [4.0, 4.1], [3.0, 3.1], [2.0, 2.1], [1.0, 1.1]),
        sum(johnsontrafo_inv_ladj.([0.5, 0.6], [4.0, 4.1], [3.0, 3.1], [2.0, 2.1], [1.0, 1.1])),
    )

    let
        fwd = JohnsonTrafo([10.0, 11.0], [3.5, 3.6], [10.0, 11.0], [1.0, 1.1])
        rev = inv(fwd)
        X = randn(2, 3)
        Y, ladjs = fwd(X, WithLADJ())
        @test hcat((getindex).(fwd.(eachcol(X), WithLADJ()), 1)...) == Y
        @test (getindex).(fwd.(eachcol(X), WithLADJ()), 2) == ladjs
        X2, inv_ladjs = rev(Y, WithLADJ())
        @test X2 ≈ X
        @test inv_ladjs ≈ - ladjs
    end
end