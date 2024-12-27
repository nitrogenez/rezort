const std = @import("std");
const rz = @import("root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var client = std.http.Client{ .allocator = gpa.allocator() };
    defer client.deinit();
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    const query = try rz.api.uriQuery(&buffer, &.{rz.api.endpoint_users_self});

    std.debug.print("query: {}\n", .{query});
}
