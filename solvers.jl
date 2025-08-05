
@enum Solution solved unsolved nosolution

function solvebyrules!(s::Sudoklass, debug=false)
    iter = 1
    level = 1
    algos = [cell_with_one_candidate!, 
            candidate_at_one_cell!, 
            cellpair_with_candidatepair!, 
            candidatepair_at_cellpair!          # samples c, g use this
            ]
    
    while matlen(s) < 81
        debug && print("\n$iter) $(lens(s)) [alg:$level] $(algos[level]) ")
        try
            if algos[level](s)
                debug && print("✅")
                level = 1       # Success, start from the basic algorithm
            else
                debug && println("❌")
                level += 1      # Failed, try higher level algorithm
            end
        catch e
            if isa(e, NoSolutionError)
                println("\tNo Solution. Bad guesses?")
                return nosolution
            else
                rethrow(e)
            end
        end

        if level > length(algos)
            println("\tCouldn't solve. Needs Guessing." )
            return unsolved
        end
        iter += 1
    end

    return solved
end

function solvebyguessing(s::Sudoklass, level)
    println("\n$(lens(s)) ")
    
    for i in 1:9
        for j in 1:9
            for v in findall(s.can[i, j, :])
                t = deepcopy(s)

                println("~~~~~~~~~~~~ " ^ level, "Level $level : Trying $v at ($i, $j) ", lens(t))
                assignvalat!(t, i, j, v)
                issane(t) || continue

                status = solvebyrules!(t)
                if status == solved
                    return solved, t
                elseif status == unsolved
                    status, u = solvebyguessing(t, level + 1)
                    if status == solved
                        return solved, u
                    end 
                end
                # if status == nosolution then we continue
            end
        end
    end
    
    return nosolution, s
end

function solvebyguessing(s::Sudoklass)
    status = solvebyrules!(s)
    if status == solved
        println("Already solved by rules! No need for guessing.")
        return solved, s
    elseif status == unsolved
        println("Unsolved by rules, trying guessing...")
        return solvebyguessing(s, 1)
    elseif status == nosolution
        println("Solving by guessing...")
        error("No solution found by rules, but this should not happen.")
    end
    error("Should not reach here.")
end

function solvebyrules(x)
    println("—" ^ 80)
    X = Sudoklass(x) 
    show(X)
    status = solvebyrules!(X)
    show(X)
    status
end

function solvebyguessing(x)
    println("—" ^ 80)
    X = Sudoklass(x) 
    show(X)
    status, result = solvebyguessing(X)
    show(result)
    status
end