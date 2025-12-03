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

test "part2" {
  try expectEqual(3121910778619, try part2_text(test_input));
}

pub fn part2() !i64 {
  return part2_text(real_input);
}

fn part2_text(input: []const u8) !i64 {
  var total: i64 = 0;
  var reader = std.Io.Reader.fixed(input);
  while (try reader.takeDelimiter('\n'))|line| {
    total += try get_max_joltage_2(line);
  }
  return total;
}

test "get_max_joltage_2" {
  try expectEqual(987654321111, try get_max_joltage_2("987654321111111"));
  try expectEqual(811111111119, try get_max_joltage_2("811111111111119"));
  try expectEqual(434234234278, try get_max_joltage_2("234234234234278"));
  try expectEqual(888911112111, try get_max_joltage_2("818181911112111"));
}

fn get_max_joltage_2(line: []const u8) !i64 {
  
  const c2d = std.fmt.charToDigit;
  const d2c = std.fmt.digitToChar;

  const d_len = 12;
  var buf: [d_len]u8 = undefined;

  var d_max_i: usize = 0;
  for (0..d_len) |d_i| {

    var d_max: u8 = 0;
    
    for (d_max_i..line.len-(d_len-d_i)+1) |c_i| {
      const d = try c2d(line[c_i], 10);
      if (d > d_max) {
        d_max = d;
        d_max_i = c_i+1;
      }
    }

    buf[d_i] = d2c(d_max, .lower);
  }

  return try std.fmt.parseInt(i64, &buf, 10);
}