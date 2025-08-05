######################################################################### Level 1
struct NoSolutionError <: Exception
    msg::String
end

function cell_with_one_candidate!(s::Sudoklass)
    c0, m0 = lens(s)

    for i in 1:9
        for j in 1:9
            if s.mat[i,j] == 0 
                if sum(s.can[i, j, :]) == 0
                    throw(NoSolutionError("Got no candidates for ($i, $j)"))
                end

                if sum(s.can[i, j, :]) == 1
                    assignvalat!(s, i, j, findfirst(s.can[i, j, :]))         
    end end end end

    c1, m1 = lens(s)
    c1 < c0
end 

######################################################################### Level 2

function candidate_at_one_cell!(s::Sudoklass)
    c0, m0 = lens(s)

    allhoods(s) do hood
        for v in 1:9
            if sum(hood[:, v]) == 1
                loc = findfirst(hood[:, v])
                hood[loc, :] .= false
                hood[loc, v]  = true           
            end 
        end 
    end 

    c1, m1 = lens(s)
    c1 < c0
end

######################################################################### Level 3

function cellpair_with_candidatepair!(s::Sudoklass)
    c0, m0 = lens(s)

    allhoods(s) do hood
        d = Dict{BitArray, Set{Int}}()                       # candidates -> locations
        for i in 1:9
            if sum(hood[i, :]) == 2
                if hood[i, :] ∉ keys(d)
                    d[hood[i, :]] = Set()
                end
                push!(d[hood[i, :]], i)
            end
        end                              # { [000011000] => (2,), [010100000] => (7, 8) }

        filter!(kv -> length(kv.second) == 2, d) 
        
        for couples_vec in keys(d)
            couples = findall(couples_vec)
            locs = d[couples_vec] |> collect            # Couple $couples found at $locs
            hood[:, couples] .= false
            hood[locs, couples] .= true
        end   
    end

    c1, m1 = lens(s)
    c1 < c0
end


######################################################################### Level 4
function candidatepair_at_cellpair!(s::Sudoklass)
    c0, m0 = lens(s)

    allhoods(s) do hood
        d = Dict{BitArray, Set{Int}}()                       # locations -> values 
        for v in 1:9
            if sum(hood[:, v]) == 2
                if hood[:, v] ∉ keys(d)
                    d[hood[:, v]] = Set()
                end
                push!(d[hood[:, v]], v)
            end
        end                         # {[100100000] => (4, 5), [000000110] => (7,)}

        filter!(kv -> length(kv.second) == 2, d)
        
        for locs_vec in keys(d)
            locs = findall(locs_vec)
            couples = d[locs_vec] |> collect            # Couple $couples found at $locs
            hood[:, couples] .= false
            hood[locs, :] .= false
            hood[locs, couples] .= true
        end   
    end

    c1, m1 = lens(s)
    c1 < c0
end
