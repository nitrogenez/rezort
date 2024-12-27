const std = @import("std");

pub const Node = struct {
    revolt: []const u8,
    features: Features,
    ws: []const u8,
    app: []const u8,
    vapid: []const u8,
    build: Build,
};

pub const Features = struct {
    captcha: struct { enabled: bool, key: []const u8 },
    email: bool,
    invite_only: bool,
    autumn: struct { enabled: bool, url: []const u8 },
    january: struct { enabled: bool, url: []const u8 },
    voso: struct { enabled: bool, url: []const u8, ws: []const u8 },
};

pub const Build = struct {
    commit_sha: []const u8,
    commit_timestamp: []const u8,
    semver: []const u8,
    origin_url: []const u8,
    timestamp: []const u8,
};
