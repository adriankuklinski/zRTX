const std = @import("std");

pub const Utility = struct{
    pub fn createRng() std.Random.DefaultPrng {
        var seed: u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch {
            seed = @intCast(std.time.milliTimestamp());
        };
        return std.Random.DefaultPrng.init(seed);
    }
    
    pub fn randomDouble(rng: *std.Random.DefaultPrng) f64 {
        return rng.random().float(f64);
    }

    pub fn randomDoubleRange(rng: *std.Random.DefaultPrng, min: f64, max: f64) f64 {
        return min + (max-min) * randomDouble(rng);
    }
};
