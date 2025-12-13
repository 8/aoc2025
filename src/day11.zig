const std = @import("std");
const Allocator = std.mem.Allocator;
const Reader = std.Io.Reader;
const print = std.debug.print;

const test_input = 
  \\aaa: you hhh
  \\you: bbb ccc
  \\bbb: ddd eee
  \\ccc: ddd eee fff
  \\ddd: ggg
  \\eee: out
  \\fff: out
  \\ggg: out
  \\hhh: ccc fff iii
  \\iii: out
;

const InputOutputMap = struct {
  const Self = @This();

  const OutputList = std.ArrayList([]const u8);
  const Inner = std.StringArrayHashMap(OutputList);

  inner: Inner,

  pub fn init(a: Allocator, text: []const u8) !Self {

    var lookup: Inner = .init(a);
    errdefer lookup.deinit();

    var line_reader = Reader.fixed(text);

    while (try line_reader.takeDelimiter('\n')) |line| {

     if (line.len < 4) {
        return error.LineTooShort;
      } else if (line[3] != ':') {
        return error.NoColonFound;
      }
      const key = line[0..3];

      var reader = Reader.fixed(line[5..]);

      var output_list = OutputList.empty;
      errdefer output_list.deinit(a);

      while (try reader.takeDelimiter(' ')) |part| {
        if (part.len != 3) {
          return error.WrongOutputLength;
        }

        try output_list.append(a, part);
      }

      try lookup.put(key, output_list);
    }

    return .{
      .inner = lookup,
    };
  }

  pub fn deinit(self: *Self) void {
    for (self.inner.values()) |*outputs| {
      outputs.deinit(self.inner.allocator);
    }
    self.inner.deinit();
  }
};

test "InputOutpuMap" {
  var io: InputOutputMap = try .init(std.testing.allocator, test_input);
  defer io.deinit();
}

test "part1" {
  const result = try part1_text(std.testing.allocator, test_input);
  _ = result;
}

pub fn part1_text(allocator: Allocator, input: []const u8) !u64 {

  var io: InputOutputMap = try .init(allocator, input);
  defer io.deinit();

  var it = io.inner.iterator();
  while (it.next()) |i| {
    print("{s}: {}\n", .{i.key_ptr.*, i.value_ptr.*.items.len});
  }

  return 0;
}