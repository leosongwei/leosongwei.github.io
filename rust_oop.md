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
    fn name(&self) -> &str;
    fn color(&self) -> &str;

    fn print_color(&self) {
        println!("the {} is {}", self.name(), self.color())
    }
}

impl Fruit for Apple {
    fn name(&self) -> &str {
        return "apple";
    }

    fn color(&self) -> &str {
        return self.color.as_str();
    }
}
impl Fruit for Pear {
    fn name(&self) -> &str {
        return "pear";
    }

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

    // polymorphism
    let list = vec![
        Box::new(Apple {
            color: "red".to_string(),
        }) as Box<dyn Fruit>,
        Box::new(Pear {
            color: "red".to_string(),
        }) as Box<dyn Fruit>,
    ];
    for x in list {
        x.print_color();
    }
}
```
