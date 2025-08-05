block(i) = (i<4) ? (1:3) : (i<7) ? (4:6) : (7:9)
block(i, j) = Iterators.product(block(i), block(j))

struct Sudoklass 
    mat::Array{Int, 2}
    can::BitArray{3}        # 9x9x9 boolean array of candidates
end

canlen(s::Sudoklass) = sum(s.can)
matlen(s::Sudoklass) = sum(x -> x>0, s.mat)
lens(s::Sudoklass) = canlen(s), matlen(s)

function show(s::Sudoklass)
    println("### ### ###")
    L = matlen(s) == 81 ? 0 : maximum(sum(s.can, dims=3))
    for i in 1:9
        for j in 1:9
            v = s.mat[i, j]
            if 0 < v < 10
                print(" $v", repeat(" ", L))
            else
                u = s.can[i, j, :] |> findall |> join
                print("($u)", repeat(" ", L-length(u)))
            end
            if j in (3, 6)
                print(" | ")
            end
        end
        println()
        if i in (3, 6)
            println()
        end
    end
    println("### -",  canlen(s), " +", matlen(s), " ### ###")
end

function Sudoklass()
    mat = zeros(Int, 9, 9)
    can = trues(9, 9, 9)
    Sudoklass(mat, can)
end

function Sudoklass(mat::Matrix{Int})
    s = Sudoklass()
    assignvalues!(s, mat)
    @assert issane(s) "Sudoklass is not sane"
    s
end

function assignvalues!(s::Sudoklass, mat::Matrix{Int})
    for j in 1:9
        for i in 1:9
            if mat[i, j] == 0
                continue
            elseif 0 < mat[i, j] ≤ 9
                assignvalat!(s, i, j, mat[i, j])
            else
                error("Error parsing array mat($i, $j) = $(mat[i, j])")
            end
        end
    end
end

function assignvalat!(s::Sudoklass, i0, j0, v0)
    @assert s.mat[i0, j0] == 0 "Can not override cell ($i0, $j0) value = $(s.mat[i0, j0])"
    @assert s.can[i0, j0, v0] "Can not assign value $v0 at ($i0, $j0). Candidates are $(s.can[i0, j0] |> findall)"
    
    s.mat[i0, j0] = v0
    s.can[i0, j0, :] .= false

    for i in 1:9
        s.can[i, j0, v0] = false       end
    for j in 1:9
        s.can[i0, j, v0] = false       end
    for (i, j) in block(i0, j0)
        s.can[i, j,  v0] = false       end
end


function issane(s::Sudoklass, debug=false)
    for i in 1:9
        for j in 1:9
            # Check if the cell value is valid
            if !(0 ≤ s.mat[i, j] ≤ 9)
                println("Invalid cell ($i, $j) value = $(s.mat[i, j])")
                return false
            end

            # Check if the cell candidates are valid
            if s.mat[i, j] == 0
                if !any(s.can[i, j, :]) 
                    println("Cell ($i, $j) has no candidates")
                    return false
                end
            end
        end
    end
    return true
end

######################################################################### Helpers

rowhood(s::Sudoklass, i) = @view s.can[i, :, :]
colhood(s::Sudoklass, j) = @view s.can[:, j, :]
function blkhood(s::Sudoklass, k)
    slices = [
        (1:3, 1:3), (1:3, 4:6), (1:3, 7:9),
        (4:6, 1:3), (4:6, 4:6), (4:6, 7:9),
        (7:9, 1:3), (7:9, 4:6), (7:9, 7:9),
    ]
    hood = @view s.can[slices[k][1], slices[k][2], :]
    reshape(hood, 9, 9)                                 # Goes column first
end

rowhoods(s::Sudoklass) = rowhood.((s,), 1:9)
colhoods(s::Sudoklass) = colhood.((s,), 1:9)
blkhoods(s::Sudoklass) = blkhood.((s,), 1:9)

function allhoods(fn::Function, s::Sudoklass)
    rowhoods(s) .|> fn
    colhoods(s) .|> fn
    blkhoods(s) .|> fn
end

function locations(hood)
    [findall(hood[:, v]) for v in 1:9]    
end
