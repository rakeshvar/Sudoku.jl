function dummy(args...; kwargs...)
end

function solve_dlx(mat::AbstractMatrix{Bool})
    nchoices, nconstrains = size(mat)
    solutions = Vector{Int}[]

    function solve(partial_solution::Vector{Int}=Int[], 
                   active_choices=trues(nchoices), 
                   active_constraints=trues(nconstrains))
        if sum(active_constraints) == 0
            push!(solutions, copy(partial_solution))
            return
        end

        # Choose the active constraints with least choices
        choices_per_constraint = sum(mat[active_choices, :], dims=1)[:]
        choices_per_constraint[.!active_constraints] .= nchoices           # Set done Constraintss to max 
        min_num_choices, best_constraint = findmin(choices_per_constraint)
        (min_num_choices == 0) && return                                   # No solution possible
        
        choices_for_best = findall(mat[:, best_constraint] .&& active_choices)    # Remaining rows that cover this Constraints

        for ichoice in choices_for_best
            solve([partial_solution; ichoice],
                  active_choices .& .!any(mat[:, mat[ichoice, :]], dims=2)[:],  
                    # Choices that do not intersect with choice
                  active_constraints .& .!mat[ichoice, :])
                    # Constraintss not covered by row r
        end
    end

    solve()
    return solutions
end

TESTING = false
if TESTING
  A = [1 0 0 1 0;
      0 1 0 1 0;
      0 1 1 0 1;
      1 0 1 0 0;
      1 1 1 0 1;
      0 0 0 1 0;
      0 1 0 0 1;
      0 0 1 0 0;] |> BitMatrix
  solutions = solve_dlx(A) 
  show(stdin, "text/plain", solutions)
end
