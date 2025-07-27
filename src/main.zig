const std = @import("std");

pub fn main() !void {
    const image_width: i16 = 256;
    const image_height: i16 = 256;

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{d} {d}\n255\n", .{image_width, image_height});

    for (0..image_height) |row| {
        std.log.info("\rScanlines remaining: {d} ", .{image_height - row});
        for (0..image_width) |col| {
            const row_f: f16 = @floatFromInt(row);
            const col_f: f16 = @floatFromInt(col);
            const width_f: f16 = @floatFromInt(image_width - 1);
            const height_f: f16 = @floatFromInt(image_height - 1);
            
            const r: f16 = col_f / width_f;
            const g: f16 = row_f / height_f;
            const b: f16 = 0.0;
            
            const ir: i16 = @intFromFloat(@round(255.999 * r));
            const ig: i16 = @intFromFloat(@round(255.999 * g));
            const ib: i16 = @intFromFloat(@round(255.999 * b));
            
            try stdout.print("{d} {d} {d}\n", .{ir, ig, ib});
        }
    }
    std.log.info("\rDone.\n", .{});
}
