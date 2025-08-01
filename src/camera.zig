const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const randomOnHemesphere = @import("vec3.zig").randomOnHemisphere;
const randomUnitVector = @import("vec3.zig").randomUnitVector;
const Point3 = Vec3;
const Color = Vec3;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittable.zig").HitRecord;
const HittableList = @import("hittable_list.zig").HittableList;
const Interval = @import("interval.zig").Interval;
const writeColor = @import("color.zig").writeColor;
const Utility = @import("./utility.zig").Utility;

pub const Camera = struct {
    const Self = @This();
    
    aspect_ratio: f64,
    image_width: i32 ,
    samples_per_pixel: i32,
    max_depth: i32,
    
    image_height: i32,
    pixel_samples_scale: f64,
    center: Point3,
    pixel00_loc: Point3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    
    pub fn init() Self {
        return .{
            .aspect_ratio = 1.0,
            .image_width = 100,
            .image_height = undefined,
            .samples_per_pixel = 10,
            .max_depth = 10,
            .pixel_samples_scale = undefined,
            .center = undefined,
            .pixel00_loc = undefined,
            .pixel_delta_u = undefined,
            .pixel_delta_v = undefined,
        };
    }
    
    pub fn new(aspect_ratio: f64, image_width: i32) Self {
        return .{
            .aspect_ratio = aspect_ratio,
            .image_width = image_width,
            .image_height = undefined,
            .center = undefined,
            .pixel00_loc = undefined,
            .pixel_delta_u = undefined,
            .pixel_delta_v = undefined,
        };
    }
    
    pub fn render(self: *Self, world: HittableList) !void {
        self.initialize();
        
        const stdout_file = std.io.getStdOut().writer();
        var bw = std.io.bufferedWriter(stdout_file);
        const stdout = bw.writer();
        
        try stdout.print("P3\n{d} {d}\n255\n", .{ self.image_width, self.image_height });
        
        for (0..@as(usize, @intCast(self.image_height))) |j| {
            std.log.info("\rScanlines remaining: {d} ", .{self.image_height - @as(i32, @intCast(j))});
            for (0..@as(usize, @intCast(self.image_width))) |i| {
                var pixel_color = Color.new(0, 0, 0);
                for (0..@as(usize, @intCast(self.samples_per_pixel))) |_| {
                    const r = self.getRay(@as(i32, @intCast(i)), @as(i32, @intCast(j)));
                    pixel_color = pixel_color.add(self.rayColor(r, self.max_depth, world));
                }

                try writeColor(stdout, pixel_color.scale(self.pixel_samples_scale));
            }
        }
        
        std.log.info("\rDone.\n", .{});
        try bw.flush();
    }
    
    fn initialize(self: *Self) void {
        self.image_height = @intFromFloat(@as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio);
        self.image_height = if (self.image_height < 1) 1 else self.image_height;
        
        self.pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(self.samples_per_pixel));
        self.center = Point3.init();
        
        const focal_length: f64 = 1.0;
        const viewport_height: f64 = 2.0;
        const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(self.image_width)) / @as(f64, @floatFromInt(self.image_height)));
        
        const viewport_u = Vec3.new(viewport_width, 0, 0);
        const viewport_v = Vec3.new(0, -viewport_height, 0);
        
        self.pixel_delta_u = viewport_u.divide(@as(f64, @floatFromInt(self.image_width)));
        self.pixel_delta_v = viewport_v.divide(@as(f64, @floatFromInt(self.image_height)));
        
        const viewport_upper_left = self.center
            .sub(Vec3.new(0, 0, focal_length))
            .sub(viewport_u.scale(0.5))
            .sub(viewport_v.scale(0.5));
        
        self.pixel00_loc = viewport_upper_left
            .add(self.pixel_delta_u.add(self.pixel_delta_v).scale(0.5));
    }

    fn getRay(self: Self, i: i32, j: i32) Ray {
        const offset: Vec3 = sampleSquare();
        const pixel_sample = self.pixel00_loc
            .add(self.pixel_delta_u.scale(@as(f64, @floatFromInt(i)) + offset.x()))
            .add(self.pixel_delta_v.scale(@as(f64, @floatFromInt(j)) + offset.y()));

        const origin: Point3 = self.center;
        const direction: Vec3 = pixel_sample.sub(origin);

        return Ray.new(origin, direction);
    }

    fn sampleSquare() Vec3 {
        var rng = Utility.createRng();
        return Vec3.new(Utility.randomDouble(&rng) - 0.5, Utility.randomDouble(&rng) - 0.5, 0);
    }
    
    fn rayColor(self: Self, r: Ray, depth: i32, world: HittableList) Color {
        if (depth <= 0) {
            return Color.new(0, 0, 0);
        }

        var rec: HitRecord = undefined;
        const ray_range = Interval.new(0.001, std.math.inf(f64));
        if (world.hit(r, ray_range, &rec)) {
            var scattered: Ray = undefined;
            var attenuation: Color = undefined;
            if (rec.material.scatter(r, rec, &attenuation, &scattered)) {
                return attenuation.mul(self.rayColor(scattered, depth - 1, world));
            }
            return Color.new(0, 0, 0);
        }
        
        const unit_direction = r.getDir().unitVector();
        const a = 0.5 * (unit_direction.y() + 1.0);
        return Color.new(1.0, 1.0, 1.0).scale(1.0 - a)
            .add(Color.new(0.5, 0.7, 1.0).scale(a));
    }
};

test "Camera initialization" {
    const testing = std.testing;
    
    const camera = Camera.init();
    try testing.expectEqual(@as(f64, 1.0), camera.aspect_ratio);
    try testing.expectEqual(@as(i32, 100), camera.image_width);
    
    const custom_camera = Camera.new(16.0 / 9.0, 400);
    try testing.expectEqual(@as(f64, 16.0 / 9.0), custom_camera.aspect_ratio);
    try testing.expectEqual(@as(i32, 400), custom_camera.image_width);
}
