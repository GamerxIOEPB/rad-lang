// Benchmark: Allocation & Vector Iteration (1,000,000 elements x 10 runs)
use std::time::Instant;

fn main() {
    let n = 1000000usize;
    let iterations = 10usize;
    let t0 = Instant::now();

    let mut total_sum: i64 = 0;
    for iter in 0..iterations {
        let mut v: Vec<i64> = Vec::with_capacity(n);
        for i in 0..n {
            v.push((i as i64) + (iter as i64));
        }
        let s: i64 = v.iter().sum();
        total_sum += s;
    }

    let elapsed_ms = t0.elapsed().as_millis();
    println!("RUST_ALLOC_RESULT: {} ms (sum: {})", elapsed_ms, total_sum);
}
