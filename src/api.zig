// Copyright (c) 2024 Andrij Glyko <nitrogenez.dev@tuta.io>

//! Well cum to the api zone.
//! Here be low-abstraction API wrapper functions and API endpoint
//! definitions. Some functions require session token, others don't.
//! To see which need it and which don't, check the Revolt API reference:
//!     https://developers.revolt.chat/developers/api/reference.html

const std = @import("std");
const rest = @import("rest.zig");
const query = @import("query.zig");
const err = @import("schema/err.zig");
const node = @import("schema/node.zig");

const Json = std.json.Parsed;

// Endpoints
pub const node_primary = "api.revolt.chat";
pub const events_primary = "ws.revolt.chat";
pub const endpoint_staging = "revolt.chat/api";
pub const events_staging = "revolt.chat/events";

// Endpoints for users
pub const endpoint_users = "/users";
pub const endpoint_users_self = endpoint_users ++ "/@me";
pub const endpoint_users_self_username = endpoint_users_self ++ "/username";

// Get the root options.
const root = @import("root");
const opts: @import("root.zig").Options = if (@hasDecl(root, "rezort_opts"))
    root.rezort_opts
else
    .{};

/// Main API endpoint.
/// Depends on the .rz_staging option in your project's root module.
pub const node_uri = blk: {
    if (opts.rz_api_endpoint) |ep| {
        break :blk ep;
    }
    break :blk switch (opts.rz_api_staging) {
        true => endpoint_staging,
        else => node_primary,
    };
};

/// Event API endpoint.
/// Depends on the .rz_staging option in your project's root module.
pub const events_uri = blk: {
    if (opts.rz_endpoint_events) |ep| {
        break :blk ep;
    }
    break :blk switch (opts.rz_staging) {
        true => events_staging,
        else => events_primary,
    };
};

/// Returns Revolt node info.
/// Caller owns the memory.
pub fn getNodeInfo(client: *std.http.Client, allocator: std.mem.Allocator) !Json(node_uri.Node) {
    var buffer: []u8 = undefined;
    return rest.get(node.Node, client, allocator, try query.build(
        &buffer,
        &.{},
    ), .{}, &.{});
}

/// Returns a parsed semver of the main node.
/// Frame owns the memory.
pub fn getNodeVersion(client: *std.http.Client) !std.SemanticVersion {
    var buffer: [0x6000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const info = try getNodeInfo(client, fba.allocator());
    defer info.deinit();
    return std.SemanticVersion.parse(info.value.revolt);
}
