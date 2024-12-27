// Copyright (c) 2024-2025 Andrij Glyko <nitrogenez.dev@tuta.io>

//! Here be dragons!
//! This is almost the staple of rezort. The raw REST API functions!
//! The function signatures here are long as fuck. Make sure to use LSP.
//! In a nutshell: the main function here is `request`. It builds a request.
//! Uh-huh. And then sends it, writing data if necessary.

// TODO: Make `request` less ambiguous. Maybe do little generics instead
// of `anytype`?

// FIXME: i wonder if std.json.stringify can recognise `void`...

// FIXME: i guess i'll need to make some kind of a diagnostics tool
// to report the actual errors returned by revolt. like, knowing the
// location of the error might be useful, you know.

const std = @import("std");
const err = @import("schema/err.zig");

pub const Error = error{
    RateLimited,
    AccessDenied,
    BadRequest,
    InvalidQuery,
};

/// Builds a request, and sends it via `client`. If `@TypeOf(payload)` is not
/// `void`, tries to serialize `payload` as JSON and writes it.
/// Session token and `query` are your responsibility. idgaf.
pub fn request(
    client: *std.http.Client,
    method: std.http.Method,
    query: std.Uri,
    headers: std.http.Client.Request.Headers,
    extra_headers: []const std.http.Header,
    payload: anytype,
) !std.http.Client.Request {
    std.log.debug("QUERY:{} {s}", .{ @tagName(method), query });

    var header_buffer: [0x4000]u8 = undefined;
    var req = try client.open(method, query, .{
        .server_header_buffer = &header_buffer,
        .headers = headers,
        .extra_headers = extra_headers,
    });
    errdefer req.deinit();

    if (@TypeOf(payload) != void) {
        const payload_json = try std.json.stringifyAlloc(client.allocator, payload, .{
            .emit_null_optional_fields = false,
        });
        defer client.allocator.free(payload_json);
        req.transfer_encoding = .{ .content_length = payload_json.len };

        try req.send();
        try req.writeAll(payload_json);
        try req.finish();
        try req.wait();
    } else {
        try req.send();
        try req.wait();
    }
    return req;
}

fn checkError(req: *std.http.Client.Request) (err.Error || Error)!void {
    return switch (req.response.status) {
        .ok => {},
        .too_many_requests => Error.RateLimited,
        .unauthorized => Error.AccessDenied,
        .bad_request => Error.BadRequest,
        .not_found => Error.InvalidQuery,
        else => parseError(req),
    };
}

/// Parses the response, parsing the returned error if necessary.
pub fn parseResponse(
    comptime Schema: type,
    req: *std.http.Client.Request,
    allocator: std.mem.Allocator,
) !std.json.Parsed(Schema) {
    try checkError(req);

    if (Schema == void) {
        return std.json.Parsed(void){};
    }
    const data = try request.reader().readAllAlloc(allocator, 0x100000);
    defer allocator.free(data);

    return std.json.parseFromSlice(Schema, allocator, data, .{
        .allocate = .alloc_always,
    });
}

fn parseError(
    req: *std.http.Client.Request,
) (std.json.ParseError(err.Response) || std.http.Client.Request.ReadError || err.Error) {
    var alloc_buffer: [0x4000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&alloc_buffer);
    var read_buffer: [0x2000]u8 = undefined;
    const bytes = try req.read(&read_buffer);
    const read = read_buffer[0..bytes];

    var data = try std.json.parseFromSlice(err.Response, fba.allocator(), read, .{});
    defer data.deinit();

    return err.map.get(data.value.type) orelse error.UnknownError;
}

/// Sends a GET request to the server. No payload.
/// The session token is your responsibility once again :)
pub fn get(
    comptime ResponseSchema: type,
    client: *std.http.Client,
    allocator: std.mem.Allocator,
    query: std.Uri,
    headers: std.http.Client.Request.Headers,
    extra_headers: []const std.http.Header,
) !std.json.Parsed(ResponseSchema) {
    var req = try request(client, .GET, query, headers, extra_headers, {});
    defer req.deinit();
    const resp = try parseResponse(ResponseSchema, &req, allocator);
    return resp;
}

/// Sends a POST request to the server, writing payload if it's not `void`.
/// How'd you guess? The session token is none of my business.
pub fn post(
    comptime ResponseSchema: type,
    client: *std.http.Client,
    allocator: std.mem.Allocator,
    query: std.Uri,
    headers: std.http.Client.Request.Headers,
    extra_headers: []const std.http.Header,
    payload: anytype,
) !std.json.Parsed(ResponseSchema) {
    var req = try request(client, .POST, query, headers, extra_headers, payload);
    defer req.deinit();
    return parseResponse(ResponseSchema, &req, allocator);
}

/// Sends a PATCH request to the server, writing payload if it's not `void`.
/// Session token is your business, again.
pub fn patch(
    comptime ResponseSchema: type,
    client: *std.http.Client,
    allocator: std.mem.Allocator,
    query: std.Uri,
    headers: std.http.Client.Request.Headers,
    extra_headers: []const std.http.Header,
    payload: anytype,
) !std.json.Parsed(ResponseSchema) {
    var req = try request(client, .PATCH, query, headers, extra_headers, payload);
    defer req.deinit();
    return parseResponse(ResponseSchema, &req, allocator);
}

/// Sends a DELETE request to the server, writing payload if it's not `void`.
/// Session token is on you, bro.
pub fn delete(
    comptime ResponseSchema: type,
    client: *std.http.Client,
    allocator: std.mem.Allocator,
    query: std.Uri,
    headers: std.http.Client.Request.Headers,
    extra_headers: []const std.http.Header,
    payload: anytype,
) !std.json.Parsed(ResponseSchema) {
    var req = try request(client, .DELETE, query, headers, extra_headers, payload);
    defer req.deinit();
    return parseResponse(ResponseSchema, &req, allocator);
}
