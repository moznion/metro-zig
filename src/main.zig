const std = @import("std");
const testing = std.testing;
const bits = @import("bits-util-zig/src/main.zig");
const byteorder = @import("byteorder-util-zig/src/main.zig");

pub fn hash64(buffer: []u8, seed: u64) u64 {
    const k0 = 0xD6D018F5;
    const k1 = 0xA2AA033B;
    const k2 = 0x62992FC1;
    const k3 = 0x30BC5B29;

    var tmp: u64 = 0;
    var hash: u64 = (seed + k2) * k0;

    var ptr = buffer;

    if (ptr.len >= 32) {
        var v0 = hash;
        var v1 = hash;
        var v2 = hash;
        var v3 = hash;

        while (ptr.len >= 32) {
            // v0 += byteorder.LittleEndian.toU64(ptr[0..8].*) * k0
            _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[0..8].*), k0, &tmp);
            _ = @addWithOverflow(u64, v0, tmp, &v0);
            // v0 = bits.rotateLeft64(v0, -29) + v2
            _ = @addWithOverflow(u64, bits.rotateLeft64(v0, -29), v2, &v0);

            // v1 += byteorder.LittleEndian.toU64(ptr[8..16].*) * k1
            _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[8..16].*), k1, &tmp);
            _ = @addWithOverflow(u64, v1, tmp, &v1);
            // v1 = bits.rotateLeft64(v1, -29) + v3
            _ = @addWithOverflow(u64, bits.rotateLeft64(v1, -29), v3, &v1);

            // v2 += byteorder.LittleEndian.toU64(ptr[16..24].*) * k2
            _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[16..24].*), k2, &tmp);
            _ = @addWithOverflow(u64, v2, tmp, &v2);
            // v2 = bits.rotateLeft64(v2, -29) + v0
            _ = @addWithOverflow(u64, bits.rotateLeft64(v2, -29), v0, &v2);

            // v3 += byteorder.LittleEndian.toU64(ptr[24..32].*) * k3
            _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[24..32].*), k3, &tmp);
            _ = @addWithOverflow(u64, v3, tmp, &v3);
            // v3 = bits.rotateLeft64(v3, -29) + v1
            _ = @addWithOverflow(u64, bits.rotateLeft64(v3, -29), v1, &v3);

            ptr = ptr[32..];
        }

        // v2 ^= bits.rotateLeft64(((v0+v3)*k0)+v1, -37) * k1
        _ = @addWithOverflow(u64, v0, v3, &tmp);
        _ = @mulWithOverflow(u64, tmp, k0, &tmp);
        _ = @addWithOverflow(u64, tmp, v1, &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -37), k1, &tmp);
        v2 ^= tmp;

        // v3 ^= bits.rotateLeft64(((v1+v2)*k1)+v0, -37) * k0
        _ = @addWithOverflow(u64, v1, v2, &tmp);
        _ = @mulWithOverflow(u64, tmp, k1, &tmp);
        _ = @addWithOverflow(u64, tmp, v0, &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -37), k0, &tmp);
        v3 ^= tmp;

        // v0 ^= bits.rotateLeft64(((v0+v2)*k0)+v3, -37) * k1
        _ = @addWithOverflow(u64, v0, v2, &tmp);
        _ = @mulWithOverflow(u64, tmp, k0, &tmp);
        _ = @addWithOverflow(u64, tmp, v3, &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -37), k1, &tmp);
        v0 ^= tmp;

        // v1 ^= bits.rotateLeft64(((v1+v3)*k1)+v2, -37) * k0
        _ = @addWithOverflow(u64, v1, v3, &tmp);
        _ = @mulWithOverflow(u64, tmp, k1, &tmp);
        _ = @addWithOverflow(u64, tmp, v2, &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -37), k0, &tmp);
        v1 ^= tmp;

        _ = @addWithOverflow(u64, hash, v0 ^ v1, &hash);
    }

    if (ptr.len >= 16) {
        var v0 = hash;
        var v1 = hash;

        // v0 += byteorder.LittleEndian.toU64(ptr[0..8].*) * k2
        _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[0..8].*), k2, &tmp);
        _ = @addWithOverflow(u64, v0, tmp, &v0);
        // v0 = bits.rotateLeft64(v0, -29) * k3
        _ = @mulWithOverflow(u64, bits.rotateLeft64(v0, -29), k3, &v0);

        // v1 += byteorder.LittleEndian.toU64(ptr[8..16].*) * k2
        _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[8..16].*), k2, &tmp);
        _ = @addWithOverflow(u64, v1, tmp, &v1);
        // v1 = bits.rotateLeft64(v1, -29) * k3
        _ = @mulWithOverflow(u64, bits.rotateLeft64(v1, -29), k3, &v1);

        // v0 ^= bits.rotateLeft64(v0*k0, -21) + v1
        _ = @mulWithOverflow(u64, v0, k0, &tmp);
        _ = @addWithOverflow(u64, bits.rotateLeft64(tmp, -21), v1, &tmp);
        v0 ^= tmp;

        // v1 ^= bits.rotateLeft64(v1*k3, -21) + v0
        _ = @mulWithOverflow(u64, v1, k3, &tmp);
        _ = @addWithOverflow(u64, bits.rotateLeft64(tmp, -21), v0, &tmp);
        v1 ^= tmp;

        // hash += v1
        _ = @addWithOverflow(u64, hash, v1, &hash);

        ptr = ptr[16..];
    }

    if (ptr.len >= 8) {
        // hash += byteorder.LittleEndian.toU64(ptr[0..8].*) * k3
        _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[0..8].*), k3, &tmp);
        _ = @addWithOverflow(u64, hash, tmp, &hash);

        // hash ^= bits.rotateLeft64(hash, -55) * k1
        _ = @mulWithOverflow(u64, bits.rotateLeft64(hash, -55), k1, &tmp);
        hash ^= tmp;

        ptr = ptr[8..];
    }

    if (ptr.len >= 4) {
        // hash += byteorder.LittleEndian.toU32(ptr[0..4].*) * k3
        _ = @mulWithOverflow(u64, @intCast(u64, byteorder.LittleEndian.toU32(ptr[0..4].*)), k3, &tmp);
        _ = @addWithOverflow(u64, hash, tmp, &hash);

        // hash ^= bits.rotateLeft64(hash, -26) * k1
        _ = @mulWithOverflow(u64, bits.rotateLeft64(hash, -26), k1, &tmp);
        hash ^= tmp;

        ptr = ptr[4..];
    }

    if (ptr.len >= 2) {
        // hash += byteorder.LittleEndian.toU16(ptr[0..2].*)) * k3
        _ = @mulWithOverflow(u64, @intCast(u64, byteorder.LittleEndian.toU16(ptr[0..2].*)), k3, &tmp);
        _ = @addWithOverflow(u64, hash, tmp, &hash);

        // hash ^= bits.rotateLeft64(hash, -48) * k1
        _ = @mulWithOverflow(u64, bits.rotateLeft64(hash, -48), k1, &tmp);
        hash ^= tmp;

        ptr = ptr[2..];
    }

    if (ptr.len >= 1) {
        // hash += ptr[0] * k3
        _ = @mulWithOverflow(u64, @intCast(u64, ptr[0]), k3, &tmp);
        _ = @addWithOverflow(u64, hash, tmp, &hash);

        // hash ^= bits.rotateLeft64(hash, -37) * k1
        _ = @mulWithOverflow(u64, bits.rotateLeft64(hash, -37), k1, &tmp);
        hash ^= tmp;
    }

    hash ^= bits.rotateLeft64(hash, -28);
    _ = @mulWithOverflow(u64, hash, k0, &hash); // hash *= k0
    hash ^= bits.rotateLeft64(hash, -29);

    return hash;
}

pub fn hash128(buffer: []u8, seed: u64) u128 {
    const k0 = 0xC83A91E1;
    const k1 = 0x8648DBDB;
    const k2 = 0x7BDEC03B;
    const k3 = 0x2F5870A5;

    var tmp: u64 = 0;
    var ptr = buffer;

    var v = [4]u64{ 0, 0, 0, 0 };

    // v[0] = (seed - k0) * k3
    _ = @subWithOverflow(u64, seed, k0, &tmp);
    _ = @mulWithOverflow(u64, tmp, k3, &v[0]);

    // v[1] = (seed + k1) * k2
    _ = @addWithOverflow(u64, seed, k1, &tmp);
    _ = @mulWithOverflow(u64, tmp, k2, &v[1]);

    if (ptr.len >= 32) {
        // v[2] = (seed + k0) * k2
        _ = @addWithOverflow(u64, seed, k0, &tmp);
        _ = @mulWithOverflow(u64, tmp, k2, &v[2]);

        // v[3] = (seed - k1) * k3
        _ = @subWithOverflow(u64, seed, k1, &tmp);
        _ = @mulWithOverflow(u64, tmp, k3, &v[3]);

        while (ptr.len >= 32) {
            // v[0] += byteorder.LittleEndian.toU64(ptr[0..8].*) * k0
            _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[0..8].*), k0, &tmp);
            _ = @addWithOverflow(u64, v[0], tmp, &v[0]);
            ptr = ptr[8..];

            _ = @addWithOverflow(u64, bits.rotateLeft64(v[0], -29), v[2], &v[0]);

            // v[1] += byteorder.LittleEndian.toU64(ptr[0..8].*) * k1
            _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[0..8].*), k1, &tmp);
            _ = @addWithOverflow(u64, v[1], tmp, &v[1]);
            ptr = ptr[8..];

            _ = @addWithOverflow(u64, bits.rotateLeft64(v[1], -29), v[3], &v[1]);

            // v[2] += byteorder.LittleEndian.toU64(ptr[0..8].*) * k2
            _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[0..8].*), k2, &tmp);
            _ = @addWithOverflow(u64, v[2], tmp, &v[2]);
            ptr = ptr[8..];

            _ = @addWithOverflow(u64, bits.rotateLeft64(v[2], -29), v[0], &v[2]);

            // v[3] += byteorder.LittleEndian.toU64(ptr[0..8].*) * k3
            _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[0..8].*), k3, &tmp);
            _ = @addWithOverflow(u64, v[3], tmp, &v[3]);
            ptr = ptr[8..];

            // v[3] = bits.rotateLeft64(v[3], -29) + v[1]
            _ = @addWithOverflow(u64, bits.rotateLeft64(v[3], -29), v[1], &v[3]);
        }

        // v[2] ^= bits.rotateLeft64(((v[0]+v[3])*k0)+v[1], -21) * k1
        _ = @addWithOverflow(u64, v[0], v[3], &tmp);
        _ = @mulWithOverflow(u64, tmp, k0, &tmp);
        _ = @addWithOverflow(u64, tmp, v[1], &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -21), k1, &tmp);
        v[2] ^= tmp;

        // v[3] ^= bits.rotateLeft64(((v[1]+v[2])*k1)+v[0], -21) * k0
        _ = @addWithOverflow(u64, v[1], v[2], &tmp);
        _ = @mulWithOverflow(u64, tmp, k1, &tmp);
        _ = @addWithOverflow(u64, tmp, v[0], &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -21), k0, &tmp);
        v[3] ^= tmp;

        // v[0] ^= bits.rotateLeft64(((v[0]+v[2])*k0)+v[3], -21) * k1
        _ = @addWithOverflow(u64, v[0], v[2], &tmp);
        _ = @mulWithOverflow(u64, tmp, k0, &tmp);
        _ = @addWithOverflow(u64, tmp, v[3], &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -21), k1, &tmp);
        v[0] ^= tmp;

        // v[1] ^= bits.rotateLeft64(((v[1]+v[3])*k1)+v[2], -21) * k0
        _ = @addWithOverflow(u64, v[1], v[3], &tmp);
        _ = @mulWithOverflow(u64, tmp, k1, &tmp);
        _ = @addWithOverflow(u64, tmp, v[2], &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -21), k0, &tmp);
        v[1] ^= tmp;
    }

    if (ptr.len >= 16) {
        // v[0] += byteorder.LittleEndian.toU64(ptr[0..8].*) * k2
        _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[0..8].*), k2, &tmp);
        _ = @addWithOverflow(u64, tmp, v[0], &v[0]);
        ptr = ptr[8..];

        _ = @mulWithOverflow(u64, bits.rotateLeft64(v[0], -33), k3, &v[0]);

        // v[1] += byteorder.LittleEndian.toU64(ptr[0..8].*) * k2
        _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[0..8].*), k2, &tmp);
        _ = @addWithOverflow(u64, tmp, v[1], &v[1]);
        ptr = ptr[8..];

        _ = @mulWithOverflow(u64, bits.rotateLeft64(v[1], -33), k3, &v[1]);

        // v[0] ^= bits.rotateLeft64((v[0]*k2)+v[1], -45) * k1
        _ = @mulWithOverflow(u64, v[0], k2, &tmp);
        _ = @addWithOverflow(u64, tmp, v[1], &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -45), k1, &tmp);
        v[0] ^= tmp;

        // v[1] ^= bits.rotateLeft64((v[1]*k3)+v[0], -45) * k0
        _ = @mulWithOverflow(u64, v[1], k3, &tmp);
        _ = @addWithOverflow(u64, tmp, v[0], &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -45), k0, &tmp);
        v[1] ^= tmp;
    }

    if (ptr.len >= 8) {
        // v[0] += byteorder.LittleEndian.toU64(ptr[0..8].*) * k2
        _ = @mulWithOverflow(u64, byteorder.LittleEndian.toU64(ptr[0..8].*), k2, &tmp);
        _ = @addWithOverflow(u64, tmp, v[0], &v[0]);
        ptr = ptr[8..];

        _ = @mulWithOverflow(u64, bits.rotateLeft64(v[0], -33), k3, &v[0]);

        // v[0] ^= bits.rotateLeft64((v[0]*k2)+v[1], -27) * k1
        _ = @mulWithOverflow(u64, v[0], k2, &tmp);
        _ = @addWithOverflow(u64, tmp, v[1], &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -27), k1, &tmp);
        v[0] ^= tmp;
    }

    if (ptr.len >= 4) {
        // v[1] += byteorder.LittleEndian.toU32(ptr[0..4].*)) * k2
        _ = @mulWithOverflow(u64, @intCast(u64, byteorder.LittleEndian.toU32(ptr[0..4].*)), k2, &tmp);
        _ = @addWithOverflow(u64, tmp, v[1], &v[1]);
        ptr = ptr[4..];

        // v[1] = bits.rotateLeft64(v[1], -33) * k3
        _ = @mulWithOverflow(u64, bits.rotateLeft64(v[1], -33), k3, &v[1]);

        // v[1] ^= bits.rotateLeft64((v[1]*k3)+v[0], -46) * k0
        _ = @mulWithOverflow(u64, v[1], k3, &tmp);
        _ = @addWithOverflow(u64, tmp, v[0], &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -46), k0, &tmp);
        v[1] ^= tmp;
    }

    if (ptr.len >= 2) {
        // v[0] += byteorder.LittleEndian.toU16(ptr[0..2].*)) * k2
        _ = @mulWithOverflow(u64, @intCast(u64, byteorder.LittleEndian.toU16(ptr[0..2].*)), k2, &tmp);
        _ = @addWithOverflow(u64, tmp, v[0], &v[0]);
        ptr = ptr[2..];

        // v[0] = bits.rotateLeft64(v[0], -33) * k3
        _ = @mulWithOverflow(u64, bits.rotateLeft64(v[0], -33), k3, &v[0]);

        // v[0] ^= bits.rotateLeft64((v[0]*k2)+v[1], -22) * k1
        _ = @mulWithOverflow(u64, v[0], k2, &tmp);
        _ = @addWithOverflow(u64, tmp, v[1], &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -22), k1, &tmp);
        v[0] ^= tmp;
    }

    if (ptr.len >= 1) {
        // v[1] += ptr[0] * k2
        _ = @mulWithOverflow(u64, @intCast(u64, ptr[0]), k2, &tmp);
        _ = @addWithOverflow(u64, v[1], tmp, &v[1]);

        // v[1] = bits.rotateLeft64(v[1], -33) * k3
        _ = @mulWithOverflow(u64, bits.rotateLeft64(v[1], -33), k3, &v[1]);

        // v[1] ^= bits.rotateLeft64((v[1]*k3)+v[0], -58) * k0
        _ = @mulWithOverflow(u64, v[1], k3, &tmp);
        _ = @addWithOverflow(u64, tmp, v[0], &tmp);
        _ = @mulWithOverflow(u64, bits.rotateLeft64(tmp, -58), k0, &tmp);
        v[1] ^= tmp;
    }

    // v[0] += bits.rotateLeft64((v[0]*k0)+v[1], -13)
    _ = @mulWithOverflow(u64, v[0], k0, &tmp);
    _ = @addWithOverflow(u64, tmp, v[1], &tmp);
    _ = @addWithOverflow(u64, bits.rotateLeft64(tmp, -13), v[0], &v[0]);

    // v[1] += bits.rotateLeft64((v[1]*k1)+v[0], -37)
    _ = @mulWithOverflow(u64, v[1], k1, &tmp);
    _ = @addWithOverflow(u64, tmp, v[0], &tmp);
    _ = @addWithOverflow(u64, bits.rotateLeft64(tmp, -37), v[1], &v[1]);

    // v[0] += bits.rotateLeft64((v[0]*k2)+v[1], -13)
    _ = @mulWithOverflow(u64, v[0], k2, &tmp);
    _ = @addWithOverflow(u64, tmp, v[1], &tmp);
    _ = @addWithOverflow(u64, bits.rotateLeft64(tmp, -13), v[0], &v[0]);

    // v[1] += bits.rotateLeft64((v[1]*k3)+v[0], -37)
    _ = @mulWithOverflow(u64, v[1], k3, &tmp);
    _ = @addWithOverflow(u64, tmp, v[0], &tmp);
    _ = @addWithOverflow(u64, bits.rotateLeft64(tmp, -37), v[1], &v[1]);

    return @intCast(u128, v[0]) << 64 | v[1];
}

test "hash64" {
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
    {
        const seed = 0;
        const hash = hash64(data[0..], seed);
        const expected = byteorder.LittleEndian.toU64([_]u8{ 0x6B, 0x75, 0x3D, 0xAE, 0x06, 0x70, 0x4B, 0xAD });
        try std.testing.expect(hash == expected);
    }

    {
        const seed = 1;
        const hash = hash64(data[0..], seed);
        const expected = byteorder.LittleEndian.toU64([_]u8{ 0x3B, 0x0D, 0x48, 0x1C, 0xF4, 0xB9, 0xB8, 0xDF });
        try std.testing.expect(hash == expected);
    }
}

test "hash128" {
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
    {
        const seed = 0;
        const hash = hash128(data[0..], seed);
        const expectedUpper64Bits = byteorder.LittleEndian.toU64([_]u8{ 0xC7, 0x7C, 0xE2, 0xBF, 0xA4, 0xED, 0x9F, 0x9B });
        const expectedLower64Bits = byteorder.LittleEndian.toU64([_]u8{ 0x05, 0x48, 0xB2, 0xAC, 0x50, 0x74, 0xA2, 0x97 });

        try std.testing.expect(@truncate(u64, (hash & 0xffffffffffffffff0000000000000000) >> 64) == expectedUpper64Bits);
        try std.testing.expect(@truncate(u64, (hash & 0xffffffffffffffff)) == expectedLower64Bits);
    }

    {
        const seed = 1;
        const hash = hash128(data[0..], seed);
        const expectedUpper64Bits = byteorder.LittleEndian.toU64([_]u8{ 0x45, 0xA3, 0xCD, 0xB8, 0x38, 0x19, 0x9D, 0x7F });
        const expectedLower64Bits = byteorder.LittleEndian.toU64([_]u8{ 0xBD, 0xD6, 0x8D, 0x86, 0x7A, 0x14, 0xEC, 0xEF });

        try std.testing.expect(@truncate(u64, (hash & 0xffffffffffffffff0000000000000000) >> 64) == expectedUpper64Bits);
        try std.testing.expect(@truncate(u64, (hash & 0xffffffffffffffff)) == expectedLower64Bits);
    }
}
