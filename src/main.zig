const std = @import("std");
const print = std.log.info;
const day1 = @import("day01.zig");
const day2 = @import("day02.zig");
const day3 = @import("day03.zig");

pub fn main() !void {
  print("day1 part1: {}", .{try day1.part1()});
  print("day1 part2: {}", .{try day1.part2()});

  print("day2 part1: {}", .{try day2.part1()});
  print("day2 part2: {}", .{try day2.part2()});

  print("day3 part1: {}", .{try day3.part1()});
  print("day3 part2: {}", .{try day3.part2()});
}
