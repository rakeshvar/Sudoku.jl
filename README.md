# Sudoku.jl

A Julia package for solving Sudoku puzzles.

## Features

- Solve standard 9x9 Sudoku puzzles

## Usage

You can use the `sudosolve.ipynb` notebook to solve a puzzle. You need `julia` kernel in jupyter.

The main functions are `solvebyrules` and `solvebyguessing`. You can specify the puzzle either as a matrix or as a string (converted to a matrix using the helper `text2mat`.) See `samples.jl` for examples.

## License

Whatever License