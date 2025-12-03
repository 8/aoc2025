const std = @import("std");
const expectEqual = std.testing.expectEqual;

const test_input =
  \\987654321111111
  \\811111111111119
  \\234234234234278
  \\818181911112111
;

const real_input = @embedFile("03.txt");

pub fn part1() !i64 {
  return part1_text(real_input);
}

test "part1_text" {
  try expectEqual(357, part1_text(test_input));
}

fn part1_text(input: []const u8) !i64 {
  var total: i64 = 0;

  var reader = std.Io.Reader.fixed(input);
  while (try reader.takeDelimiter('\n')) |line| {
    total += try get_max_joltage(line);
  }

  return total;
}

test "get_max_joltage" {
  try expectEqual(98, get_max_joltage("987654321111111"));
  try expectEqual(89, get_max_joltage("811111111111119"));
  try expectEqual(78, get_max_joltage("234234234234278"));
  try expectEqual(92, get_max_joltage("818181911112111"));
}

fn get_max_joltage(line: []const u8) !i64 {
  
  const c2d = std.fmt.charToDigit;
  
  // first find highest first digit, that is not the last
  var d1_max: u8 = 0;
  var d1_i: usize = 0;
  for (line[0..line.len-1], 0..) |c, i| {
    const d = try c2d(c, 10);
    if (d > d1_max) {
      d1_max = d;
      d1_i = i;
    }
  }

  var d2_max: u8 = 0;
  for (line[d1_i+1..]) |c| {
    const d = try c2d(c, 10);
    if (d > d2_max) {
      d2_max = d;
    }
  }

  var buf : [2]u8 = undefined;
  buf[0] = std.fmt.digitToChar(d1_max, .lower);
  buf[1] = std.fmt.digitToChar(d2_max, .lower);
  const res = try std.fmt.parseInt(i64, &buf, 10);
  return res;
}
