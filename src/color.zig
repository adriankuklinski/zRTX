const std = @import("std");
const Vec3 = @import("./vec3.zig").Vec3;
const Point3 = Vec3;
const Color = Vec3;
const Interval = @import("interval.zig").Interval;
const Camera = @import("camera.zig").Camera;
const Hittable = @import("hittable.zig").Hittable;
const HittableList = @import("hittable_list.zig").HittableList;
const Material = @import("material.zig").Material;
const Sphere = @import("sphere.zig").Sphere;

const intensity = Interval.new(0.000, 0.999);

pub fn linearToGamma(linear_component: f64) f64 {
    if (linear_component > 0) {
        return @sqrt(linear_component);
    }
    return 0;
}

pub fn writeColor(writer: anytype, pixel_color: Color) !void {
    var r = pixel_color.x();
    var g = pixel_color.y();
    var b = pixel_color.z();

    r = linearToGamma(r);
    g = linearToGamma(g);
    b = linearToGamma(b);

    const rbyte: i32 = @intFromFloat(256 * intensity.clamp(r));
    const gbyte: i32 = @intFromFloat(256 * intensity.clamp(g));
    const bbyte: i32 = @intFromFloat(256 * intensity.clamp(b));

    try writer.print("{d} {d} {d}\n", .{rbyte, gbyte, bbyte});
}
