const std = @import("std");

fn beU8(buf: []const u8, idx: usize) u8 {
    return std.mem.readInt(u8, buf[idx], std.builtin.Endian.big);
}

fn beI8(buf: []const u8, idx: usize) i8 {
    return std.mem.readInt(i8, buf[idx], std.builtin.Endian.big);
}

fn beU16(buf: []const u8, idx: usize) u16 {
    return std.mem.readInt(u16, buf[idx], std.builtin.Endian.big);
}

fn beI16(buf: []const u8, idx: usize) i16 {
    return std.mem.readInt(i16, buf[idx], std.builtin.Endian.big);
}

fn beU24(buf: []const u8, idx: usize) u24 {
    return std.mem.readInt(u24, buf[idx], std.builtin.Endian.big);
}

fn beU32(buf: []const u8, idx: usize) u32 {
    return std.mem.readInt(u32, buf[idx], std.builtin.Endian.big);
}

fn beI32(buf: []const u8, idx: usize) i32 {
    return std.mem.readInt(i32, buf[idx], std.builtin.Endian.big);
}

fn beFixed(buf: []const u8, idx: usize) f32 {
    // 16.16 fixed -> float
    const v = beI32(buf, idx);
    return @as(f32, @floatFromInt(v)) / 65536.0;
}

pub fn readFile() !void {
    const file = try std.fs.cwd().openFile("font.otf", .{});
    defer file.close();
}
