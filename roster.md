# Raid Structure, Group and Raid Indices
To implement sorting functionality, it is important to understand the structure of a raid and
how it is represented in the WoW API:
1. A raid consists of 8 groups of up to 5 players each, for a total of 40 maximum players.
2. For the purposes of Brutilities, only groups 1-6 will be used for final rosters, though groups
   7 and 8 may be used for temporary storage during the sorting process.
3. Each position in the raid is indexed sequentially starting at 1, the first position in group 1,
   and ending at 40, the last position in group 8.
4. For the purposes of "splitting" the raid, groups 1, 3, and 5 are considered "odd" groups, while
   groups 2, 4, and 6 are considered "even" groups; while the group numbering is intuitive, it can
   get confusing because odd groups contain even raid indices and vice versa (e.g., group 3 contains
   raid indices 11-15 including 12 and 14).

# Raid Composition, Player Roles, and Class Balance
With the structure of the raid in mind, we can talk about the "composition" of a raid, meaning the
mixture and balance of player roles and how they inform the sorting algorithm. To implement the basic
functionality, we can make the following assumptions about the structure of a raid:
1. A raid will have between 10 and 30 players (inclusive).
2. A raid will have exactly 2 tanks, then some number of healers and dps; a typical ratio is ~1 healer
   for every 4-5 total players, so an 18-man raid may consist of 2 tanks, 4 healers, and 12 dps.
3. The objective of the sorting and splitting algorithm is to create a raid that is as balanced as
   possible with respect to player roles and classes or class abilities. The sorting algorithm should
   attempt to adhere to the following principles:
   a. Tanks are assigned the "top" position in each half; indicies 1 and 6 in groups 1 and 2 respectively.
   b. Healers should be assigned top positions in each group after tanks (e.g., indices 2 and 7 in
      groups 1 and 2, but beginning in group 3 where there is no tank the first spot, 11, goes to
      a healer).
   c. Once tanks and healers are assigned, dps can be thought of as "filling out" the rest of the
      available spots in such a way as to achieve balance in number and class.
   d. The primary goal of the sort is to balance player numbers, neither half should ever differ
      by more than 1 player from the other half after a sort is complete.
   e. The secondary goal of the sort is to balance player classes which is important to distribute
      key raid abilities like ressurrection and dispels; it may not be possible to always achieve
      "perfect" class balance while adhering to the requirement to balance numbers, but the algorithm
      should get as close as possible to this ideal.
4. One potential approach to preparing to achieve this sorting is to first sort the list of players
   by combat role where TANK > HEALER > DAMAGER, then to sort by class. Sorting this way first and
   then assigning new indices in this order may make the job of balancing classes and roles much
   easier (e.g., tank assignment should always be simple because their indices will always be available
   if they are assigned first).
   
# Sorting Logic Summary
The general approach to sorting a raid should follow these general steps:
1. Use GetRaidRosterInfo() to get the current layout and composition, or "where players are."
2. Apply the guidelines laid out above in the raid composition section to identify the ideal
   future position for each player, effectively assigning a new target index to each player; the
   "where they should be" step.
3. Use SetRaidSubgroup( index, group ) and/or SwapRaidSubgroup( index, index ) to rearrange players
   into their desired destination positions. There are two key considerations when designing the
functions to actually move players:
   a. It is unclear if it's possible to assign players directly to a specific index; it may be
      necessary to simply ensure that players belong to the group that conatins their assigned
      index. However, if index-accurate sorting can be achieved it should be preferred.
   b. It is unlikely the game client will respond appropriately to a large number of group assignments
      or swaps being executed simultaneously; this module will likely need to implement a "queue"
      of moves and then execute them on a timer at a predefined frequency such as every 250ms.

# Possible Approach:
If SwapRaidSubgroup works as expected, the approach requiring the fewest total moves should be something
close to:
For each index n, if the player at that index is not assigned to index n, then find the player who is
and call SwapRaidSubgroup( n, index ) where index is the index of the player who should be there.
If this does not work as expected, an alternative approach may be to "vacate" a destination group by
moving all players who currently occupy it to empty spots not in that group, then finding each player
assigned to the now-empty group and using SetRaidSubgroup to move them into it in the order of their
index assignments. This would require more total moves but may be more reliable and easier to understand.

# Final Considerations
1. It is important to keep in mind the primacy of the "balance numbers" rule; for example this may
   result in having two incomplete groups in either half - it is not necessary to "fill" or complete
   a group if doing so upsets the numbers balance.
2. The notion of "first available" may be important in a number of contexts, for example:
   a. Get the first available index in a group
   b. Get the first available index in a half (even/odd)
   c. Get the first available index in the raid (regardless of group or half)
   d. Get the first group that has an available index
3. To support sorting and assigning new indices, maintaining a mapping table of players to their
   current and future indices will be needed; to successfully implement the "get first available"
   logic we will need to track which indices have already been assigned to players.
