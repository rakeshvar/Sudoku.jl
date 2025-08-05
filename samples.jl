# https://github.com/grantm/sudoku-exchange-puzzle-bank

function text2num(s)
    ret = fill(0, 9, 9)
    lines = split(s, '\n')
    if lines[1] == ""
        popfirst!(lines)
    end
    for (i, l) in enumerate(lines)
        for (j, c) in enumerate(l)
            if '0' ≤ c ≤ '9'
                ret[i, j] = parse(Int, c)
            elseif !(c ∈ " .")
                println("Did not understand $c at ($i, $j). Assuming empty cell.")
            end
        end
    end
    ret
end

# cell_with_one_candidate is enough
a = [
0 3 0   0 7 0   0 0 0;
6 0 0   1 9 5   0 0 0;
0 9 8   0 0 0   0 6 0;

8 0 0   0 6 0   0 0 3;
4 0 0   8 0 3   0 0 1;
7 0 0   0 2 0   0 0 6;

0 6 0   0 0 0   2 8 0;
0 0 0   4 1 9   0 0 5;
0 0 0   0 8 0   0 7 9;
]

# candidate_at_one_cell (once) is enough
b = 
"
  8    13
  3 6 8 9
     54
4 7   6
 1   7 34
 6
 8631
      59
17 45  6
" |> text2num

# cellpair_with_candidatepair is enough
c = 
"
   8 1
       43
5
    7 8
      1
 2  3
6      75
  34
   2  6
" |> text2num

# 
d = 
"
    2    
4     1  
 3 6 7  9
 2  9  
    8   5
3  2 5 4 
 6 5 3  7
     8   
8 7    9 
" |> text2num

# Needs a lot of guessing
e = 
"

6
84
492
5687
73142
286547
3172986
95436182
" |> text2num

f = 
"
   2 45  
4  3   1
    5
 6 8   2
  2 1   7
  9   8
6  4  25
  1    6
527  3
" |> text2num

# Uses candidatepair_at_cellpair
g = "
    5 2
 3     6
     1 4
  4395
 81 4
    2
  52    9
1       7
 769   8 
" |> text2num

nothing