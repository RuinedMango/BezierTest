const sdl3 = @import("sdl3");
const std = @import("std");

const fps = 60;
const screen_width = 400;
const screen_height = 400;

fn setPixel(ssurface: sdl3.surface.Surface, x: u64, y: u64, red: u8, green: u8, blue: u8) !void {
    try ssurface.lock();
    var pixels: []u8 = ssurface.getPixels().?;
    const bytes_pixel = ssurface.getFormat().?.getBytesPerPixel();
    pixels[y * ssurface.getPitch() + x * bytes_pixel + 0] = blue;
    pixels[y * ssurface.getPitch() + x * bytes_pixel + 1] = green;
    pixels[y * ssurface.getPitch() + x * bytes_pixel + 2] = red;
    ssurface.unlock();
}

fn drawThickPixel(surface: sdl3.surface.Surface, x: u64, y: u64, thickness: u64, r: u8, g: u8, b: u8) !void {
    const half = thickness / 2;
    var dx: i32 = -@as(i32, @intCast(half));
    while (dx <= half) {
        var dy: i32 = -@as(i32, @intCast(half));
        while (dy <= half) {
            try setPixel(surface, @as(u64, @intCast(@as(i32, @intCast(x)) + dx)), @as(u64, @intCast(@as(i32, @intCast(y)) + dy)), r, g, b);
            dy += 1;
        }
        dx += 1;
    }
}

fn drawQuadraticBezier(surface: sdl3.surface.Surface, p0x: u64, p0y: u64, p1x: u64, p1y: u64, p2x: u64, p2y: u64, thickness: u64) !void {
    const step: f64 = 0.0001; // smaller = smoother
    var t: f64 = 0.0;

    while (t <= 1.0) : (t += step) {
        const one_minus_t = 1.0 - t;

        // Compute floating point coordinates
        const xf = one_minus_t * one_minus_t * @as(f64, @floatFromInt(p0x)) +
            2 * one_minus_t * t * @as(f64, @floatFromInt(p1x)) +
            t * t * @as(f64, @floatFromInt(p2x));

        const yf = one_minus_t * one_minus_t * @as(f64, @floatFromInt(p0y)) +
            2 * one_minus_t * t * @as(f64, @floatFromInt(p1y)) +
            t * t * @as(f64, @floatFromInt(p2y));

        // Cast to u64 to pass to drawThickPixel
        try drawThickPixel(surface, @as(u64, @intFromFloat(xf)), @as(u64, @intFromFloat(yf)), thickness, 255, 0, 0);
    }
}

fn bresenhamsLine(surface: sdl3.surface.Surface, x0: u64, y0: u64, x1: u64, y1: u64, thickness: u64) !void {
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
        //

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

pub fn main() !void {
    defer sdl3.shutdown();

    const init_flags = sdl3.InitFlags{ .video = true };
    try sdl3.init(init_flags);
    defer sdl3.quit(init_flags);

    const window = try sdl3.video.Window.init("Hello SDL3", screen_width, screen_height, .{});
    defer window.deinit();

    var fps_capper = sdl3.extras.FramerateCapper(f32){ .mode = .{ .limited = fps } };

    var quit = false;
    while (!quit) {
        const dt = fps_capper.delay();
        _ = dt;

        const surface = try window.getSurface();
        try surface.fillRect(null, surface.mapRgb(128, 255, 255));
        // B
        try bresenhamsLine(surface, 10, 10, 10, 90, 3);
        try drawQuadraticBezier(surface, 10, 10, 50, 10, 10, 50, 3);
        try drawQuadraticBezier(surface, 10, 50, 50, 50, 10, 90, 3);
        // E
        try bresenhamsLine(surface, 50, 10, 50, 90, 3);
        try bresenhamsLine(surface, 50, 10, 80, 10, 3);
        try bresenhamsLine(surface, 50, 50, 80, 50, 3);
        try bresenhamsLine(surface, 50, 90, 80, 90, 3);

        const x = sdl3.mouse.getState().x;
        const y = sdl3.mouse.getState().y;

        try drawQuadraticBezier(surface, 10, 10, @intFromFloat(x), @intFromFloat(y), 390, 10, 3);

        try window.updateSurface();

        while (sdl3.events.poll()) |event|
            switch (event) {
                .quit => quit = true,
                .terminating => quit = true,
                else => {},
            };
    }
}
