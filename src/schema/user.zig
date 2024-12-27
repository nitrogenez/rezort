const std = @import("std");
const file = @import("file.zig");

pub const Relations = []const struct {
    _id: []const u8,
    status: []const u8,
};

pub const Status = struct {
    text: ?[]const u8 = null,
    presence: []const u8 = "Online",
};

pub const Profile = struct {
    content: ?[]const u8 = null,
    background: ?[]const u8 = null,
};

pub const User = struct {
    _id: []const u8,
    username: []const u8,
    discriminator: []const u8,
    display_name: ?[]const u8 = null,
    avatar: ?file.File = null,
    relations: ?Relations = null,
    badges: ?u32 = null,
    status: ?Status = null,
    flags: ?u32 = null,
    privileged: ?bool = null,
    bot: ?struct { owner: []const u8 } = null,
    relationship: []const u8,
    online: bool,
};

pub const UserEdit = struct {
    display_name: ?[]const u8 = null,
    avatar: ?[]const u8 = null,
    status: ?Status = null,
    profile: ?Profile = null,
    badges: ?i32 = null,
    flags: ?i32 = null,
    remove: ?[]const []const u8 = null,
};

pub const UserNameChange = struct {
    username: []const u8,
    password: []const u8,
};
