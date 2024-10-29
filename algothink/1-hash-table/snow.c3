/*
PROBLEM
URL: (https://dmoj.ca/problem/cco07p2)
==> DESCRIPTION
You may have heard that no two snowflakes are alike. Your task is to write a program to determine whether this is really true.
Your program will read information about a collection of snowflakes, and search for a pair that may be identical.

Each snowflake has six arms. For each snowflake, your program will be provided with a measurement of the length of each of
the six arms. Any pair of snowflakes which have the same lengths of corresponding arms should be flagged by your program as possibly identical.

NOTE: The original CCO data were weak and have been augmented with some custom test cases.
==> INPUT SPECIFICATION
    The first line of input will contain a single integer n , 0 < n ≤ 100 000 , the number of snowflakes to follow.
    This will be followed by n lines, each describing a snowflake. Each snowflake will be described by a line
    containing six integers (each integer is at least 0 and less than 10 000 000 ), the lengths of the arms of the
    snowflake. The lengths of the arms will be given in order around the snowflake (either clockwise or counterclockwise),
    but they may begin with any of the six arms. For example, the same snowflake could be described as 1 2 3 4 5 6 or 4 3 2 1 6 5.
==> OUTPUT SPECIFICATION
    If all of the snowflakes are distinct, your program should print the message: No two snowflakes are alike.
    If there is a pair of possibly identical snowflakes, your program should print the message: Twin snowflakes found.
==> SAMPLE INPUT
    2
    1 2 3 4 5 6
    4 3 2 1 6 5
==> SAMPLE OUTPUT
    Twin snowflakes found.
*/

import std::io;

def SnowFlake = uint[<6>];

struct SFNode {
    SnowFlake sf;
    SFNode* sf_next;
}

macro atoui(String a) {
    uint i = 0;
    foreach (char c : a) {
        if (!c.is_digit()) break;
        i *= 10;
        i += (int)(c - '0');
    }
    return i;
}


fn void main() {
    String line = io::readline()!!;
    uint n = atoui(line);
    // SnowFlake[100_000] flakes;
    // usz sf_count = 0;
    // while (n > 0) {
    //     n--;
    //     String sf_line = io::readline()!!;
    //     String[] nums = sf_line.split(" ");
    //     assert(nums.len == 6);
    //     foreach (i, num: nums) {
    //         flakes[sf_count][i] = atoui(num);
    //     }
    //     sf_count++;
    // }
    // pairwise_comparision_with_pre_test(flakes[0..sf_count-1]);
    SFNode*[100_000] flake_list;
    usz list_count = 0;
    while(n > 0) {
        n--;
        String sf_line = io::readline()!!;
        String[] nums = sf_line.split(" ");
        assert(nums.len == 6);
        SFNode* sf = mem::alloc_aligned(SFNode);
        foreach (i, num: nums) {
            sf.sf[i] = atoui(num);
        }
        int key =  sf.sf.sum() % 100_000;
        sf.sf_next = flake_list[key];
        flake_list[key] = sf;
    }
    search_twin(flake_list[0..]);
}

macro sf_identify_eq(SnowFlake sf1, SnowFlake sf2) {
    return sf1.comp_eq(sf2).product();
}

macro sf_identify_twins(SnowFlake sf1, SnowFlake sf2) {
    // compare direct
    if (sf_identify_eq(sf1, sf2)) return true;
    // compare turning clockwise and counter-clockwise
    for (int i=0; i<5; i++) {
        sf2 = $$swizzle(sf2, 5, 0, 1, 2, 3, 4);
        if (sf_identify_eq(sf1, sf2)) return true;
        SnowFlake mirror = $$swizzle(sf2, 0, 5, 4, 3, 2, 1);
        if (sf_identify_eq(sf1, mirror)) return true;
    }
    return false;
}

/*
Time Complexity
O(n^2); n = no of flakes
Some Time on my AMD Ryzen 7 7730U with Radeon Grap
(all without any twin snowflakes)
snowflakes | time (s)
1000       | 0.08
10000      | 7.98
100000 takes too much to even count
*/
fn void pairwise_comparision(SnowFlake[] flakes) {
    for (int i=0; i<flakes.len-1; i++) {
        for (int j=i+1; j<flakes.len; j++) {
            if (sf_identify_twins(flakes[i], flakes[j])) {
                io::printn("Twin snowflakes found.");
                return;
            }
        }
    }
    io::printn("No two snowflakes are alike.");
}

/*
doing this pre check decreases the time to
snowflakes | time (s)
1000       | 0.01
10000      | 0.53
100000     | 28.98
*/
fn void pairwise_comparision_with_pre_test(SnowFlake[] flakes) {
    for (int i=0; i<flakes.len-1; i++) {
        for (int j=i+1; j<flakes.len; j++) {
            if (flakes[i].sum() != flakes[j].sum()) continue;
            if (sf_identify_twins(flakes[i], flakes[j])) {
                io::printn("Twin snowflakes found.");
                return;
            }
        }
    }
    io::printn("No two snowflakes are alike.");
}
/*
So Whats the possible solution?
I would assume (since the chapter is named hash table) it involves some kind
of hash function to hash the snowflake and index it into an hash table. and if a snowflake
already exists at the table indexed by key then there are twin flakes.
so the problem is how to hash the snowflakes so that twin snowflakes gives same flake but
if they are not twin they give different keys
OR
store the flakes whose sum are same into a kind of linked list and only compare among those
*/

/*
Finally the time
without compiler optimizations
snowflakes | time (s)
1000       | 0.00
10000      | 0.03
100000     | 0.38

with compiler optimizations (O4)
snowflakes | time (s)
1000       | 0.00
10000      | 0.01
100000     | 0.07
*/
fn void search_twin(SFNode*[] nodes) {
    for (int i=0; i<nodes.len; i++) {
        SFNode* sf_node1 = nodes[i];
        while(sf_node1 != null) {
            SFNode* sf_node2 = sf_node1.sf_next;
            while(sf_node2 != null) {
                if (sf_identify_twins(sf_node1.sf, sf_node2.sf)) {
                    io::printn("Twin snowflakes found.");
                    return;
                }
                sf_node2 = sf_node2.sf_next;
            }
            sf_node1 = sf_node1.sf_next;
        }
    }
    io::printn("No two snowflakes are alike.");
}
