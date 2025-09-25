const sdl3 = @import("sdl3");
const std = @import("std");

fn setPixel(ssurface: sdl3.surface.Surface, x: u64, y: u64, red: u8, green: u8, blue: u8) !void {
    var pixels: []u8 = ssurface.getPixels().?;
    const bytes_pixel = ssurface.getFormat().?.getBytesPerPixel();
    const pitch = ssurface.getPitch();
    const offset = y * pitch + x * bytes_pixel;
    pixels[offset + 0] = blue;
    pixels[offset + 1] = green;
    pixels[offset + 2] = red;
}

fn drawThickPixel(surface: sdl3.surface.Surface, x: u64, y: u64, thickness: u64, r: u8, g: u8, b: u8) !void {
    const half = thickness / 2;
    var dx: i64 = -@as(i64, @intCast(half));
    while (dx <= half) : (dx += 1) {
        var dy: i64 = -@as(i64, @intCast(half));
        while (dy <= half) : (dy += 1) {
            if (dx * dx + dy * dy <= half * half) {
                try setPixel(surface, @as(u64, @intCast(@as(i32, @intCast(x)) + dx)), @as(u64, @intCast(@as(i32, @intCast(y)) + dy)), r, g, b);
            }
        }
    }
}

pub fn drawQuadraticBezier(surface: sdl3.surface.Surface, p0x: i64, p0y: i64, p1x: i64, p1y: i64, p2x: i64, p2y: i64, thickness: u64) !void {
    const step: f64 = 1.0 / (std.math.hypot(@as(f64, @floatFromInt(p1x - p0x)), @as(f64, @floatFromInt(p1y - p0y))) + std.math.hypot(@as(f64, @floatFromInt(p2x - p1x)), @as(f64, @floatFromInt(p2y - p1y)))); // smaller = smoother
    var t: f64 = 0.0;
    var stepper: u8 = 0;

    while (t <= 1.0) : (t += step) {
        const one_minus_t = 1.0 - t;

        const xf = one_minus_t * one_minus_t * @as(f64, @floatFromInt(p0x)) +
            2 * one_minus_t * t * @as(f64, @floatFromInt(p1x)) +
            t * t * @as(f64, @floatFromInt(p2x));

        const yf = one_minus_t * one_minus_t * @as(f64, @floatFromInt(p0y)) +
            2 * one_minus_t * t * @as(f64, @floatFromInt(p1y)) +
            t * t * @as(f64, @floatFromInt(p2y));

        try drawThickPixel(surface, @as(u64, @intFromFloat(xf)), @as(u64, @intFromFloat(yf)), thickness, 255, stepper, 0);
        if (stepper == 254) {
            stepper = 0;
        } else {
            stepper += 1;
        }
    }
}

pub fn drawCubicBezier(surface: sdl3.surface.Surface, p0x: u64, p0y: u64, p1x: u64, p1y: u64, p2x: u64, p2y: u64, p3x: u64, p3y: u64, thickness: u64) !void {
    const step: f64 = 0.0001;
    var t: f64 = 0.0;

    while (t <= 1.0) : (t += step) {
        const one_minus_t = 1.0 - t;

        const xf = one_minus_t * one_minus_t * one_minus_t * @as(f64, @floatFromInt(p0x)) +
            3 * (one_minus_t * one_minus_t) * t * @as(f64, @floatFromInt(p1x)) +
            3 * one_minus_t * (t * t) * @as(f64, @floatFromInt(p2x)) +
            t * t * t * @as(f64, @floatFromInt(p3x));
        const yf = one_minus_t * one_minus_t * one_minus_t * @as(f64, @floatFromInt(p0y)) +
            3 * (one_minus_t * one_minus_t) * t * @as(f64, @floatFromInt(p1y)) +
            3 * one_minus_t * (t * t) * @as(f64, @floatFromInt(p2y)) +
            t * t * t * @as(f64, @floatFromInt(p3y));

        try drawThickPixel(surface, @as(u64, @intFromFloat(xf)), @as(u64, @intFromFloat(yf)), thickness, 255, 0, 0);
    }
}

pub fn bresenhamsLine(surface: sdl3.surface.Surface, x0: u64, y0: u64, x1: u64, y1: u64, thickness: u64) !void {
    var x: i32 = @intCast(x0);
    var y: i32 = @intCast(y0);

    const dx: i32 = @intCast(@abs(x1 - x0));
    const dy: i32 = @intCast(@abs(y1 - y0));

    var sx: i32 = 0;
    var sy: i32 = 0;

    if (x < x1) {
        sx = 1;
    } else {
        sx = -1;
    }

    if (y < y1) {
        sy = 1;
    } else {
        sy = -1;
    }

    var err = dx - dy;

    while (true) {
        try drawThickPixel(surface, @as(u64, @intCast(x)), @as(u64, @intCast(y)), thickness, 255, 0, 0); // plot current pixel

        if (x == x1 and y == y1) break; // finished

        const e2 = 2 * err;
        if (e2 > -dy) {
            err -= dy;
            x = x + sx;
        }
        if (e2 < dx) {
            err += dx;
            y = y + sy;
        }
    }
}
