Play with pointers in Rust
--------------------------

tags: rust; buffer; pointer; array;

```rust
use std::mem;

#[derive(Debug)]
#[repr(C)]
struct Apple {
    weight: u32,
    size: u32,
}

fn main() {
    let total = 10;
    let mut buffer = Vec::<u8>::with_capacity(total * mem::size_of::<Apple>());
    let buffer_ptr = mem::ManuallyDrop::new(buffer).as_mut_ptr();

    unsafe {
        println!("{:?}", *buffer_ptr);
    }

    let mut apple_vec: Vec<Apple> = unsafe { Vec::from_raw_parts(buffer_ptr.cast(), total, total) };

    for apple in apple_vec.iter_mut() {
        apple.weight = 233;
        apple.size = 666;
    }

    for (i, apple) in apple_vec.iter().enumerate() {
        println!("{}: {:?}", i, apple);
    }
    unsafe {
        for i in 0..(total * mem::size_of::<Apple>()) {
            print!("{} ", *buffer_ptr.offset(i as isize))
        }
        println!("")
    }
}
```

Output:

> 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
> 0: Apple { weight: 233, size: 666 }
> 1: Apple { weight: 233, size: 666 }
> 2: Apple { weight: 233, size: 666 }
> 3: Apple { weight: 233, size: 666 }
> 4: Apple { weight: 233, size: 666 }
> 5: Apple { weight: 233, size: 666 }
> 6: Apple { weight: 233, size: 666 }
> 7: Apple { weight: 233, size: 666 }
> 8: Apple { weight: 233, size: 666 }
> 9: Apple { weight: 233, size: 666 }
> 233 0 0 0 154 2 0 0 233 0 0 0 154 2 0 0 233 0 0 0 154 2 0 0 233 0 0 0 154 2 0 0 233 0 0 0 154 2 0 0 233 0 0 0 154 2 0 0 233 0 0 0 154 2 0 0 233 0 0 0 154 2 0 0 233 0 0 0 154 2 0 0 233 0 0 0 154 2 0 0
