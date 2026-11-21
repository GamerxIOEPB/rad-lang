use std::time::Instant;

fn main() {
    let n = 512usize;
    let total_elements = n * n;

    let mut a = vec![0.0f64; total_elements];
    let mut b = vec![0.0f64; total_elements];
    let mut c = vec![0.0f64; total_elements];

    for i in 0..total_elements {
        a[i] = ((i % 100) as f64) * 0.01;
        b[i] = (((i + 50) % 100) as f64) * 0.01;
    }

    let t0 = Instant::now();

    for row in 0..n {
        for col in 0..n {
            let mut sum = 0.0f64;
            for k in 0..n {
                sum += a[row * n + k] * b[k * n + col];
            }
            c[row * n + col] = sum;
        }
    }

    let elapsed_ms = t0.elapsed().as_millis();

    let mut checksum = 0.0f64;
    let mut ci = 0usize;
    while ci < total_elements {
        checksum += c[ci];
        ci += 1024;
    }

    println!("RUST_MATMUL_RESULT: {} ms (checksum: {})", elapsed_ms, checksum as i64);
}
