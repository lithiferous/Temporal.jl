using Pkg; Pkg.activate(".")
using Temporal

# define universe and gather data
assets = ["DOGE-BUSD"]
function datasource(asset::String)::TS
    savedata_path = joinpath("data", "$asset.csv")
    return Temporal.tsread(savedata_path, indextype=UInt64, format="yyyy-mm-dd HH:MM:SS")

end

df = datasource(assets[end])

save_path(asset::String) = joinpath("/home/bane/projects/julia/Temporal.jl", "data", "$asset.csv")

file = save_path(assets[1])
eol = '\n'
header = true
dlm = ','
indextype = UInt64
format="yyyy-mm-dd"


csv = Vector{String}(split(read(file, String), eol))
if csv[end] == ""
    pop!(csv)  # remove final blank line
end
if header
    fields = Vector{String}(split(popfirst!(csv), dlm)[2:end])
    k = length(fields)
    n = length(csv)
else
    # k = matchcount(csv[1], dlm)
    k = sum([csv[1][i] == dlm for i in 1:length(csv[1])])
    n = length(csv)
    fields = autocol(1:k)
end
# Fill data
arr = zeros(Float64, (n,k))
if indextype != UInt64
    idx = fill("", n)::Vector{String}
else
    idx = zeros(UInt64, n)::Vector{UInt64}
end
for i = 1:n
    s = Vector{String}(split(csv[i], dlm))
    idx[i] = indextype != UInt64 ? popfirst!(s) : parse(UInt64, popfirst!(s))
    s[s.==""] .= "NaN"
    for j in 1:length(s)
        arr[i,j] = parse(Float64, s[j])
    end
end
    return TS(arr, indextype.(idx, format), fields)
