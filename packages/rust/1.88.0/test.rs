use itertools::Itertools;

fn main() {
    let s = vec![1, 2, 3].into_iter().join(",");
    println!("{s}");
}

