using ColorTypes, FixedPointNumbers
using Test

@testset "rgb conversions with abstract types" begin
    c = RGB(1, 0.6, 0)
    @test convert(Colorant, c) === RGB{Float64}(1, 0.6, 0)
    @test convert(Colorant{N0f8}, c) === RGB{N0f8}(1, 0.6, 0)
    @test_broken convert(Colorant{Float32,3}, c) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, c) === RGB{Float64}(1, 0.6, 0)
    @test convert(Color{N0f8}, c) === RGB{N0f8}(1, 0.6, 0)
    @test convert(Color{Float32}, c) === RGB{Float32}(1, 0.6, 0)
    @test convert(AbstractRGB, c) === RGB{Float64}(1, 0.6, 0)
    @test convert(AbstractRGB{N0f8}, c) === RGB{N0f8}(1, 0.6, 0)
    @test_throws ErrorException convert(TransparentColor, c)
    @test_throws ErrorException convert(TransparentColor{RGB{N0f8}}, c)
    @test_throws ErrorException convert(TransparentColor{RGB{N0f8},N0f8}, c)
    @test_throws ErrorException convert(TransparentColor{RGB{N0f8},N0f8,2}, c)
    @test convert(AlphaColor, c) === ARGB{Float64}(1, 0.6, 0, 1)
    @test_broken convert(AlphaColor{RGB{N0f8}}, c) === ARGB{N0f8}(1, 0.6, 0, 1)
    @test convert(AlphaColor{RGB{N0f8},N0f8}, c) === ARGB{N0f8}(1, 0.6, 0, 1)
    @test convert(AlphaColor{RGB{N0f8},N0f8,4}, c) === ARGB{N0f8}(1, 0.6, 0, 1)
    @test convert(ColorAlpha, c) === RGBA{Float64}(1, 0.6, 0, 1)
    @test_broken convert(ColorAlpha{RGB{N0f8}}, c) === RGBA{N0f8}(1, 0.6, 0, 1)
    @test convert(ColorAlpha{RGB{N0f8},N0f8}, c) === RGBA{N0f8}(1, 0.6, 0, 1)
    @test convert(ColorAlpha{RGB{N0f8},N0f8,4}, c) === RGBA{N0f8}(1, 0.6, 0, 1)

    ac = ARGB(1, 0.6, 0, 0.8)
    @test convert(Colorant, ac) === ARGB{Float64}(1, 0.6, 0, 0.8)
    @test convert(Colorant{N0f8}, ac) === ARGB{N0f8}(1, 0.6, 0, 0.8)
    @test_broken convert(Colorant{Float32,3}, ac) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, ac) === RGB{Float64}(1, 0.6, 0)
    @test_broken convert(AbstractRGB, ac) === RGB{Float64}(1, 0.6, 0)
    @test_broken convert(AbstractRGB{N0f8}, ac) === RGB{N0f8}(1, 0.6, 0)
    @test convert(TransparentColor, ac) == ARGB{Float64}(1, 0.6, 0, 0.8)
    @test convert(AlphaColor, ac) === ARGB{Float64}(1, 0.6, 0, 0.8) # issue #126
    @test convert(ColorAlpha, ac) === RGBA{Float64}(1, 0.6, 0, 0.8) # issue #126

    ca = RGBA(1, 0.6, 0, 0.8)
    @test convert(Colorant, ca) === RGBA{Float64}(1, 0.6, 0, 0.8)
    @test convert(Colorant{N0f8}, ca) === RGBA{N0f8}(1, 0.6, 0, 0.8)
    @test_broken convert(Colorant{Float32,3}, ca) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, ca) === RGB{Float64}(1, 0.6, 0)
    @test_broken convert(AbstractRGB, ca) === RGB{Float64}(1, 0.6, 0)
    @test_broken convert(AbstractRGB{N0f8}, ca) === RGB{N0f8}(1, 0.6, 0)
    @test convert(TransparentColor, ca) == RGBA{Float64}(1, 0.6, 0, 0.8)
    @test convert(AlphaColor, ca) === ARGB{Float64}(1, 0.6, 0, 0.8) # issue #126
    @test convert(ColorAlpha, ca) === RGBA{Float64}(1, 0.6, 0, 0.8) # issue #126

    rgb24 = RGB24(1, 0.6, 0)
    @test convert(Colorant, rgb24) === RGB24(1, 0.6, 0)
    @test convert(Colorant{N0f8}, rgb24) === RGB24(1, 0.6, 0)
    @test_broken convert(Colorant{Float32,3}, rgb24) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, rgb24) === RGB24(1, 0.6, 0)
    @test convert(AbstractRGB, rgb24) === RGB24(1, 0.6, 0)
    @test convert(AbstractRGB{N0f8}, rgb24) === RGB24(1, 0.6, 0)
    @test_throws ErrorException convert(TransparentColor, rgb24)
    @test convert(AlphaColor, rgb24) === ARGB32(1, 0.6, 0, 1)
    @test_throws MethodError convert(ColorAlpha, rgb24)

    argb32 = ARGB32(1, 0.6, 0, 0.8)
    @test convert(Colorant, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test convert(Colorant{N0f8}, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test_broken convert(Colorant{Float32,3}, argb32) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, argb32) === RGB24(1, 0.6, 0)
    @test_broken convert(AbstractRGB, argb32) === RGB24(1, 0.6, 0)
    @test_broken convert(AbstractRGB{N0f8}, argb32) === RGB24(1, 0.6, 0)
    @test convert(TransparentColor, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test convert(AlphaColor, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test_throws MethodError convert(ColorAlpha, argb32)

    @test convert(AbstractARGB{RGB,N0f8}, c, 0.2) === ARGB{N0f8}(1, 0.6, 0, 0.2)
    @test convert(AbstractRGBA{RGB,N0f8}, c, 0.2) === RGBA{N0f8}(1, 0.6, 0, 0.2)
    @test_broken convert(AbstractARGB{RGB24,N0f8}, rgb24, 0.2) === ARGB32(1, 0.6, 0, 0.2)
    @test_throws MethodError convert(AbstractARGB{RGB,N0f8}, ac, 0.2)
    @test_throws MethodError convert(AbstractARGB{RGB,N0f8}, ca, 0.2)
    @test_throws ErrorException convert(AbstractARGB{RGB,N0f8}, rgb24, 0.2)
    @test_throws MethodError convert(AbstractARGB{RGB,N0f8}, argb32, 0.2)
end
