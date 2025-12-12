const std = @import("std");
const Allocator = std.mem.Allocator;
const Reader = std.Io.Reader;
const print = std.debug.print;

const test_input = 
  \\[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
  \\[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
  \\[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
;

const IndicatorLights = struct {
  const Self = @This();

  bit_set: std.bit_set.DynamicBitSet,

  pub fn init(a: Allocator, s: []const u8) !Self {
    if (s[0] != '[') {
      return error.NoOpeningBracketFound;
    }
    if (s[s.len-1] != ']') {
      return error.NoClosingBracketFound;
    }
    const length = s.len-2;
    var bit_set = try std.bit_set.DynamicBitSet.initEmpty(a, length);
    errdefer bit_set.deinit();

    for (s[1..s.len-1], 0..) |c, i| {
      switch (c) {
        '.' => {},
        '#' => bit_set.set(i),
        else => return error.InvalidCharacter,
      }
    }

    return .{
      .bit_set = bit_set,
    };
  }
  pub fn deinit(self: *Self) void {
    self.bit_set.deinit();
  }
};

test "IndicatorLights.init" {
  var indicator_lights = try IndicatorLights.init(std.testing.allocator, "[.##.]");
  defer indicator_lights.deinit();
  try std.testing.expectEqual(4, indicator_lights.bit_set.capacity());
  try std.testing.expectEqual(false, indicator_lights.bit_set.isSet(0));
  try std.testing.expectEqual(true, indicator_lights.bit_set.isSet(1));
  try std.testing.expectEqual(true, indicator_lights.bit_set.isSet(2));
  try std.testing.expectEqual(false, indicator_lights.bit_set.isSet(3));
  try std.testing.expectEqual(4, indicator_lights.bit_set.unmanaged.bit_length);
}

const Button = struct {
  const Self = @This();
  inner: std.AutoHashMap(u32, void),

  pub fn init(a: Allocator, s: []const u8) !Self {

    if (s[0] != '(') { return error.NoStartingBracketFound; }
    else if (s[s.len-1] != ')') { return error.NoClosingBracketFound; }

    var lookup = std.AutoHashMap(u32, void).init(a);
    errdefer lookup.deinit();

    const content = s[1..s.len-1];
    var reader = Reader.fixed(content);
    while (try reader.takeDelimiter(',')) |n_s| {
      const n = try std.fmt.parseInt(u32, n_s, 10);
      try lookup.put(n, {});
    }

    return .{
      .inner = lookup,
    };
  }
  pub fn deinit(self: *Self) void {
    self.inner.deinit();
  }
};

test "Button.init" {
   var button = try Button.init(std.testing.allocator,"(2,3)");
   defer button.deinit();
   try std.testing.expectEqual(false, button.inner.contains(0));
   try std.testing.expectEqual(false, button.inner.contains(1));
   try std.testing.expectEqual(true, button.inner.contains(2));
   try std.testing.expectEqual(true, button.inner.contains(3));
   try std.testing.expectEqual(false, button.inner.contains(4));
}

const Buttons = struct {
  const Self = @This();
  inner: std.ArrayList(Button),
  allocator: Allocator,

  pub fn init(a: Allocator, s: []const u8) !Self {

    var button_list = std.ArrayList(Button).empty;
    errdefer button_list.deinit(a);

    var reader = Reader.fixed(s);
    while (try reader.takeDelimiter(' ')) |part| {
      if (part[0] != '(') {
        return error.NoOpeningBracket;
      } else if (part[part.len-1] != ')') {
        return error.NoClosingBracket;
      }

      const button : Button = try .init(a, part);
      try button_list.append(a, button);
    }

    return .{
      .allocator = a,
      .inner = button_list,
    };
  }

  pub fn deinit(self: *Self) void {
    for (self.inner.items) |*button| {
      button.deinit();
    }
    self.inner.deinit(self.allocator);
  }
};

test "Buttons.init" {
  var buttons = try Buttons.init(std.testing.allocator, "(3) (1,3) (2) (2,3) (0,2) (0,1)");
  defer buttons.deinit();
  try std.testing.expectEqual(6, buttons.inner.items.len);
}

const JoltageRequirements = struct {
  const Self = @This();
  inner: std.ArrayList(u32),
  allocator: Allocator,

  pub fn init(a: Allocator, s: []const u8) !Self {
    var array_list = std.ArrayList(u32).empty;
    errdefer array_list.deinit(a);
    
    if (s[0] != '{') {
      return error.NoOpenCurlyBracketFound;
    } else if (s[s.len-1] != '}') {
      return error.NoClosingCurlyBracketFound;
    }

    var reader = Reader.fixed(s[1..s.len-1]);
    while (try reader.takeDelimiter(',')) |part| {
      const n = try std.fmt.parseInt(u32, part, 10);
      try array_list.append(a, n);
    }

    return .{
      .inner = array_list,
      .allocator = a,
    };
  }

  pub fn deinit(self: *Self) void {
    self.inner.deinit(self.allocator);
  }
};

test "JoltageRequirements.init" {
  var joltage_requirements : JoltageRequirements = try .init(std.testing.allocator, "{10,11,11,5,10,5}");
  try std.testing.expectEqual(6, joltage_requirements.inner.items.len);
  defer joltage_requirements.deinit();
}

const Machine = struct {
  const Self = @This();
  indicator_lights: IndicatorLights,
  buttons: Buttons,
  joltage_requirements: JoltageRequirements,

  pub fn init(a: Allocator, s: []const u8) !Self {
    var reader = Reader.fixed(s);

    const indicator_lights: IndicatorLights = try .init(a, try reader.takeDelimiter(' ') orelse return error.NoSpaceSeparatorFound);
    const buttons: Buttons = try .init(a, try reader.takeDelimiterExclusive('{'));
    const joltage_requirements: JoltageRequirements = try .init(a, s[reader.seek..]);

    return .{
      .indicator_lights = indicator_lights,
      .buttons = buttons,
      .joltage_requirements = joltage_requirements,
    };
  }

  pub fn deinit(self: *Self) void {
    self.buttons.deinit();
    self.indicator_lights.deinit();
    self.joltage_requirements.deinit();
  }
};

test "Machine.init" {
  var machine = try Machine.init(std.testing.allocator, "[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}");
  defer machine.deinit();

  try std.testing.expectEqual(5, machine.indicator_lights.bit_set.unmanaged.bit_length);
  try std.testing.expectEqual(5, machine.buttons.inner.items.len);
  try std.testing.expectEqual(5, machine.joltage_requirements.inner.items.len);
}

// test "part1" {
//   try std.testing.expectEqual(7, try part1_text(std.testing.allocator, test_input));
// }

pub fn part1_text(allocator: Allocator, input: []const u8) !u64 {

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();
  const a = arena.allocator();

  var reader = Reader.fixed(input);
  while (try reader.takeDelimiter('\n')) |line| {
    const machine: Machine = try .init(a, line);
    print("{}\n", .{machine});
  }

  return 0;
}
