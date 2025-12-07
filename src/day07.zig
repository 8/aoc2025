const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

const test_input = 
  \\.......S.......
  \\...............
  \\.......^.......
  \\...............
  \\......^.^......
  \\...............
  \\.....^.^.^.....
  \\...............
  \\....^.^...^....
  \\...............
  \\...^.^...^.^...
  \\...............
  \\..^...^.....^..
  \\...............
  \\.^.^.^.^.^...^.
  \\...............
;

const real_input = @embedFile("07.txt");

pub fn part1(allocator: Allocator) !u64 {
  return part1_text(allocator, real_input);
}

test "part1" {
  try std.testing.expectEqual(21, try part1_text(std.testing.allocator, test_input));
}

pub fn part1_text(allocator: Allocator, input: []const u8) !u64 {

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();
  var a = arena.allocator();

  var lines_list = std.ArrayList([]u8).empty;

  var reader = std.Io.Reader.fixed(input);
  while (try reader.takeDelimiter('\n')) |line| {
    try lines_list.append(a, try a.dupe(u8, line));
  }

  const lines = lines_list.items;

  var split_count: u32 = 0;

  for (lines, 0..) |line, y| {
    if (y+1 < lines.len) {
      for (line, 0..) |c, x| {
        if (c == '|' or c == 'S') {
          if (lines[y+1][x] == '^') {
            split_count += 1;
            if (x > 0) {
              lines[y+1][x-1]='|';
            }
            if (x+1 < lines[y+1].len) {
              lines[y+1][x+1]='|';
            }
          } else {
            lines[y+1][x]='|';
          }
        }
      }
    }
  }

  return split_count;
}