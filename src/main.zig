const sdl3 = @import("sdl3");
const std = @import("std");
const draw = @import("draw.zig");
const font = @import("truetype.zig");

const fps = 120;
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

        const mouseState = sdl3.mouse.getState();
        try surface.lock();
        try draw.drawQuadraticBezier(surface, 10, 10, @as(i64, @intFromFloat(mouseState.x)), @as(i64, @intFromFloat(mouseState.y)), 390, 390, 3);
        surface.unlock();

        try window.updateSurface();

        while (sdl3.events.poll()) |event|
            switch (event) {
                .quit => quit = true,
                .terminating => quit = true,
                else => {},
            };
    }
}
