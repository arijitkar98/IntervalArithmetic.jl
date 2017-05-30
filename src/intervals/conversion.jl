# This file is part of the IntervalArithmetic.jl package; MIT licensed

## Promotion rules

# Avoid ambiguity with ForwardDiff:

# promote_rule{T<:Real, N, R<:Real}(::Type{Interval{T}},
#     ::Type{ForwardDiff.Dual{N,R}}) = ForwardDiff.Dual{N, Interval{promote_type(T,R)}}


promote_rule{T<:Real, S<:Real}(::Type{Interval{T}}, ::Type{Interval{S}}) =
    Interval{promote_type(T, S)}

promote_rule{T<:Real, S<:Real}(::Type{Interval{T}}, ::Type{S}) =
    Interval{promote_type(T, S)}

promote_rule{T<:Real}(::Type{BigFloat}, ::Type{Interval{T}}) =
    Interval{promote_type(T, BigFloat)}


promote_rule{T<:Real, S<:Real}(::Type{FastInterval{T}}, ::Type{FastInterval{S}}) =
    FastInterval{promote_type(T, S)}

promote_rule{T<:Real, S<:Real}(::Type{FastInterval{T}}, ::Type{S}) =
    FastInterval{promote_type(T, S)}

promote_rule{T<:Real}(::Type{BigFloat}, ::Type{FastInterval{T}}) =
    FastInterval{promote_type(T, BigFloat)}

promote_rule{T<:Real, S<:Real}(::Type{Interval{T}}, ::Type{FastInterval{S}}) =
    Interval{promote_type(T, S)}


# Floating point intervals:

convert{T<:AbstractFloat}(::Type{Interval{T}}, x::AbstractString) =
    parse(Interval{T}, x)
# convert{T<:AbstractFloat}(::Type{FastInterval{T}}, x::AbstractString) =
#     parse(FastInterval{T}, x)

function convert{T<:AbstractFloat, S<:Real}(::Type{Interval{T}}, x::S)
    Interval{T}( T(x, RoundDown), T(x, RoundUp) )
    # the rounding up could be done as nextfloat of the rounded down one?
    # use @round_up and @round_down here?
end
convert{T<:AbstractFloat, S<:Real}(::Type{FastInterval{T}}, x::S) =
    FastInterval{T}( T(x), T(x) )

function convert{T<:AbstractFloat}(::Type{Interval{T}}, x::Float64)
    II = convert(Interval{T}, rationalize(x))
    # This prevents that rationalize(x) returns a zero when x is very small
    if x != zero(x) && II == zero(Interval{T})
        return Interval(parse(T, string(x), RoundDown),
                        parse(T, string(x), RoundUp))
    end
    II
end
function convert{T<:AbstractFloat}(::Type{FastInterval{T}}, x::Float64)
    II = convert(FastInterval{T}, rationalize(x))
    # This prevents that rationalize(x) returns a zero when x is very small
    if x != zero(x) && II == zero(FastInterval{T})
        return convert(FastInterval{T}, string(x))
    end
    II
end


convert{T<:AbstractFloat}(::Type{Interval{T}}, x::Interval{T}) = x
convert{T<:AbstractFloat}(::Type{FastInterval{T}}, x::FastInterval{T}) = x
convert{T<:AbstractFloat}(::Type{Interval{T}}, x::FastInterval) =
    Interval(parse(T, string(x.lo), RoundDown), parse(T, string(x.hi), RoundUp))

function convert{T<:AbstractFloat}(::Type{Interval{T}}, x::Interval)
    Interval{T}( T(x.lo, RoundDown), T(x.hi, RoundUp) )
end
convert{T<:AbstractFloat}(::Type{FastInterval{T}}, x::FastInterval) =
    FastInterval{T}( T(x.lo), T(x.hi) )


# Complex numbers:
convert{T<:AbstractFloat}(::Type{Interval{T}}, x::Complex{Bool}) = (x == im) ?
    one(T)*im : throw(ArgumentError("Complex{Bool} not equal to im"))


# Rational intervals
function convert(::Type{Interval{Rational{Int}}}, x::Irrational)
    a = float(convert(Interval{BigFloat}, x))
    convert(Interval{Rational{Int}}, a)
end

function convert(::Type{Interval{Rational{BigInt}}}, x::Irrational)
    a = convert(Interval{BigFloat}, x)
    convert(Interval{Rational{BigInt}}, a)
end

convert{T<:Integer, S<:Integer}(::Type{Interval{Rational{T}}}, x::S) =
    Interval(x*one(Rational{T}))

convert{T<:Integer, S<:Integer}(::Type{Interval{Rational{T}}}, x::Rational{S}) =
    Interval(x*one(Rational{T}))

convert{T<:Integer, S<:Float64}(::Type{Interval{Rational{T}}}, x::S) =
    Interval(rationalize(T, x))

convert{T<:Integer, S<:BigFloat}(::Type{Interval{Rational{T}}}, x::S) =
    Interval(rationalize(T, x))


# conversion to Interval without explicit type:
function convert(::Type{Interval}, x::Real)
    T = typeof(float(x))

    return convert(Interval{T}, x)
end
function convert(::Type{FastInterval}, x::Real)
    T = typeof(float(x))

    return convert(FastInterval{T}, x)
end

convert(::Type{Interval}, x::Interval) = x
convert(::Type{FastInterval}, x::FastInterval) = x
