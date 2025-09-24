const sdl3 = @import("sdl3");
const std = @import("std");
const draw = @import("draw.zig");

const fps = 60;
const screen_width = 400;
const screen_height = 400;

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
        try draw.bresenhamsLine(surface, 10, 10, 10, 90, 3);
        try draw.drawQuadraticBezier(surface, 10, 10, 50, 10, 10, 50, 3);
        try draw.drawQuadraticBezier(surface, 10, 50, 50, 50, 10, 90, 3);
        // E
        try draw.bresenhamsLine(surface, 50, 10, 50, 90, 3);
        try draw.bresenhamsLine(surface, 50, 10, 80, 10, 3);
        try draw.bresenhamsLine(surface, 50, 50, 80, 50, 3);
        try draw.bresenhamsLine(surface, 50, 90, 80, 90, 3);
        // Fuck it im not writing the rest

        const x = sdl3.mouse.getState().x;
        const y = sdl3.mouse.getState().y;

        try draw.drawCubicBezier(surface, 10, 10, @intFromFloat(x), @intFromFloat(y), 50, 50, 390, 10, 3);

        try window.updateSurface();

        while (sdl3.events.poll()) |event|
            switch (event) {
                .quit => quit = true,
                .terminating => quit = true,
                else => {},
            };
    }
}
