include("dlx.jl")
include("samples.jl")

"""
Given a 9x9 Sudoku matrix (with 0 for empty cells), generate the exact cover matrix
for the DLX (Dancing Links) solver with Algorithm X. Returns a matrix of 0s and 1s.
"""
function sudoku_to_dlx_matrix(sudomat::Matrix{Int}, N=9)
    N² = N * N 
    n_constraints = 4N²
    choices = []

    for r in 1:N, c in 1:N, v in 1:N
        # If [r, c] contains a digit, skip other choices
        sudomat[r, c] ∈ (0, v) || continue

        choice = falses(n_constraints)
        choice[      (r-1)*N + c] = true      # cell should be filled
        choice[ N² + (r-1)*N + v] = true      # digit should appear in row
        choice[2N² + (c-1)*N + v] = true      # digit should appear in column
        b = div(r-1, 3)*3 + div(c-1, 3) + 1
        choice[3N² + (b-1)*N + v] = true      # digit should appear in box

        push!(choices, choice)
    end

    reduce(vcat, choices')::Matrix{Bool}
end

function decode_sudoku_solution(solution_choices, N=9)
    sudomat = zeros(Int, N, N)
    N² = N * N

    for choice in eachrow(solution_choices)
        icell, irow, icol, ibox = findall(choice)
        row, num1 = divrem(irow-N²-1, N) 
        col, num2 = divrem(icol-2N²-1, N)
        row += 1
        col += 1
        num = num1 + 1  # Convert to 1-based index
        (num2 == num1) || println("Error Inconsistent digit assignment: $num1 != $num2")
        sudomat[row, col] = num
    end
    sudomat
end

function check_solution_against_input(m_in, m_out)
    look_at = m_in .!= 0
    match = m_in[look_at] == m_out[look_at]
    match && return true

    println("Input and output do not match (concatenated digits ;-) ):")
    show(stdout, "text/plain", 10m_out+m_in)
    false
end

function solvey(X)
    dmat = sudoku_to_dlx_matrix(X)
    dlx_solutions = solve_dlx(dmat)
    println("Found $(length(dlx_solutions)) solutions.")

    for solution in dlx_solutions
        sol_choices = dmat[solution, :]
        filled = decode_sudoku_solution(sol_choices)
        if check_solution_against_input(X, filled)
            # show(stdout, "text/plain", filled)
            print("✓")
        else
            println("Invalid solution found.")
        end
    end
    println()
end


function get_one_solution(x)
    dmat = sudoku_to_dlx_matrix(x)
    dlx_solutions = solve_dlx(dmat)
    solution = dlx_solutions[1]
    sol_choices = dmat[solution, :]
    decode_sudoku_solution(sol_choices)
end

solvey.((a, b, c, d, e, f, g))
