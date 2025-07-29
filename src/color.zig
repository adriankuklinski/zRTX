const std = @import("std");
const Vec3 = @import("./vec3.zig").Vec3;
const Interval = @import("interval.zig").Interval;

pub const Color = Vec3;

const intensity = Interval.new(0.000, 0.999);

pub fn writeColor(writer: anytype, pixel_color: Color) !void {
    const r = pixel_color.x();
    const g = pixel_color.y();
    const b = pixel_color.z();

    const rbyte: i32 = @intFromFloat(256 * intensity.clamp(r));
    const gbyte: i32 = @intFromFloat(256 * intensity.clamp(g));
    const bbyte: i32 = @intFromFloat(256 * intensity.clamp(b));

    try writer.print("{d} {d} {d}\n", .{rbyte, gbyte, bbyte});
}
