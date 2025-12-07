const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Reader = std.io.Reader;
const expectEqual = std.testing.expectEqual;

const test_input =
  \\123 328  51 64 
  \\ 45 64  387 23 
  \\  6 98  215 314
  \\*   +   *   +  
  ;

const real_input = @embedFile("06.txt");

test "part1" {
  try expectEqual(4277556, try part1_text(test_input, std.testing.allocator));
}

pub fn part1(allocator: Allocator) !u64 {
  return part1_text(real_input, allocator);
}

const Op = enum {
  add, mul,
  pub fn init_string(c: u8) !Op {
    return switch (c) {
      '+' => Op.add,
      '*' => Op.mul,
      else => error.InvalidChar,
    };
  }
};

pub fn part1_text(input: []const u8, allocator: Allocator) !u64 {

  var word_list = std.ArrayList([] const u8).empty;
  defer word_list.deinit(allocator);

  var col_count: u32 = 0;
  var line_reader = std.Io.Reader.fixed(input);
  while (try line_reader.takeDelimiter('\n')) |line| {
    var word_reader = std.Io.Reader.fixed(line);
    var word_count: u32 = 0;
    while (try word_reader.takeDelimiter(' ')) |word| {
      if (word.len > 0) {
        try word_list.append(allocator, word);
        word_count += 1;
      }
    }
    if (col_count == 0) {
      col_count = word_count;
    }
  }

  const words = word_list.items;
  const row_count = words.len / col_count;

  var result: u64 = 0;
  for (0..col_count) |col_i| {

    const op = try Op.init_string(words[col_i + col_count*(row_count-1)][0]);

    var item_result: u64 = switch (op) { .add => 0, .mul => 1};
    if (op == .add) {
      for (0..row_count-1) |row_i| {
        item_result += try std.fmt.parseInt(u64, words[col_i + col_count*row_i], 10);
      }
    } else {
      for (0..row_count-1) |row_i| {
        item_result *= try std.fmt.parseInt(u64, words[col_i + col_count*row_i], 10);
      }
    }

    result += item_result;
  }

  return result;
}

pub fn part2(allocator: Allocator) !u64 {
  return part2_text(real_input, allocator);
}

test "part2" {
  try expectEqual(3263827, try part2_text(test_input, std.testing.allocator));
}

pub fn part2_text(text: []const u8, allocator: Allocator) !u64 {

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();
  const a = arena.allocator();

  var line_list = ArrayList([]const u8).empty;
  defer line_list.deinit(a);

  var line_reader = Reader.fixed(text);
  while (try line_reader.takeDelimiter('\n')) |line| {
    try line_list.append(a, line);
  }

  const lines = line_list.items;

  var result: u64 = 0;

  // process them via the operator line
  const op_line = lines[lines.len-1];

  const OpPos = struct {
    op: Op,
    x: u32,
  };

  var op_list: ArrayList(OpPos) = .empty;

  for (op_line, 0..) |c, i| {
    if (Op.init_string(c) catch null) |op| {
      try op_list.append(a, .{.op = op, .x = @intCast(i)});
    }
  }

  for (op_list.items, 0..) |op, op_i| {
    const op_next : ?OpPos = if (op_list.items.len > op_i+1) op_list.items[op_i+1] else null;
    const col_start = op.x;
    const col_end = if (op_next) |o| o.x-1 else lines[0].len;

    var op_result: u64 = if (op.op == Op.add) 0 else 1;

    for (col_start..col_end) |col|{
      var buf: [10]u8 = undefined;
      const l = lines.len-1;
      var buf_i: usize = 0;
      for (0..l) |y| {
        const c = lines[y][col];
        if (c != ' ') {
          buf[buf_i] = c;
          buf_i += 1;
        }
      }
      const n_s = buf[0..buf_i];
      const n = try std.fmt.parseInt(u32, n_s, 10);

      if (op.op == Op.add) {
        op_result += n;
      } else {
        op_result *= n;
      }
    }
    result += op_result;
  }

  return result;
}

