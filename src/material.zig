const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Color = Vec3;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittable.zig").HitRecord;
const reflect = @import("vec3.zig").reflect;
const randomUnitVector = @import("vec3.zig").randomUnitVector;

pub const Lambertian = struct {
    albedo: Color,
};

pub const Metal = struct {
    albedo: Color,
};

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,
    
    pub fn scatter(self: Material, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        return switch (self) {
            .lambertian => |lambertian| {
                const scatter_direction = rec.normal.add(randomUnitVector());
                scattered.* = Ray.new(rec.p, scatter_direction);
                attenuation.* = lambertian.albedo;
                return true;
            },
            .metal => |metal| {
                const reflected = reflect(r_in.getDir(), rec.normal);
                scattered.* = Ray.new(rec.p, reflected);
                attenuation.* = metal.albedo;
                return true;
            },
        };
    }
    
    pub fn makeLambertian(albedo: Color) Material {
        return .{ .lambertian = Lambertian{ .albedo = albedo } };
    }
    
    pub fn makeMetal(albedo: Color) Material {
        return .{ .metal = Metal{ .albedo = albedo } };
    }
};

pub fn scatter(material: anytype, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
    return material.scatter(r_in, rec, attenuation, scattered);
}
