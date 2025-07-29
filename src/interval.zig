const std = @import("std");

pub const Interval = struct {
    const Self = @This();
    
    min: f64,
    max: f64,
    
    pub fn init() Self {
        return .{
            .min = std.math.inf(f64),
            .max = -std.math.inf(f64),
        };
    }
    
    pub fn new(min: f64, max: f64) Self {
        return .{
            .min = min,
            .max = max,
        };
    }
    
    pub fn size(self: Self) f64 {
        return self.max - self.min;
    }
    
    pub fn contains(self: Self, x: f64) bool {
        return self.min <= x and x <= self.max;
    }
    
    pub fn surrounds(self: Self, x: f64) bool {
        return self.min < x and x < self.max;
    }
    
    pub fn clamp(self: Self, x: f64) f64 {
        if (x < self.min) return self.min;
        if (x > self.max) return self.max;
        return x;
    }
    
    pub fn isEmpty(self: Self) bool {
        return self.min >= self.max;
    }
    
    pub fn center(self: Self) f64 {
        return (self.min + self.max) * 0.5;
    }
    
    pub fn expand(self: Self, delta: f64) Self {
        const padding = delta * 0.5;
        return Self.new(self.min - padding, self.max + padding);
    }
};

pub const empty = Interval.init();                                
pub const universe = Interval.new(-std.math.inf(f64), std.math.inf(f64));

pub const unit = Interval.new(0.0, 1.0);
pub const positive = Interval.new(0.0, std.math.inf(f64));

test "Interval basic functionality" {
    const testing = std.testing;
    
    const empty_interval = Interval.init();
    try testing.expect(empty_interval.isEmpty());
    try testing.expect(!empty_interval.contains(0.0));
    
    const interval = Interval.new(1.0, 5.0);
    try testing.expectEqual(@as(f64, 4.0), interval.size());
    try testing.expect(interval.contains(3.0));
    try testing.expect(!interval.contains(0.0));
    try testing.expect(!interval.contains(6.0));
    
    try testing.expect(interval.surrounds(3.0));
    try testing.expect(!interval.surrounds(1.0)); // Edge case
    try testing.expect(!interval.surrounds(5.0)); // Edge case
    
    try testing.expectEqual(@as(f64, 1.0), interval.clamp(0.0));
    try testing.expectEqual(@as(f64, 3.0), interval.clamp(3.0));
    try testing.expectEqual(@as(f64, 5.0), interval.clamp(6.0));
    
    try testing.expectEqual(@as(f64, 3.0), interval.center());
}

test "Interval constants" {
    const testing = std.testing;
    
    try testing.expect(empty.isEmpty());
    
    try testing.expect(universe.contains(1000000.0));
    try testing.expect(universe.contains(-1000000.0));
    try testing.expect(universe.surrounds(0.0));
}
