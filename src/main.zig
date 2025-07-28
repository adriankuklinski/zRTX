const std = @import("std");
const Vec3 = @import("./vec3.zig").Vec3;
const Color = @import("./color.zig").Color;
const Point3 = Vec3;
const writeColor = @import("./color.zig").writeColor;
const Ray = @import("./ray.zig").Ray;
const Hittable = @import("./hittable.zig").Hittable;
const HitRecord = @import("./hittable.zig").HitRecord;
const HittableList = @import("./hittable_list.zig").HittableList;

fn hitSphere(center: Point3, radius: f64, ray: Ray) f64 {
    const oc: Vec3 = center.sub(ray.getOrigin());
    const a: f64 = ray.getDir().lengthSquared();
    const h: f64 = ray.getDir().dot(oc);
    const c: f64 = oc.lengthSquared() - radius * radius;
    const discriminant = h * h -  a * c;
    if (discriminant < 0) {
        return -1.0;
    } else {
        return (h - @sqrt(discriminant)) / a;
    }
}

fn rayColor(r: Ray, world: HittableList) Color {
    var rec: HitRecord = undefined;
    if (world.hit(r, 0, std.math.inf(f64), &rec)) {
        return rec.normal.add(Color.new(1, 1, 1)).scale(0.5);
    }
    
    const unit_direction = r.getDir().unitVector();
    const a = 0.5 * (unit_direction.y() + 1.0);
    return Color.new(1.0, 1.0, 1.0).scale(1.0 - a)
        .add(Color.new(0.5, 0.7, 1.0).scale(a));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const aspect_ratio: f64 = 16.0 / 9.0;
    const image_width: i16 = 400;
    var image_height: i16 = @intFromFloat(image_width / aspect_ratio);
    image_height = if (image_height < 1) 1 else image_height;

    var world = HittableList.init(allocator);
    defer world.deinit();

    try world.addSphere(Point3.new(0, 0, -1), 0.5);
    try world.addSphere(Point3.new(0, -100.5, -1), 100);

    const focal_length: f64 = 1.0;
    const image_width_f: f64 = @floatFromInt(image_width);
    const image_height_f: f64 = @floatFromInt(image_height);
    const viewport_height: f64 = 2.0;
    const viewport_width: f64 = viewport_height * (image_width_f / image_height_f);
    const camera_center: Point3 = Point3.init();

    const viewport_u: Vec3 = Vec3.new(viewport_width, 0, 0);
    const viewport_v: Vec3 = Vec3.new(0, -viewport_height, 0);

    const pixel_delta_u: Vec3 = viewport_u.divide(@as(f64, @floatFromInt(image_width)));
    const pixel_delta_v: Vec3 = viewport_v.divide(@as(f64, @floatFromInt(image_height)));

    const viewport_upper_left: Vec3 = camera_center
        .sub(Vec3.new(0, 0, focal_length))
        .sub(viewport_u.scale(0.5)) 
        .sub(viewport_v.scale(0.5));

    const pixel00_loc: Vec3 = viewport_upper_left
        .add(pixel_delta_u.add(pixel_delta_v).scale(0.5));

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{d} {d}\n255\n", .{image_width, image_height});

    const image_height_u: usize = @as(usize, @intCast(image_height));
    const image_width_u: usize = @as(usize, @intCast(image_width));
    for (0..image_height_u) |row| {
        std.log.info("\rScanlines remaining: {d} ", .{image_height_u - row});
        for (0..image_width_u) |col| {
            const pixel_center = pixel00_loc
                .add(pixel_delta_u.scale(@as(f64, @floatFromInt(col))))
                .add(pixel_delta_v.scale(@as(f64, @floatFromInt(row))));

            const ray_direction = pixel_center.sub(camera_center);
            const r = Ray.new(camera_center, ray_direction);

            const pixel_color = rayColor(r, world);
            try writeColor(stdout, pixel_color);
        }
    }

    std.log.info("\rDone.\n", .{});
    try bw.flush();
}
