const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Point3 = Vec3;
const Color = Vec3;
const Hittable = @import("hittable.zig").Hittable;
const HittableList = @import("hittable_list.zig").HittableList;
const Camera = @import("camera.zig").Camera;
const Material = @import("material.zig").Material;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var world = HittableList.init(allocator);
    defer world.deinit();
    
    const material_ground = Material.makeLambertian(Color.new(0.8, 0.8, 0.0));
    const material_center = Material.makeLambertian(Color.new(0.1, 0.2, 0.5));
    const material_left = Material.makeMetal(Color.new(0.8, 0.8, 0.8));
    const material_right = Material.makeMetal(Color.new(0.8, 0.6, 0.2));

    try world.add(Hittable.makeSphere(Point3.new(0.0, -100.5, -1.0), 100.0, material_ground));
    try world.add(Hittable.makeSphere(Point3.new(0.0, 0.0, -1.2), 0.5, material_center));
    try world.add(Hittable.makeSphere(Point3.new(-1.0, 0.0, -1.0), 0.5, material_left));
    try world.add(Hittable.makeSphere(Point3.new(1.0, 0.0, -1.0), 0.5, material_right));
    
    var cam = Camera.init();
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;
    cam.samples_per_pixel = 100;
    cam.max_depth = 50;
    
    try cam.render(world);
}
