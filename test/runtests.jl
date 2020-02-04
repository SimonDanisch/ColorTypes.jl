using ColorTypes, FixedPointNumbers
using Test

@testset "ColorTypes" begin

@test isempty(detect_ambiguities(ColorTypes, Base, Core))

@testset "show" begin
    include("show.jl")
end

@testset "traits" begin
    include("traits.jl")
end

@testset "types" begin
    include("types.jl")
end

@test ColorTypes.to_top(AGray32(.8)) == ColorTypes.Colorant{FixedPointNumbers.Normed{UInt8,8},2}

# This tests the same thing as the last, but in a user-observable way
let a = Array{Gray}(undef, 1)
    a[1] = Gray(0)
    a[1] = 1
    @test a[1] === Gray(1)
end

for C in ColorTypes.parametric3
    @test eltype(C{Float32}) == Float32
    et = (C <: AbstractRGB) ? N0f8 : Float32
    @test color_type(C(1,0,0)) == C{et}
    @test color_type(C) == C
    @test color_type(C{Float32}) == C{Float32}
    @test eltype(C{Float32}(1,0,0)) == Float32
end

for C in filter(T -> T <: AbstractRGB, ColorTypes.parametric3)
    for val1 in (0.2, 0.2f0, N0f8(0.2), N4f12(0.2), N0f16(0.2))
        for val2 in (0.2, 0.2f0, N0f8(0.2), N4f12(0.2), N0f16(0.2))
            c = C(val1,val2,val1)
            @test alphacolor(c, 0.2) === alphacolor(C)(val1,val2,val1,convert(eltype(c), 0.2))
            @test coloralpha(c, 0.2) === coloralpha(C)(val1,val2,val1,convert(eltype(c), 0.2))
        end
    end
end

@testset "Test some Gray stuff" begin
    c = Gray(0.8)
    @test real(c) == 0.8
    c = convert(Gray, 0.8)
    @test c === Gray{Float64}(0.8)

    ac = convert(AGray, c)
    @test ac === AGray{Float64}(0.8, 1.0)
    ac = AGray(c)
    @test ac === AGray{Float64}(0.8, 1.0)
    ac = AGray{Float64}(c)
    @test ac === AGray{Float64}(0.8, 1.0)
    ca = GrayA{Float64}(ac)
    @test ca === GrayA{Float64}(0.8, 1.0)

    c = AGray(0.8)
    @test color(c) == Gray(0.8)
end

# Transparency
@test alphacolor(Gray24(.2), .8) == AGray32(.2,.8)
@test alphacolor(RGB24(1,0,0), .8) == ARGB32(1,0,0,.8)
@test alphacolor(RGB(1,0,0), .8) == ARGB{N0f8}(1,0,0,.8)
@test coloralpha(RGB(1,0,0), .8) == RGBA{N0f8}(1,0,0,.8)
@test alphacolor(RGBA(1,0,0,.8)) == ARGB{Float64}(1,0,0,.8)
@test coloralpha(ARGB(1,0,0,.8)) == RGBA{Float64}(1,0,0,.8)
@test alphacolor(RGBA(1,0,0,.8)) == ARGB{Float64}(1,0,0,.8)
@test coloralpha(ARGB(1,0,0,.8)) == RGBA{Float64}(1,0,0,.8)
for C in setdiff(ColorTypes.parametric3, [XRGB,RGBX])
    for A in (alphacolor(C), coloralpha(C))
        @test eltype(A{Float32}) == Float32
        @test color_type(A) == C
        @test color_type(A{Float32}) == C{Float32}
        @test eltype(A(1,0.8,0.6,0.4)) == Float64
        c = A{Float64}(1,0.8,0.6,0.4)
        @test color_type(c) == C{Float64}
        cc = color(c)
        @test cc == C{Float64}(1,0.8,0.6)
        @test A(cc) == A{Float64}(1,0.8,0.6,1)
        @test A(cc, 0.4)  == c
        @test A(cc, 0x01) == A{Float64}(1,0.8,0.6,1)
        @test A{Float32}(cc, 0x01) == A{Float32}(1,0.8,0.6,1)
        @test C(c         ) == C{Float64}(1,0.8,0.6)
        @test C{Float32}(c) == C{Float32}(1,0.8,0.6)
        @test convert(A, cc) == A{Float64}(1,0.8,0.6,1)
        @test A(cc) === A{Float64}(1,0.8,0.6,1)
        @test A{Float64}(cc) === A{Float64}(1,0.8,0.6,1)
        @test convert(A, cc, 0.4)  == c
        @test convert(A, cc, 0x01) == A{Float64}(1,0.8,0.6,1)
        @test convert(A{Float32}, cc, 0x01) == A{Float32}(1,0.8,0.6,1)
        @test convert(C,          c) == C{Float64}(1,0.8,0.6)
        @test convert(C{Float32}, c) == C{Float32}(1,0.8,0.6)
        @test C{Float32}(c) === C{Float32}(1,0.8,0.6)
    end
    AC, CA = alphacolor(C), coloralpha(C)
    @test AC(CA{Float64}(1,0.8,0.6,0.4)) == AC{Float64}(1,0.8,0.6,0.4)
    @test AC{Float64}(CA{Float64}(1,0.8,0.6,0.4)) == AC{Float64}(1,0.8,0.6,0.4)
    @test CA(AC{Float64}(1,0.8,0.6,0.4)) == CA{Float64}(1,0.8,0.6,0.4)
    @test CA{Float64}(AC{Float64}(1,0.8,0.6,0.4)) == CA{Float64}(1,0.8,0.6,0.4)
end
ac = reinterpret(ARGB32, rand(UInt32))
@test convert(ARGB32, ac) == ac
c = convert(RGB24, ac)
@test convert(RGB24, c) == c

crgb   = convert(RGB, c)
acargb = convert(ARGB, ac)
@test convert(Colorant,       crgb) === crgb
@test convert(Colorant{N0f8},   crgb) === crgb
@test convert(Colorant{Float32},       crgb) === convert(RGB{Float32}, crgb)
@test convert(Color,          crgb) === crgb
@test convert(Color{N0f8},      crgb) === crgb
@test convert(Color{Float32}, crgb) === convert(RGB{Float32}, crgb)
@test_throws ErrorException convert(TransparentColor, crgb)
@test_throws ErrorException convert(TransparentColor{RGB{N0f8}}, crgb)
@test_throws ErrorException convert(TransparentColor{RGB{N0f8},N0f8}, crgb)
@test_throws ErrorException convert(TransparentColor{RGB{N0f8},N0f8,2}, crgb)
@test convert(AlphaColor, crgb) === alphacolor(crgb)
@test convert(AlphaColor{RGB{N0f8}}, crgb) === alphacolor(crgb)
@test convert(AlphaColor{RGB{N0f8},N0f8}, crgb) === alphacolor(crgb)
@test convert(AlphaColor{RGB{N0f8},N0f8,4}, crgb) === alphacolor(crgb)
@test convert(ColorAlpha, crgb) === coloralpha(crgb)
@test convert(ColorAlpha{RGB{N0f8}}, crgb) === coloralpha(crgb)
@test convert(ColorAlpha{RGB{N0f8},N0f8}, crgb) === coloralpha(crgb)
@test convert(ColorAlpha{RGB{N0f8},N0f8,4}, crgb) === coloralpha(crgb)

@test convert(Colorant, acargb) === acargb
@test convert(Colorant{N0f8},   acargb) === acargb
@test convert(Colorant{N0f8,3}, acargb) === crgb
@test convert(TransparentColor, acargb) == acargb
@test convert(Color, acargb) == crgb
@test convert(AlphaColor, acargb) === acargb # issue #126
@test convert(ColorAlpha, acargb) == coloralpha(acargb) # issue #126

h = N0f8(0.5)
@test convert(Gray24, 0.5) == Gray24(h)
@test convert(AGray, Gray24(h)) === AGray{N0f8}(h, 1)
@test convert(AGray, Gray24(h), 0.8)  === AGray{N0f8}(h, 0.8)
@test convert(AGray, AGray32(h, 0.8)) === AGray{N0f8}(h, 0.8)
@test convert(AGray32, 0.5, 0.8) == AGray32(h, N0f8(0.8))
@test convert(RGB24, 0.5) == RGB24(h, h, h)

@test red(c)   == red(ac)
@test green(c) == green(ac)
@test blue(c)  == blue(ac)
ac2 = convert(ARGB32, c)
@test reinterpret(UInt32, ac2) == (c.color | 0xff000000)
@test color(c) == c
@test color(ac) == c
@test alpha(c) == N0f8(1)
@test alpha(ac) == N0f8(ac.color>>24, 0)
@test alpha(ac2) == N0f8(1)
ac3 = convert(RGBA, ac)
@test convert(RGB24, ac3) == c

for C in filter(T -> T <: AbstractRGB, ColorTypes.color3types)
    rgb = convert(C, c)
    C == RGB24 && continue
    @test ccolor(Gray24, C) == Gray24
    @test ccolor(AGray32, C) == AGray32
    @test convert(AbstractRGB, c) == c
    @test convert(AbstractRGB{Float64}, rgb) === convert(C{Float64}, c)
    argb = convert(alphacolor(C), ac)
    rgba = convert(coloralpha(C), ac)
    @test rgb.r == red(c)
    @test rgb.g == green(c)
    @test rgb.b == blue(c)
    @test argb.alpha == alpha(ac)
    @test argb.r == red(ac)
    @test argb.g == green(ac)
    @test argb.b == blue(ac)
    @test rgba.alpha == alpha(ac)
    @test rgba.r == red(ac)
    @test rgba.g == green(ac)
    @test rgba.b == blue(ac)
end

@test_throws ErrorException convert(HSV, RGB(1,0,1))
@test_throws ErrorException convert(AHSV, RGB(1,0,1), 0.5)

@test convert(Float64, Gray(.3)) === .3
@test Float64(Gray(0.3)) === 0.3
@test float(Gray(0.3))   === 0.3
x = N0f8(0.3)
@test convert(N0f8, Gray24(0.3)) === x
@test convert(GrayA{N0f8}, .2) == GrayA{N0f8}(.2)
@test convert(AGray{N0f8}, .2) == AGray{N0f8}(.2)
@test Gray{N0f8}(0.37).val           == N0f8(0.37)
@test convert(Gray{N0f8}, 0.37).val  == N0f8(0.37)
@test convert(Gray{N0f16}, Gray24(reinterpret(N0f8, 0x0d))) == Gray{N0f16}(0.05098)

@test promote(Gray{N0f8}(0.2), Gray24(0.3)) === (Gray{N0f8}(0.2), Gray{N0f8}(0.3))
@test promote(Gray(0.2f0), Gray24(0.3)) === (Gray{Float32}(0.2), Gray{Float32}(N0f8(0.3)))
@test promote(RGB{N0f8}(0.2,0.3,0.4), RGB24(0.3,0.8,0.1)) === (RGB{N0f8}(0.2,0.3,0.4), RGB{N0f8}(0.3,0.8,0.1))
@test promote(RGB{Float32}(0.2,0.3,0.4), RGB24(0.3,0.8,0.1)) === (RGB{Float32}(0.2,0.3,0.4), RGB{Float32}(N0f8(0.3),N0f8(0.8),N0f8(0.1)))

# if the test below fails, please extend the list of types at the call to
# make_alpha in types.jl (this is the price of making that list explicit)
@test Set(ColorTypes.ctypes) ==
Set([DIN99d, DIN99o, DIN99, HSI, HSL, HSV, LCHab, LCHuv,
     LMS, Lab, Luv, XYZ, YCbCr, YIQ, xyY, BGR, RGB, Gray])

## operations
for T in (Gray{N0f8}, Gray{N2f6}, Gray{N0f16}, Gray{N2f14}, Gray{N0f32}, Gray{N2f30},
          Gray{Float16}, Gray{Float32}, Gray{Float64},
          RGB{N0f8}, RGB{N2f6}, RGB{N0f16}, RGB{N2f14}, RGB{N0f32}, RGB{N2f30},
          RGB{Float16}, RGB{Float32}, RGB{Float64},
          AGray{Float32}, GrayA{Float64},
          RGBA{Float32}, ARGB{N0f16}, XRGB{N0f8}, RGBX{Float64},
          BGR{Float16}, ABGR{N0f32}, BGRA{N2f14},
          Gray, AGray, GrayA,
          RGB, ARGB, RGBA, BGR, ABGR, BGRA, XRGB, RGBX,
          HSV, HSL, Lab, LCHab, YIQ)
    a = rand(T)
    @test all(x->x[2]<=getfield(a,x[1])<=x[3],
                zip(ColorTypes.colorfields(T),gamutmin(T),gamutmax(T)))
    @test isa(a, T)
    a = rand(T, (3, 5))
    if isconcretetype(T)
        @test isa(a, Array{T,2})
    end
    for el in a
        @test all(x->x[2]<=getfield(el,x[1])<=x[3],
                    zip(ColorTypes.colorfields(T),gamutmin(T),gamutmax(T)))
    end
    @test eltype(a) <: T
    @test size(a) == (3,5)
    ap = a'
    @test ap[1,1] == a[1,1]
end
for T in (Gray24, AGray32)
    a = rand(T)
    b = a.color
    @test b&0xff == (b>>8)&0xff == (b>>16)&0xff
    @test isa(a, T)
    a = rand(T,3,5)
    for el in a
        b = el.color
        @test b&0xff == (b>>8)&0xff == (b>>16)&0xff
    end
    @test eltype(a) <: T
    @test size(a) == (3,5)
end

@test eltype(broadcast(RGB, [BGR(1,0,0)])) == RGB{N0f8}
addred(x1::AbstractRGB, x2::AbstractRGB) = red(x1) + red(x2)
@test addred.([RGB(1,0,0)], RGB(1.0,0,0)) == [2]

@test @inferred(mapc(sqrt, Gray{N0f8}(0.04))) == Gray(sqrt(N0f8(0.04)))
@test @inferred(mapc(sqrt, AGray{N0f8}(0.04, 0.4))) == AGray(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
@test @inferred(mapc(sqrt, GrayA{N0f8}(0.04, 0.4))) == GrayA(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
@test @inferred(mapc(x->2x, RGB{N0f8}(0.04,0.2,0.3))) == RGB(map(x->2*N0f8(x), (0.04,0.2,0.3))...)
@test @inferred(mapc(sqrt, RGBA{N0f8}(0.04,0.2,0.3,0.7))) == RGBA(map(x->sqrt(N0f8(x)), (0.04,0.2,0.3,0.7))...)
@test @inferred(mapc(x->1.5f0x, RGBA{N0f8}(0.04,0.2,0.3,0.4))) == RGBA(map(x->1.5f0*N0f8(x), (0.04,0.2,0.3,0.4))...)

@test @inferred(mapc(max, Gray{N0f8}(0.2), Gray{N0f8}(0.3))) == Gray{N0f8}(0.3)
@test @inferred(mapc(-, AGray{Float32}(0.3), AGray{Float32}(0.2))) == AGray{Float32}(0.3f0-0.2f0,0.0)
@test @inferred(mapc(min, RGB{N0f8}(0.2,0.8,0.7), RGB{N0f8}(0.5,0.2,0.99))) == RGB{N0f8}(0.2,0.2,0.7)
@test @inferred(mapc(+, RGBA{N0f8}(0.2,0.8,0.7,0.3), RGBA{Float32}(0.5,0.2,0.99,0.5))) == RGBA(0.5f0+N0f8(0.2),0.2f0+N0f8(0.8),0.99f0+N0f8(0.7),0.5f0+N0f8(0.3))
@test @inferred(mapc(+, HSVA(0.1,0.8,0.3,0.5), HSVA(0.5,0.5,0.5,0.3))) == HSVA(0.1+0.5,0.8+0.5,0.3+0.5,0.5+0.3)
@test_throws ArgumentError mapc(min, RGB{N0f8}(0.2,0.8,0.7), BGR{N0f8}(0.5,0.2,0.99))
@test @inferred(mapc(abs, -2)) == 2

@test @inferred(reducec(+, 0.0, Gray(0.3))) === 0.3
@test @inferred(reducec(+, 1.0, Gray(0.3))) === 1.3
@test @inferred(reducec(+, 0, Gray(0.3))) === 0.3
@test @inferred(reducec(+, 0.0, AGray(0.3, 0.8))) === 0.3 + 0.8
@test @inferred(reducec(+, 0.0, RGB(0.3, 0.8, 0.5))) === (0.3 + 0.8) + 0.5
@test @inferred(reducec(+, 0.0, RGBA(0.3, 0.8, 0.5, 0.7))) === ((0.3 + 0.8) + 0.5) + 0.7
@test @inferred(reducec(&, true, Gray(true)))
@test !(@inferred(reducec(&, false, Gray(true))))
@test !(@inferred(reducec(&, true, Gray(false))))

@test @inferred(reducec(+, 0.0, 0.3)) === 0.3
@test @inferred(reducec(+, 0, 0.3)) === 0.3
@test @inferred(reducec(&, true, true))
@test !(@inferred(reducec(&, false, true)))
@test !(@inferred(reducec(&, true, false)))

@test @inferred(mapreducec(x->x^2, +, 0.0, Gray(0.3))) === 0.3^2
@test @inferred(mapreducec(x->x^2, +, 1.0, Gray(0.3))) === 1 + 0.3^2
@test @inferred(mapreducec(x->x^2, +, 0, Gray(0.3))) === 0.3^2
@test @inferred(mapreducec(x->x^2, +, 0.0, AGray(0.3, 0.8))) === 0.3^2 + 0.8^2
@test @inferred(mapreducec(x->x^2, +, 0.0, RGB(0.3, 0.8, 0.5))) === (0.3^2 + 0.8^2) + 0.5^2
@test @inferred(mapreducec(x->x^2, +, 0.0, RGBA(0.3, 0.8, 0.5, 0.7))) === ((0.3^2 + 0.8^2) + 0.5^2) + 0.7^2
@test !(@inferred(mapreducec(x->!x, &, true, Gray(true))))
@test !(@inferred(mapreducec(x->!x, &, false, Gray(true))))
@test @inferred(mapreducec(x->!x, &, true, Gray(false)))
@test !@inferred(mapreducec(x->!x, &, false, Gray(false)))

@test @inferred(mapreducec(x->x^2, +, 0.0, 0.3)) === 0.3^2
@test @inferred(mapreducec(x->x^2, +, 1.0, 0.3)) === 1 + 0.3^2
@test @inferred(mapreducec(x->x^2, +, 0, 0.3)) === 0.3^2
@test !(@inferred(mapreducec(x->!x, &, true, true)))
@test !(@inferred(mapreducec(x->!x, &, false, true)))
@test @inferred(mapreducec(x->!x, &, true, false))
@test !@inferred(mapreducec(x->!x, &, false, false))

@test Gray(0.8) ≈ Gray(0.8 + eps())
@test Gray(0.8) ≈ 0.8 + eps()
@test 0.8 + eps() ≈ Gray(0.8)
@test GrayA(0.8, 0.4) ≈ GrayA(0.8 + eps(), 0.4)
@test RGB(0.2, 0.8, 0.4) ≈ RGB(0.2, 0.8 + eps(), 0.4)
@test RGBA(0.2, 0.8, 0.4, 0.2) ≈ RGBA(0.2, 0.8 + eps(), 0.4, 0.2 - eps())
@test !(Gray(0.8) ≈ Gray(0.6))
@test !(RGB(0.2, 0.8, 0.4) ≈ RGB(0.2, 0.8 + eps(), 0.5))
@test Gray(0.8f0) ≈ Gray(Float64(0.8f0 + eps(0.8f0)))
c = RGB{N0f8}(0.2, 0.8, 0.4)
c1 = mapc(Float32, c)
@test c == c1 && c ≈ c1
c2 = RGB(red(c1), green(c1)-0.1, blue(c1))
@test c ≈ c2 atol=0.11
@test !isapprox(c, c2; atol=0.09)
@test c ≈ convert(RGBX, c)
@test !(c ≈ HSV{Float32}(140.0f0,0.75f0,0.8f0))  # the latter comes from convert when using Colors
@test Gray(0.8N0f8) == Gray24(0.8) && Gray(0.8N0f8) ≈ Gray24(0.8)

# issue #52
@test AGray{BigFloat}(0.5,0.25) == AGray{BigFloat}(0.5,0.25)
@test RGBA{BigFloat}(0.5, 0.25, 0.5, 0.5) == RGBA{BigFloat}(0.5, 0.25, 0.5, 0.5)

for (a, b) in ((Gray(1.0), Gray(1)),
               (GrayA(0.8, 0.6), AGray(0.8, 0.6)),
               (RGB(1, 0.5, 0), BGR(1, 0.5, 0)),
               (RGBA(1, 0.5, 0, 0.8), ABGR(1, 0.5, 0, 0.8)))
    local a, b
    @test a == b
    @test hash(a) == hash(b)
end
for (a, b) in ((RGB(1, 0.5, 0), RGBA(1, 0.5, 0, 0.9)),)
    local a, b
    @test a != b
    @test hash(a) != hash(b)
end
# It's not obvious whether we want these to compare as equal, but
# whatever happens, you want hashing and equality-testing to yield the
# same result
for (a, b) in ((RGB(1, 0.5, 0), RGBA(1, 0.5, 0, 1)),)
    local a, b
    @test (a == b) == (hash(a) == hash(b))
end

### Prevent ambiguous definitions

# Certain types, like Gray24, reinterpret a UInt32 as having a
# particular color meaning. The problem with defining `convert`
# methods is that a UInt32 has a value, e.g., 0 = black and 1 = white.
# Users who want to interpret a UInt32 as a bit pattern should
# explicitly use `reinterpret`.
@testset "bit pattern ambiguities" begin
    @test_throws MethodError convert(UInt32, RGB24(1,1,1))
    @test_throws MethodError convert(UInt32, ARGB32(1,1,1,0))
    @test convert(UInt32, Gray24(1)) == 1
    @test_throws InexactError convert(UInt32, Gray24(0.5))
    @test_throws MethodError convert(UInt32, AGray32(1,0))
    @test !(RGB24(1,1,1) == 0x00ffffff)
    @test !(ARGB32(1,1,1,0) == 0x00ffffff)
    @test Gray24(1) == 1
    @test !(Gray24(1) == 0x00ffffff)
    @test !(AGray32(1,0) == 0x00ffffff)
    @test_throws ArgumentError RGB24(0x00ffffff)
    @test_throws ArgumentError ARGB32(0x00ffffff)
    @test_throws ArgumentError Gray24(0x00ffffff)
    @test_throws ArgumentError AGray32(0x00ffffff)
    @test_throws ArgumentError RGB24[0x00000000,0x00808080]
    @test_throws ArgumentError RGB24[0x00000000,0x00808080,0x00ffffff]
    @test_throws ArgumentError RGB24[0x00000000,0x00808080,0x00ffffff,0x000000ff]
end

end # ColorTypes
