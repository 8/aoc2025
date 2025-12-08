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

pub fn part2(allocator: Allocator) !u64 {
  return part2_text(allocator, real_input);
}

test "part2" {
  const result = try part2_text(std.testing.allocator, test_input);
  try std.testing.expectEqual(40, result);
}

// .......S....... 
// .......1....... 1
// ......1^1...... 2
// ......1.1...... 2
// .....1^2^1..... 4
// .....1.2.1..... 4
// ....1^3^3^1.... 8
// ....1.3.3.1.... 8
// ...1^4^331^1... 13
// ...1.4.331.1... 13
// ..1^5^434^2^1.. 20
// ..1.5.434.2.1.. 20
// .1^154^74.21^1. 26
// .1.154.74.21.1. 26
// 1^2^A^B^B^211^1 40
// 1.2.A.B.B.211.1 40

pub fn part2_text(allocator: Allocator, input: []const u8) !u64 {

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();
  var a = arena.allocator();

  var lines_list = std.ArrayList([]u8).empty;

  var reader = std.Io.Reader.fixed(input);
  while (try reader.takeDelimiter('\n')) |line| {
    try lines_list.append(a, try a.dupe(u8, line));
  }

  const lines = lines_list.items;

  const Pos = struct {
    const Self = @This();
    x: usize,
    y: usize,
    pub fn init(x: usize, y: usize) Self {
      return .{ .x = x, .y = y };
    }
  };

  var timelines_lookup = std.AutoHashMap(Pos, usize).init(allocator);
  defer timelines_lookup.deinit();

  for (lines, 0..) |line, y| {
    for (line, 0..) |c, x| {

      if (c == 'S') {
        const pos: Pos = .init(x, y);
        try timelines_lookup.put(
          pos,
          1);
      }

      if (y > 0) {
        const parent: Pos = .init(x,y-1);
        const parent_count = timelines_lookup.get(parent) orelse 0;

        if (c == '^') {
          if (x > 0) {
            const p: Pos = .init(x-1, y);
            const prev_count = timelines_lookup.get(p) orelse 0;
            const new_count = parent_count + prev_count;
            try timelines_lookup.put(p, new_count);
          }
          if (x+1 < lines[y].len) {
            const p: Pos = .init(x+1, y);
            const prev_count = timelines_lookup.get(p) orelse 0;
            const new_count = parent_count + prev_count;
            try timelines_lookup.put(p, new_count);
          }
        }
        else if (c == '.') {
          const p: Pos = .init(x, y);
          const prev_count = timelines_lookup.get(p) orelse 0;
          const new_count = parent_count + prev_count;
          try timelines_lookup.put(p, new_count);
        }
      }
    }
  }

  // for (0..lines.len) |row| {
  //   var row_total: usize = 0;
  //   for (0..lines[0].len) |col| {
  //     const c = timelines_lookup.get(.init(col, row)) orelse 0;
  //     print("{}",.{c});
  //     row_total += c;
  //   }
  //   print(" {}", .{row_total});
  //   print("\n", .{});
  // }

  var total: u64 = 0;
  for (0..lines[0].len) |x| {
    total += timelines_lookup.get(.init(x, lines.len-1)) orelse 0;
  }
  
  return total;
}