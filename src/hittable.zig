const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Point3 = Vec3;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;
const Interval = @import("interval.zig").Interval;
const Material = @import("material.zig").Material;

pub const HitRecord = struct {
    const Self = @This();

    p: Point3,
    normal: Vec3,
    material: Material,

    t: f64,
    front_face: bool,

    pub fn setFaceNormal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        self.front_face = r.getDir().dot(outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.negate();
    }
};

pub const Hittable = union(enum) {
    sphere: Sphere,
    
    pub fn hit(self: Hittable, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        return switch (self) {
            .sphere => |sphere| sphere.hit(r, ray_t, rec),
        };
    }
    
    pub fn makeSphere(center: Point3, radius: f64, material: Material) Hittable {
        return .{ .sphere = Sphere.init(center, radius, material) };
    }
};

pub fn hit(hittable: anytype, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
    return hittable.hit(r, ray_t, rec);
}
