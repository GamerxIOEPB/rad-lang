use std::time::Instant;

fn solve_nqueens(n: i32, row: i32, cols: &mut [i32; 16], diag1: &mut [i32; 32], diag2: &mut [i32; 32]) -> i64 {
    if row == n {
        return 1;
    }
    let mut count = 0i64;
    for col in 0..n {
        let d1 = (row - col + n) as usize;
        let d2 = (row + col) as usize;
        let c = col as usize;
        if cols[c] == 0 && diag1[d1] == 0 && diag2[d2] == 0 {
            cols[c] = 1;
            diag1[d1] = 1;
            diag2[d2] = 1;

            count += solve_nqueens(n, row + 1, cols, diag1, diag2);

            cols[c] = 0;
            diag1[d1] = 0;
            diag2[d2] = 0;
        }
    }
    count
}

fn main() {
    let n = 14i32;
    let mut cols = [0i32; 16];
    let mut diag1 = [0i32; 32];
    let mut diag2 = [0i32; 32];

    let t0 = Instant::now();
    let solutions = solve_nqueens(n, 0, &mut cols, &mut diag1, &mut diag2);
    let elapsed_ms = t0.elapsed().as_millis();

    println!("RUST_NQUEENS_RESULT: {} ms (solutions: {})", elapsed_ms, solutions);
}
