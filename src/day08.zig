const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

const test_input = 
  \\162,817,812
  \\57,618,57
  \\906,360,560
  \\592,479,940
  \\352,342,300
  \\466,668,158
  \\542,29,236
  \\431,825,988
  \\739,650,466
  \\52,470,668
  \\216,146,977
  \\819,987,18
  \\117,168,530
  \\805,96,715
  \\346,949,466
  \\970,615,88
  \\941,993,340
  \\862,61,35
  \\984,92,344
  \\425,690,689
  ;

const real_input = @embedFile("08.txt");

pub fn part1(allocator: Allocator) !u64 {
  return part1_text(allocator, real_input, 1000);
}

test "part1" {
  try std.testing.expectEqual(40, try part1_text(std.testing.allocator, test_input, 10));
}

const Pos = struct {
  const Self = @This();
  x: i32,
  y: i32,
  z: i32,

  pub fn init_from_line(line: []const u8) !Self {
    var reader = std.Io.Reader.fixed(line);

    const x = try std.fmt.parseInt(i32, try reader.takeDelimiter(',') orelse "", 10);
    const y = try std.fmt.parseInt(i32, try reader.takeDelimiter(',') orelse "", 10);
    const z = try std.fmt.parseInt(i32, try reader.takeDelimiter(',') orelse "", 10);

    return .{
      .x = x,
      .y = y,
      .z = z,
    };
  }

  pub fn getDist(self: *const Self, other: *const Self) i64 {
    // return @as(u64, @intCast(std.math.pow(i64, self.x - other.x, 2)))
    //      + @as(u64, @intCast(std.math.pow(i64, self.y - other.y, 2)))
    //      + @as(u64, @intCast(std.math.pow(i64, self.z - other.z, 2)));

    return std.math.pow(i64, (self.x - other.x), 2)
         + std.math.pow(i64, (self.y - other.y), 2)
         + std.math.pow(i64, (self.z - other.z), 2);
  }
};


const Pair = struct {
  const Self = @This();
  p1: Pos,
  p2: Pos,
  dist: i64,

  pub fn sort(context: void, self: Self, other: Self) bool {
    _ = context;
    return self.dist < other.dist;
  }
};

const Circuit = std.AutoArrayHashMap(Pos, void);

fn sortCircuit(ctx: void, self: Circuit, other: Circuit) bool {
  _ = ctx;
  return self.count() > other.count();
}

pub fn part1_text(allocator: Allocator, input: []const u8, connect_count: u32) !u64 {

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();

  const a = arena.allocator();

  var pos_list = std.ArrayList(Pos).empty;
  defer pos_list.deinit(a);

  var reader = std.Io.Reader.fixed(input);
  while (try reader.takeDelimiter('\n')) |line| {
    const pos = try Pos.init_from_line(line);
    try pos_list.append(a, pos);
  }

  // const positions = pos_list.items;
  // print("{}\n", .{ positions.len });

  // create pairs
  var pair_list = std.ArrayList(Pair).empty;
  defer pair_list.deinit(a);

  var i: u64 = 0;

  var dist_lookup = std.AutoHashMap(i64, void).init(a);
  defer dist_lookup.deinit();

  for (pos_list.items) |pos| {

    var other_list = try pos_list.clone(a);
    defer other_list.deinit(a);

    while (other_list.pop()) |other| : (i+=1) {

      const dist = pos.getDist(&other);

      if (dist > 0 and !dist_lookup.contains(dist)) {
        try dist_lookup.put(dist, {});
        const pair: Pair = .{
          .p1 = pos,
          .p2 = other,
          .dist = dist,
        };

        try pair_list.append(a, pair);
      }
    }
  }

  // sort
  std.mem.sort(Pair, pair_list.items, {}, Pair.sort);

  // print("len: {}\n", .{pair_list.items.len});

  // for (0..connect_count) |p_i|{
  //   print("{}: {}\n", .{p_i, pair_list.items[p_i]});
  // }

  const closest_pairs = pair_list.items[0..connect_count];

  var circuit_list = std.ArrayList(Circuit).empty;
  defer circuit_list.deinit(a);
 
  for (closest_pairs) |pair| {

    var maybe_c1: ?*Circuit = null;
    var maybe_c2: ?*Circuit = null;

    for (circuit_list.items) |*circuit|{
      if (circuit.contains(pair.p1)) {
        maybe_c1 = circuit;
      }
      if (circuit.contains(pair.p2)) {
        maybe_c2 = circuit;
      }
    }

    // combine them
    if (maybe_c1 != null and maybe_c2 != null) {

      if (maybe_c1 != maybe_c2) {


      // print("combine them\n",.{});
      // print ("circuit_list.count: {}\n", .{circuit_list.items.len});
      // print ("maybe_c1.count: {}\n", .{maybe_c1.?.count()});

      const c2 = maybe_c2.?;
      var iterator = c2.iterator();
      while (iterator.next()) |pos|  {
        try maybe_c1.?.put(pos.key_ptr.*, {});
      }

      for (circuit_list.items, 0..) |*c, ii| {
        if (c == c2) {
          _ = circuit_list.orderedRemove(ii);
          break;
        }
      }

      // print ("maybe_c1.count: {}\n", .{maybe_c1.?.count()});
      // print ("circuit_list.count: {}\n", .{circuit_list.items.len});
      }

    } else if (maybe_c1) |c1| {
      // print("adding p2 {}\n", .{pair.p2});
      try c1.put(pair.p2, {});
    } else if (maybe_c2) |c2|{
      // print("adding p1 {}\n", .{pair.p1});
      try c2.put(pair.p1, {});
    } else {

      // create a new circuit
      var circuit : Circuit = .init(a);
      try circuit.put(pair.p1, {});
      try circuit.put(pair.p2, {});
      try circuit_list.append(a, circuit);

      // print("created new circuit\n", .{});
    }
  }

  // sort the circuits by length
  std.mem.sort(Circuit, circuit_list.items, {}, sortCircuit);

  // for (circuit_list.items) |circuit| {
    // print("circuit: {}\n", .{circuit.count()});
    // var iterator = circuit.iterator();
    // while (iterator.next()) |pos| {
    //   print("{}\n",.{pos});
    // }
    // print("\n", .{});
  // }

  // multiply the largest 3 circuits
  var total: u64 = 1;
  for (circuit_list.items[0..3]) |circuit| {
    // print("{}\n", .{circuit});
    total *= circuit.count();
  }

  return total;
}

