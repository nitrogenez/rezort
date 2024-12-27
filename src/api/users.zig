const std = @import("std");
const api = @import("../api.zig");
const rest = @import("rest.zig");
const query = @import("query.zig");
const user = @import("schema/user.zig");
const file = @import("schema/file.zig");
const err = @import("schema/err.zig");
const node = @import("schema/node.zig");

const Json = std.json.Parsed;

/// Returns info about user `target`. Requires session token.
/// Caller owns the memory.
pub fn fetchUser(
    client: *std.http.Client,
    allocator: std.mem.Allocator,
    target: []const u8,
    token: []const u8,
) !Json(user.User) {
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    const uri = try query.build(&buffer, &.{ api.endpoint_users, target });
    return rest.get(user.User, client, allocator, uri, .{}, &.{
        .{ .name = "X-Session-Token", .value = token },
    });
}

/// Returns info about Self (user associated with the session token).
/// Requires session token. Caller owns the memory.
pub fn fetchSelf(
    client: *std.http.Client,
    allocator: std.mem.Allocator,
    token: []const u8,
) !Json(user.User) {
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    const uri = try query.build(&buffer, &.{api.endpoint_users_self});
    return rest.get(user.User, client, allocator, uri, .{}, &.{
        .{ .name = "X-Session-Token", .value = token },
    });
}

/// Patches user `target` with data from `payload`, and returns modified user data.
/// Requires session token. Caller owns the memory.
pub fn editUser(
    client: *std.http.Client,
    allocator: std.mem.Allocator,
    target: []const u8,
    token: []const u8,
    payload: user.UserEdit,
) !Json(user.User) {
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    const uri = try query.build(&buffer, &.{ api.endpoint_users, target });
    return rest.patch(user.User, client, allocator, uri, .{
        .content_type = .{ .override = "application/json" },
    }, &.{.{ .name = "X-Session-Token", .value = token }}, payload);
}

/// Fetches flags for user `target`.
/// Frame owns the memory.
pub fn fetchUserFlags(
    client: *std.http.Client,
    allocator: std.mem.Allocator,
    target: []const u8,
) !i32 {
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    const uri = try query.build(&buffer, &.{ api.endpoint_users, target, "flags" });
    const res = try rest.get(struct {
        flags: i32,
    }, client, allocator, uri, .{}, &.{}, {});
    defer res.deinit();
    return res.value.flags;
}

/// Changes the username. Returns updated user info. Requires session token.
/// Caller owns the memory.
pub fn changeUserName(
    client: *std.http.Client,
    allocator: std.mem.Allocator,
    token: []const u8,
    payload: user.UserNameChange,
) !Json(user.User) {
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    const uri = try query.build(&buffer, &.{api.endpoint_users_self_username});
    return rest.patch(user.User, client, allocator, uri, .{
        .content_type = .{ .override = "application/json" },
    }, &.{.{ .name = "X-Session-Token", .value = token }}, payload);
}

/// Returns profile info of user `target`. Requires session token.
/// Caller owns the memory.
pub fn fetchUserProfile(
    client: *std.http.Client,
    allocator: std.mem.Allocator,
    target: []const u8,
    token: []const u8,
) !Json(user.Profile) {
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    const uri = try query.build(&buffer, &.{ api.endpoint_users, target, "profile" });
    return rest.get(user.Profile, client, allocator, uri, .{}, &.{
        .{ .name = "X-Session-Token", .value = token },
    });
}
