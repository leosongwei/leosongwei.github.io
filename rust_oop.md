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
    // must define accessors
    fn color(&self) -> String; 

    // then we can have shared behaviors
    fn print_color(&self) {
        println!("{}", self.color())
    }
}

// implement accessors
impl Fruit for Apple {
    fn color(&self) -> String {
        return self.color.clone();
    }
}
impl Fruit for Pear {
    fn color(&self) -> String {
        return self.color.clone();
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
