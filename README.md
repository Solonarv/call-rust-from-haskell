# Call Rust from Haskell

A working example of calling Rust code from Haskell via the C FFI.

Currently tested only on Windows, but *should* work on the other major OSs as well.

Uses a [Shake](https://shakebuild.com/) build script to orchestrate `cargo` and `cabal` invocations
and copy build artifacts to the right location.

## Building

```sh
git clone https://github.com/Solonarv/call-rust-from-haskell.git
cd call-rust-from-haskell
cabal v2-run build
```

Build artifacts land in `_build`. You can change this by editing the `buildDir`
variable near the top of [build.hs](build.hs).

## Running

```sh
cabal v2-run build run
```

This will build the program and execute it afterwards.