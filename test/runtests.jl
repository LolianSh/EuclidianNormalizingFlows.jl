# This file is a part of EuclidianNormalizingFlows.jl, licensed under the MIT License (MIT).

import Test

Test.@testset "Package EuclidianNormalizingFlows" begin
    include("test_householder_trafo.jl")
end # testset
