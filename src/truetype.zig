const std = @import("std");

fn beU8(buf: []const u8, idx: usize) u8 {
    return buf[idx];
}

fn beU16(buf: []const u8, idx: usize) u16 {
    return (@as(u16, buf[idx]) << 8) | @as(u16, buf[idx + 1]);
}

fn beI16(buf: []const u8, idx: usize) i16 {
    return @as(i16, beU16(buf, idx));
}

fn beU32(buf: []const u8, idx: usize) u32 {
    return (@as(u32, buf[idx]) << 24) |
        (@as(u32, buf[idx + 1]) << 16) |
        (@as(u32, buf[idx + 2]) << 8) |
        (@as(u32, buf[idx + 3]));
}

fn beI32(buf: []const u8, idx: usize) i32 {
    return @as(i32, beU32(buf, idx));
}

fn beFixed(buf: []const u8, idx: usize) f32 {
    // 16.16 fixed -> float
    const v = beI32(buf, idx);
    return @as(f32, @floatFromInt(v)) / 65536.0;
}
