const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

const test_input = 
  \\7,1
  \\11,1
  \\11,7
  \\9,7
  \\9,5
  \\2,5
  \\2,3
  \\7,3
;

const real_input = @embedFile("09.txt");

const Pos = struct {
  const Self = @This();
  x: u32,
  y: u32,

  pub fn init_from_line(line: []const u8) !Self {
    var reader = std.Io.Reader.fixed(line);
    const x = try std.fmt.parseInt(u32, try reader.takeDelimiter(',') orelse return error.NotANumber, 10);
    const y = try std.fmt.parseInt(u32, try reader.takeDelimiter('\n') orelse return error.NotANumber, 10);
    return .{
      .x = x,
      .y = y,
    };
  }
};

test "part1_text" {
  try std.testing.expectEqual(50, try part1_text(std.testing.allocator, test_input));
}

pub fn part1(allocator: Allocator) !u64 {
  return part1_text(allocator, real_input);
}

pub fn part1_text(allocator: Allocator, input: []const u8) !u64 {
  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();
  const a = arena.allocator();

  // read in the input as a list
  var reader = std.Io.Reader.fixed(input);

  var pos_list = std.ArrayList(Pos).empty;
  defer pos_list.deinit(a);
  
  while (try reader.takeDelimiter('\n')) |line| {
    const pos = try Pos.init_from_line(line);
    try pos_list.append(a, pos);
  }

  const positions = pos_list.items;

  var area_max: u64 = 0;

  // combine them pair wise and calculate their area, biggest area wins
  for (positions, 0..) |pos1, i| {
    for (positions[i+1..]) |pos2|{
      const height = @abs(@as(i64, pos2.y)-@as(i64, pos1.y))+1;
      const width = @abs(@as(i64, pos2.x)-@as(i64, pos1.x))+1;
      const area = height*width;
      // print("pos1: {}, pos2: {}, height: {}, width: {}, area: {}\n", .{pos1, pos2, height, width, area});
      if (area > area_max) {
        area_max = @intCast(area);
      }
    }
  }

  return area_max;
}
