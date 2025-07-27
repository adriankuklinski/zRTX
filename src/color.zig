const std = @import("std");
const Vec3 = @import("./vec3.zig").Vec3;

pub const Color = Vec3;

pub fn writeColor(writer: anytype, pixel_color: Color) !void {
    const r = pixel_color.x();
    const g = pixel_color.y();
    const b = pixel_color.z();

    const rbyte: i32 = @intFromFloat(255.999 * r);
    const gbyte: i32 = @intFromFloat(255.999 * g);
    const bbyte: i32 = @intFromFloat(255.999 * b);

    try writer.print("{d} {d} {d}\n", .{rbyte, gbyte, bbyte});
}
