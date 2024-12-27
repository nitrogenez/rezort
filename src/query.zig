const std = @import("std");
const api = @import("api");

/// Builds an `std.Uri` query to `paths`.
pub fn build(buffer: []u8, paths: []const []const u8) !std.Uri {
    var fba = std.heap.FixedBufferAllocator.init(buffer);
    return std.Uri{
        .scheme = "https",
        .host = .{ .raw = api.node },
        .path = .{ .raw = try std.fs.path.join(fba.allocator(), paths) },
    };
}

/// https://{node}/users/{target}
pub inline fn users(buffer: []u8, target: []const u8) !std.Uri {
    return build(buffer, &.{ api.endpoint_users, target });
}

/// https://{node}/users/@me
pub inline fn self(buffer: []u8) !std.Uri {
    return build(buffer, &.{api.endpoint_users_self});
}

fn expectQuery(expected: []const u8, paths: []const []const u8) !void {
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    var ser_buffer: [std.fs.max_path_bytes]u8 = undefined;
    const query = try build(&buffer, paths);
    const actual = try std.fmt.bufPrint(&ser_buffer, "{}", .{query});
    try std.testing.expectEqualStrings("https://api.revolt.chat" ++ expected, actual);
}

test "query builds" {
    try expectQuery("/random/shit", &.{ "random", "shit" });
    try expectQuery("/users/@me", &.{api.endpoint_users_self});
    try expectQuery("/users/1234", &.{ api.endpoint_users, "1234" });
    try expectQuery("/users/@me/username", &.{api.endpoint_users_self_username});
}
