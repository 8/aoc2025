const std = @import("std");
const Allocator = std.mem.Allocator;
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

  var col_count: u64 = 0;
  var line_reader = std.Io.Reader.fixed(input);
  while (try line_reader.takeDelimiter('\n')) |line| {
    var word_reader = std.Io.Reader.fixed(line);
    var word_count: u64 = 0;
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

