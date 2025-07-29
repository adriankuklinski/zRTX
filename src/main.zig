const std = @import("std");
const Point3 = @import("vec3.zig").Vec3;
const HittableList = @import("hittable_list.zig").HittableList;
const Camera = @import("camera.zig").Camera;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var world = HittableList.init(allocator);
    defer world.deinit();
    
    try world.addSphere(Point3.new(0, 0, -1), 0.5);
    try world.addSphere(Point3.new(0, -100.5, -1), 100);
    
    var cam = Camera.init();
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;
    
    try cam.render(world);
}
