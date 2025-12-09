const std = @import("std");
const allocator = std.heap.wasm_allocator;
const day1 = @import("day01.zig");
const day2 = @import("day02.zig");
const day3 = @import("day03.zig");
const day4 = @import("day04.zig");
const day5 = @import("day05.zig");
const day6 = @import("day06.zig");
const day7 = @import("day07.zig");
const day8 = @import("day08.zig");
const day9 = @import("day09.zig");

extern fn printNumber(n: i64) void;
extern fn printString(s: [*]const u8, len: usize) void;

fn printSlice(s: []const u8) void {
  printString(@ptrCast(s), s.len);
}

fn prepareText(input:[*]u8, len: usize) []const u8 {
  const input_text: []const u8 = @ptrCast(input[0..len]);
  return allocator.dupe(u8, input_text) catch "";
}

export fn day1_part1_text(input: [*]u8, len: usize) i64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day1.part1_text(text) catch -1;
}
export fn day1_part2_text(input: [*]u8, len: usize) i64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day1.part2_text(text) catch -1;
}
export fn day2_part1_text(input: [*]u8, len: usize) i64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day2.part1_text(text) catch -1;
}
export fn day2_part2_text(input: [*]u8, len: usize) i64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day2.part2_text(text) catch -1;
}
export fn day3_part1_text(input: [*]u8, len: usize) i64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day3.part1_text(text) catch -1;
}
export fn day3_part2_text(input: [*]u8, len: usize) i64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day3.part2_text(text) catch -1;
}
export fn day4_part1_text(input: [*]u8, len: usize) i64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day4.part1_text(text, allocator) catch -1;
}
export fn day4_part2_text(input: [*]u8, len: usize) i64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day4.part2_text(text, allocator) catch -1;
}
export fn day5_part1_text(input: [*]u8, len: usize) u64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day5.part1_text(text, allocator) catch 0;
}
export fn day5_part2_text(input: [*]u8, len: usize) u64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day5.part2_text(text, allocator) catch 0;
}
export fn day6_part1_text(input: [*]u8, len: usize) u64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day6.part1_text(text, allocator) catch 0;
}
export fn day6_part2_text(input: [*]u8, len: usize) u64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day6.part2_text(text, allocator) catch 0;
}
export fn day7_part1_text(input: [*]u8, len: usize) u64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day7.part1_text(allocator, text) catch 0;
}
export fn day7_part2_text(input: [*]u8, len: usize) u64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day7.part2_text(allocator, text) catch 0;
}
export fn day8_part1_text(input: [*]u8, len: usize) u64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day8.part1_text(allocator, text, 1000) catch 0;
}
export fn day8_part2_text(input: [*]u8, len: usize) u64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day8.part2_text(allocator, text) catch 0;
}
export fn day9_part1_text(input: [*]u8, len: usize) u64 {
  const text = prepareText(input, len);
  defer allocator.free(text);
  return day9.part1_text(allocator, text) catch 0;
}