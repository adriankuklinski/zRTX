const std = @import("std");
const Vec3 = @import("./vec3.zig").Vec3;
const Point3 = Vec3;

pub const RayResult = struct{
    origin: Point3,
    dir: Vec3,
};

pub const Ray = struct{
    const Self = @This();

    origin: Point3,
    dir: Vec3,

    pub fn init() Self {
        return .{ 
            .origin = Point3.init(),
            .dir = Vec3.init(),
        };
    }

    pub fn new(origin: Point3, direction: Vec3) Self {
        return .{
            .origin = origin,
            .dir = direction,
        };
    }

    pub fn getOrigin(self: Self) Point3 { return self.origin; }
    pub fn getDir(self: Self) Vec3 { return self.dir; }

    pub fn at(self: Self, t: f64) Point3 {
        return self.origin.add(self.dir.scale(t));
    }
};
