const std = @import("std");
const day1 = @import("day01.zig");
const day2 = @import("day02.zig");
const day3 = @import("day03.zig");

export fn day1_part1() i64 {
  return day1.part1() catch -1;
}
export fn day1_part2() i64 {
  return day1.part2() catch -1;
}
export fn day2_part1() i64 {
  return day2.part1() catch -1;
}
export fn day2_part2() i64 {
  return day2.part2() catch -1;
}
export fn day3_part1() i64 {
  return day3.part1() catch -1;
}
