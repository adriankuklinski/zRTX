const std = @import("std");
const Utility = @import("./utility.zig").Utility;

pub const Vec3 = struct {
    const Self = @This();
    
    e: [3]f64,
    
    pub fn init() Self {
        return .{ .e = .{ 0.0, 0.0, 0.0 } };
    }
    
    pub fn new(e0: f64, e1: f64, e2: f64) Self {
        return .{ .e = .{ e0, e1, e2 } };
    }
    
    pub fn x(self: Self) f64 {
        return self.e[0];
    }
    
    pub fn y(self: Self) f64 {
        return self.e[1];
    }
    
    pub fn z(self: Self) f64 {
        return self.e[2];
    }
    
    pub fn get(self: Self, i: usize) f64 {
        return self.e[i];
    }
    
    pub fn getPtr(self: *Self, i: usize) *f64 {
        return &self.e[i];
    }
    
    pub fn negate(self: Self) Self {
        return Self.new(-self.e[0], -self.e[1], -self.e[2]);
    }
    
    pub fn addAssign(self: *Self, v: Self) void {
        self.e[0] += v.e[0];
        self.e[1] += v.e[1];
        self.e[2] += v.e[2];
    }
    
    pub fn scaleAssign(self: *Self, t: f64) void {
        self.e[0] *= t;
        self.e[1] *= t;
        self.e[2] *= t;
    }
    
    pub fn divideAssign(self: *Self, t: f64) void {
        self.scaleAssign(1.0 / t);
    }
    
    pub fn lengthSquared(self: Self) f64 {
        return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
    }

    pub fn nearZero(self: Self) bool {
        const s = 1e-8;
        return (@abs(self.e[0]) < s) and (@abs(self.e[1]) < s) and (@abs(self.e[2]) < s);
    }
    
    pub fn length(self: Self) f64 {
        return @sqrt(self.lengthSquared());
    }
    
    pub fn add(self: Self, other: Self) Self {
        return Self.new(
            self.e[0] + other.e[0],
            self.e[1] + other.e[1],
            self.e[2] + other.e[2]
        );
    }
    
    pub fn sub(self: Self, other: Self) Self {
        return Self.new(
            self.e[0] - other.e[0],
            self.e[1] - other.e[1],
            self.e[2] - other.e[2]
        );
    }
    
    pub fn mul(self: Self, other: Self) Self {
        return Self.new(
            self.e[0] * other.e[0],
            self.e[1] * other.e[1],
            self.e[2] * other.e[2]
        );
    }
    
    pub fn scale(self: Self, t: f64) Self {
        return Self.new(t * self.e[0], t * self.e[1], t * self.e[2]);
    }
    
    pub fn divide(self: Self, t: f64) Self {
        return self.scale(1.0 / t);
    }
    
    pub fn dot(self: Self, other: Self) f64 {
        return self.e[0] * other.e[0] + 
               self.e[1] * other.e[1] + 
               self.e[2] * other.e[2];
    }
    
    pub fn cross(self: Self, other: Self) Self {
        return Self.new(
            self.e[1] * other.e[2] - self.e[2] * other.e[1],
            self.e[2] * other.e[0] - self.e[0] * other.e[2],
            self.e[0] * other.e[1] - self.e[1] * other.e[0]
        );
    }
    
    pub fn unitVector(self: Self) Self {
        return self.divide(self.length());
    }

    pub fn randomUnitVector(self: Self) Self {
        while (true) {
            const p = self.randomRange(-1, 1);
            const lensq = p.lengthSquared();
            if (1e-160 < lensq and lensq <= 1) {
                return p.divide(@sqrt(lensq));
            }
        }
    }

    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("{d} {d} {d}", .{ self.e[0], self.e[1], self.e[2] });
    }
};

pub fn add(u: Vec3, v: Vec3) Vec3 {
    return u.add(v);
}

pub fn sub(u: Vec3, v: Vec3) Vec3 {
    return u.sub(v);
}

pub fn mul(u: Vec3, v: Vec3) Vec3 {
    return u.mul(v);
}

pub fn scale(t: f64, v: Vec3) Vec3 {
    return v.scale(t);
}

pub fn scaleVec(v: Vec3, t: f64) Vec3 {
    return v.scale(t);
}

pub fn divide(v: Vec3, t: f64) Vec3 {
    return v.divide(t);
}

pub fn dot(u: Vec3, v: Vec3) f64 {
    return u.dot(v);
}

pub fn cross(u: Vec3, v: Vec3) Vec3 {
    return u.cross(v);
}

pub fn unitVector(v: Vec3) Vec3 {
    return v.unitVector();
}

pub fn randomUnitVector() Vec3 {
    while (true) {
        const p = randomRange(-1, 1);
        const lensq = p.lengthSquared();
        if (1e-160 < lensq and lensq <= 1) {
            return p.divide(@sqrt(lensq));
        }
    }
}

pub fn random() Vec3 {
    var rng = Utility.createRng();
    return Vec3.new(Utility.randomDouble(   &rng), Utility.randomDouble(&rng), Utility.randomDouble(&rng));
}

pub fn randomRange(min: f64, max: f64) Vec3 {
    var rng = Utility.createRng();
    return Vec3.new(
        Utility.randomDoubleRange(&rng, min, max),
        Utility.randomDoubleRange(&rng, min, max), 
        Utility.randomDoubleRange(&rng, min, max)
    );
}

pub fn randomOnHemisphere(normal: Vec3) Vec3 {
    const on_unit_sphere = randomUnitVector();
    if (on_unit_sphere.dot(normal) > 0.0) {
        return on_unit_sphere;
    } else {
        return on_unit_sphere.negate();
    }
}

pub fn reflect(v: Vec3, n: Vec3) Vec3 {
    return v.sub(n.scale(2.0 * v.dot(n)));
}

test "Vec3 basic operations" {
    const testing = std.testing;
    
    const v1 = Vec3.new(1.0, 2.0, 3.0);
    const v2 = Vec3.new(4.0, 5.0, 6.0);
    
    try testing.expectEqual(@as(f64, 1.0), v1.x());
    try testing.expectEqual(@as(f64, 2.0), v1.y());
    try testing.expectEqual(@as(f64, 3.0), v1.z());
    
    const sum = v1.add(v2);
    try testing.expectEqual(@as(f64, 5.0), sum.x());
    try testing.expectEqual(@as(f64, 7.0), sum.y());
    try testing.expectEqual(@as(f64, 9.0), sum.z());
    
    const dot_result = v1.dot(v2);
    try testing.expectEqual(@as(f64, 32.0), dot_result);
    
    const v3 = Vec3.new(3.0, 4.0, 0.0);
    try testing.expectEqual(@as(f64, 5.0), v3.length());
}

test "Vec3 mutation operations" {
    const testing = std.testing;
    
    var v = Vec3.new(1.0, 2.0, 3.0);
    v.scaleAssign(2.0);
    
    try testing.expectEqual(@as(f64, 2.0), v.x());
    try testing.expectEqual(@as(f64, 4.0), v.y());
    try testing.expectEqual(@as(f64, 6.0), v.z());
}
