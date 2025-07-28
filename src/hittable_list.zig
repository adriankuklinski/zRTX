const std = @import("std");
const Hittable = @import("./hittable.zig").Hittable;
const HitRecord = @import("./hittable.zig").HitRecord;
const Ray = @import("./ray.zig").Ray;
const Vec3 = @import("./vec3.zig").Vec3;
const Point3 = Vec3;

pub const HittableList = struct {
    const Self = @This();
    
    objects: std.ArrayList(Hittable),
    allocator: std.mem.Allocator,
    
    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .objects = std.ArrayList(Hittable).init(allocator),
            .allocator = allocator,
        };
    }
    
    pub fn initWithObject(allocator: std.mem.Allocator, object: Hittable) !Self {
        var list = Self.init(allocator);
        try list.add(object);
        return list;
    }
    
    pub fn deinit(self: *Self) void {
        self.objects.deinit();
    }
    
    pub fn clear(self: *Self) void {
        self.objects.clearRetainingCapacity();
    }
    
    pub fn add(self: *Self, object: Hittable) !void {
        try self.objects.append(object);
    }
    
    pub fn hit(self: Self, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
        var temp_rec: HitRecord = undefined;
        var hit_anything = false;
        var closest_so_far = ray_tmax;
        
        for (self.objects.items) |object| {
            if (object.hit(r, ray_tmin, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }
        
        return hit_anything;
    }
    
    pub fn addSphere(self: *Self, center: Point3, radius: f64) !void {
        try self.add(Hittable.makeSphere(center, radius));
    }
};
