const std = @import("std");
const print = std.log.info;
const day1 = @import("day01.zig");
const day2 = @import("day02.zig");
const day3 = @import("day03.zig");
const day4 = @import("day04.zig");
const day5 = @import("day05.zig");
const day6 = @import("day06.zig");
const day7 = @import("day07.zig");
const day8 = @import("day08.zig");

pub fn main() !void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();

  // print("day1 part1: {}", .{try day1.part1()});
  // print("day1 part2: {}", .{try day1.part2()});

  // print("day2 part1: {}", .{try day2.part1()});
  // print("day2 part2: {}", .{try day2.part2()});

  // print("day3 part1: {}", .{try day3.part1()});
  // print("day3 part2: {}", .{try day3.part2()});

  // print("day4 part1: {}", .{try day4.part1(gpa.allocator())});
  // print("day4 part2: {}", .{try day4.part2(gpa.allocator())});

  // print("day5 part1: {}", .{try day5.part1(gpa.allocator())});
  // print("day5 part2: {}", .{try day5.part2(gpa.allocator())});

  // print("day6 part1: {}", .{try day6.part1(gpa.allocator())});
  // print("day6 part2: {}", .{try day6.part2(gpa.allocator())});

  // print("day7 part1: {}", .{try day7.part1(gpa.allocator())});
  // print("day7 part2: {}", .{try day7.part2(gpa.allocator())});

  print("day8 part1: {}", .{try day8.part1(gpa.allocator())});
}
