const std = @import("std");

const test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
const real_input = "17330-35281,9967849351-9967954114,880610-895941,942-1466,117855-209809,9427633930-9427769294,1-14,311209-533855,53851-100089,104-215,33317911-33385573,42384572-42481566,43-81,87864705-87898981,258952-303177,451399530-451565394,6464564339-6464748782,1493-2439,9941196-10054232,2994-8275,6275169-6423883,20-41,384-896,2525238272-2525279908,8884-16221,968909030-969019005,686256-831649,942986-986697,1437387916-1437426347,8897636-9031809,16048379-16225280";

test "part1" {
  const result = try part1_text(test_input);
  try std.testing.expectEqual(1227775554, result);
}

pub fn part1() !i64 {
  return part1_text(real_input);
}

fn part1_text(input: []const u8) !i64 {

  var reader = std.Io.Reader.fixed(input);
  var invalid: i64 = 0;

  while (try reader.takeDelimiter(',')) |range_text| {
    const range = try Range.init_from_string(range_text);
    for (range.start..range.stop+1) |id| {
      if (try is_invalid_id(@intCast(id))) {
        invalid += @intCast(id);
      }
    }
  }

  return @intCast(invalid);
}

test "is_invalid_id" {
  try std.testing.expect(try is_invalid_id(11));
  try std.testing.expect(try is_invalid_id(22));
  try std.testing.expectEqual(false, try is_invalid_id(36));
}

fn is_invalid_id(id: u64) !bool {

  var buf : [12]u8 = undefined;
  const s = try std.fmt.bufPrint(&buf, "{}", .{id});

  if (s.len % 2 == 1) {
    return false;
  } else {
    const mid = s.len/2;
    return std.mem.eql(u8, s[0..mid], s[mid..]);
  }
}

const Range = struct {
  start: u64,
  stop: u64,

  pub fn init_from_string(s: []const u8) !Range {
    var reader = std.Io.Reader.fixed(s);
    var start: u64 = 0; var stop: u64 = 0;
    var i: u64 = 0;
    while (try reader.takeDelimiter('-')) |p| : (i += 1) {
      if (i == 0) { start = try std.fmt.parseInt(u64, p, 10); }
      else { stop = try std.fmt.parseInt(u64, p, 10); }
    }
    return .{
      .start = start,
      .stop = stop,
    };
  }
};

pub fn part2() !i64 {
  return part2_text(real_input);
}

fn part2_text(input: []const u8) !i64 {

  var reader = std.Io.Reader.fixed(input);
  var invalid: i64 = 0;

  while (try reader.takeDelimiter(',')) |range_text| {
    const range = try Range.init_from_string(range_text);
    for (range.start..range.stop+1) |id| {
      if (try is_invalid_id_2(@intCast(id))) {
        invalid += @intCast(id);
      }
    }
  }

  return @intCast(invalid);
}

test "is_invalid_id_2" {
  try std.testing.expect(try is_invalid_id_2(11));
  try std.testing.expect(!try is_invalid_id_2(110));
  try std.testing.expect(try is_invalid_id_2(111));
  try std.testing.expect(try is_invalid_id_2(22));
  try std.testing.expect(!try is_invalid_id_2(36));
  try std.testing.expect(try is_invalid_id_2(123123123));
  try std.testing.expect(try is_invalid_id_2(38593859));
}

fn is_invalid_id_2(id: u64) !bool {

  var buf : [12]u8 = undefined;
  const s = try std.fmt.bufPrint(&buf, "{}", .{id});

  pc: for (2..s.len+1) |part_count| {
    if (@mod(s.len, part_count) == 0) {

      const part_len = s.len / part_count;
      for (1..part_count) |part_index| {
        const part_start = part_len*part_index;
        const part_first = s[0..part_len];
        const part_other = s[part_start..part_start+part_len];
        const res = std.mem.eql(u8,part_first, part_other);
        // std.debug.print("id: {}, part_count: {}, part_len: {}, part_start: {}, part_first: {s}, part_other: {s}, res: {}\n",
        //   .{id, part_count, part_len, part_start, part_first, part_other, res});
        if (!res) {
          continue :pc;
        }
      }
      return true;
    }
  }

  return false;
}

test "part2" {
  const result = try part2_text(test_input);
  try std.testing.expectEqual(4174379265, result);
}
