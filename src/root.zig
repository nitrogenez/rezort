const std = @import("std");

pub const Options = struct {
    rz_api_staging: bool = false,
    rz_api_endpoint: ?[]const u8 = null,
    rz_api_endpoint_events: ?[]const u8 = null,
};

pub const api = @import("api.zig");
pub const rest = @import("rest.zig");

pub const schema = struct {
    pub const node = @import("schema/node.zig");
    pub const err = @import("schema/err.zig");
    pub const file = @import("schema/file.zig");
    pub const user = @import("schema/user.zig");
};
