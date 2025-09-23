const sdl3 = @import("sdl3");
const std = @import("std");

const fps = 60;
const screen_width = 400;
const screen_height = 400;

fn setPixel(ssurface: sdl3.surface.Surface, x: usize, y: usize, red: u8, green: u8, blue: u8) !void {
    try ssurface.lock();
    var pixels: []u8 = ssurface.getPixels().?;
    const bytes_pixel = ssurface.getFormat().?.getBytesPerPixel();
    pixels[y * ssurface.getPitch() + x * bytes_pixel + 0] = blue;
    pixels[y * ssurface.getPitch() + x * bytes_pixel + 1] = green;
    pixels[y * ssurface.getPitch() + x * bytes_pixel + 2] = red;
    ssurface.unlock();
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
        for (0..screen_width) |i| {
            for (0..screen_height) |l| {
                if (i % 2 == 1) {
                    if (l % 2 == 0) {
                        try setPixel(surface, i, l, 255, 0, 0);
                    }
                }
            }
        }
        try window.updateSurface();

        while (sdl3.events.poll()) |event|
            switch (event) {
                .quit => quit = true,
                .terminating => quit = true,
                else => {},
            };
    }
}
