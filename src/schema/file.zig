const std = @import("std");

pub const File = struct {
    _id: []const u8,
    tag: []const u8,
    filename: []const u8,
    metadata: struct {
        type: []const u8,
        width: ?u32 = null,
        height: ?u32 = null,
    },
    content_type: []const u8,
    size: i32,
    deleted: ?bool = null,
    reported: ?bool = null,
    message_id: ?[]const u8 = null,
    user_id: ?[]const u8 = null,
    server_id: ?[]const u8 = null,
    object_id: ?[]const u8 = null,
};
