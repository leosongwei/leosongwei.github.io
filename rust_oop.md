Rust OOP
--------

tags: rust; OOP;

## Shared behavior

```rust
struct Apple {
    color: String,
}

struct Pear {
    color: String,
}

trait Fruit {
    fn color(&self) -> &str;

    fn print_color(&self) {
        println!("{}", self.color())
    }
}

impl Fruit for Apple {
    fn color(&self) -> &str {
        return self.color.as_str();
    }
}
impl Fruit for Pear {
    fn color(&self) -> &str {
        return self.color.as_str();
    }
}

fn main() {
    let a = Apple {
        color: "red".to_string(),
    };
    let b = Pear {
        color: "green".to_string(),
    };
    a.print_color();
    b.print_color();
}
```
