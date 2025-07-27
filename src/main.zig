const std = @import("std");
const Vec3 = @import("./vec3").Vec3;
const Color = @import("./color.zig").Color;
const writeColor = @import("./color.zig").writeColor;

pub fn main() !void {
    const image_width: i16 = 256;
    const image_height: i16 = 256;

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{d} {d}\n255\n", .{image_width, image_height});

    for (0..image_height) |row| {
        std.log.info("\rScanlines remaining: {d} ", .{image_height - row});
        const row_f: f32 = @floatFromInt(row);

        for (0..image_width) |col| {
            const col_f: f32 = @floatFromInt(col);
            const color: Color = Color.new(col_f/(image_width-1), row_f/(image_height-1), 0);
            try writeColor(stdout, color);
        }
    }

    std.log.info("\rDone.\n", .{});
    try bw.flush();
}

