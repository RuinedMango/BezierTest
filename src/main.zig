const sdl3 = @import("sdl3");
const std = @import("std");

const fps = 60;
const screen_width = 640;
const screen_height = 480;

fn setPixel(ssurface: sdl3.surface.Surface, x: i16, y: i16, red: u8, green: u8, blue: u8) void {
    _ = x;
    _ = y;
    _ = red;
    _ = green;
    _ = blue;
    ssurface.lock();
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
        try window.updateSurface();

        while (sdl3.events.poll()) |event|
            switch (event) {
                .quit => quit = true,
                .terminating => quit = true,
                else => {},
            };
    }
}
