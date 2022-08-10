# MetroHash for Zig [![test](https://github.com/moznion/metro-zig/actions/workflows/test.yaml/badge.svg)](https://github.com/moznion/metro-zig/actions/workflows/test.yaml)

[MetroHash](http://www.jandrewrogers.com/2015/05/27/metrohash/) library for [Zig](https://ziglang.org/).

This library provides 64-bit and 128-bit MetroHash hashing functions.

## Synopsis

### 64-bit Hash

```zig
var data = [_]u8{
    48, 49, 50, 51, 52, 53, 54, 55,
    56, 57, 48, 49, 50, 51, 52, 53,
    54, 55, 56, 57, 48, 49, 50, 51,
    52, 53, 54, 55, 56, 57, 48, 49,
    50, 51, 52, 53, 54, 55, 56, 57,
    48, 49, 50, 51, 52, 53, 54, 55,
    56, 57, 48, 49, 50, 51, 52, 53,
    54, 55, 56, 57, 48, 49, 50,
};
const seed: u64 = 1;
const hash: u64 = hash64(data[0..], seed);
```

### 128-bit Hash

```zig
var data = [_]u8{
    48, 49, 50, 51, 52, 53, 54, 55,
    56, 57, 48, 49, 50, 51, 52, 53,
    54, 55, 56, 57, 48, 49, 50, 51,
    52, 53, 54, 55, 56, 57, 48, 49,
    50, 51, 52, 53, 54, 55, 56, 57,
    48, 49, 50, 51, 52, 53, 54, 55,
    56, 57, 48, 49, 50, 51, 52, 53,
    54, 55, 56, 57, 48, 49, 50,
};
const seed: u64 = 1;
const hash: u128 = hash128(data[0..], seed);
```

## How to build and test

```
$ git submodule init && git submodule update
$ zig build test
```

## Note

This implementation is based on [jandrewrogers/MetroHash](https://github.com/jandrewrogers/MetroHash) and [dgryski/go-metro](https://github.com/dgryski/go-metro).

## License

MIT

## Author

moznion (<moznion@mail.moznion.net>)

