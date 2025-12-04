const std = @import("std");
const expectEql = std.testing.expectEqual;
const Allocator = std.mem.Allocator;

const test_input =
  \\..@@.@@@@.
  \\@@@.@.@.@@
  \\@@@@@.@.@@
  \\@.@@@@..@.
  \\@@.@@@@.@@
  \\.@@@@@@@.@
  \\.@.@.@.@@@
  \\@.@@@.@@@@
  \\.@@@@@@@@.
  \\@.@.@@@.@.
;

const real_input = @embedFile("04.txt");

pub fn part1(allocator: Allocator) !i64 {
  return part1_text(real_input, allocator);
}

test "part1" {
  try expectEql(13, try part1_text(test_input, std.testing.allocator));
}

fn getLines(arena: Allocator, input: []const u8) !std.ArrayList([]u8) {
  var lines_list: std.ArrayList([]u8) = .empty;
  var reader = std.Io.Reader.fixed(input);
  while (try reader.takeDelimiter('\n')) |line| {
    try lines_list.append(arena, try arena.dupe(u8, line));
  }
  return lines_list;
}

fn part1_text(input: []const u8, allocator: Allocator) !i64 {
  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();

  var total: i64 = 0;
  const lines_list = try getLines(arena.allocator(), input);
  const lines = lines_list.items;

  for (0..lines.len) |y| {
    for (0..lines[0].len) |x| {
      if (lines[y][x] == '@') {
        const adj_count = getCount(lines, @intCast(x), @intCast(y));
        if (adj_count-1 < 4) {
          total += 1;
        }
      }
    }
  }

  return total;
}

test "getCount()" {
  var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
  defer arena.deinit();
  const lines = try getLines(arena.allocator(), test_input);
  try expectEql(2, getCount(lines.items, 0, 0));
  try expectEql(5, getCount(lines.items, 7, 0));
  try expectEql(7, getCount(lines.items, 1, 1));
}

fn getCount(lines: [][] u8, x: usize, y: usize) u8 {
  var count: u8 = 0;
  const y1 = if (y>0) y-1 else y;
  const y2 = if (y+1<lines.len) y+1 else y;
  const x1 = if (x>0) x-1 else x;
  const x2 = if (x+1<lines[0].len) x+1 else x;
  for (y1..y2+1) |yi| {
    for (x1..x2+1) |xi| {
      if (lines[yi][xi] == '@') {
        count+=1;
      }
    }
  }
  return count;
}

pub fn part2(allocator: Allocator) !i64 {
  return part2_test(real_input, allocator);
}

test "part2" {
  const result = try part2_test(test_input, std.testing.allocator);
  try expectEql(43, result);
}

fn part2_test(input: []const u8, allocator: Allocator) !i64 {

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();
  const line_list = try getLines(arena.allocator(), input);
  const lines = line_list.items;

  var removed_count: i64 = 0;
  var do = true;
  while (do) {
    do = false;
    for (0..lines.len) |y| {
      for (0..lines[0].len) |x| {
        if (lines[y][x] == '@') {
          const adj_count = getCount(lines, @intCast(x), @intCast(y));
          if (adj_count-1 < 4) {
            removed_count += 1;
            lines[y][x] = '.';
            do = true;
          }
        }
      }
    }
  }

  return removed_count;
}