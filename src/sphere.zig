const Vec3 = @import("./vec3.zig").Vec3;
const Point3 = Vec3;
const Ray = @import("./ray.zig").Ray;
const HitRecord = @import("./hittable.zig").HitRecord;

pub const Sphere = struct {
    center: Point3,
    radius: f64,
    
    pub fn init(center: Point3, radius: f64) Sphere {
        return .{
            .center = center,
            .radius = @max(0.0, radius),
        };
    }
    
    pub fn hit(self: Sphere, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
        const oc = self.center.sub(r.getOrigin());
        const a = r.getDir().lengthSquared();
        const h = r.getDir().dot(oc);
        const c = oc.lengthSquared() - self.radius * self.radius;
        
        const discriminant = h * h - a * c;
        if (discriminant < 0) return false;
        
        const sqrtd = @sqrt(discriminant);
        
        var root = (h - sqrtd) / a;
        if (root <= ray_tmin or ray_tmax <= root) {
            root = (h + sqrtd) / a;
            if (root <= ray_tmin or ray_tmax <= root) return false;
        }
        
        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = rec.p.sub(self.center).divide(self.radius);
        rec.setFaceNormal(r, outward_normal);
        
        return true;
    }
};
