= 21.0.1

Improved performance and defined Ruby version 2.5.5 as minimum requirement

= 21.0.0

First version for game "Blokus"

= 20.2.4

Update game name in documentation

= 20.2.3

Improve method documentation

= 20.2.1 & 20.2.2

Bugfixes for performing moves on a gamestate

= 20.2.0

First version for game "Hive"

= 19.1.0

- winning condition is now set when changing a gamestate with Move#perform!

= 19.0.4

- fixed one more bug in in Move#perform! (thanks to wollw!)

= 19.0.3

- fixed another bug in in Move#perform! (thanks to wollw!)

= 19.0.2

- fixed bug in Move#perform! (thanks to wollw!)

= 19.0.1

- fixed bug in swarm size calculation (thanks to wollw!)

= 19.0.0

First version for game "Piranhas"

= 1.2.1

- fixed a bug which could lead to an infinite loop in the possible_move method

= 1.2.0

- fixed connection code
- fixed bug which lead to a exception when testing for playability of fallback card

= 1.1.0

Added missing perform! methods for actions.

= 1.0.0

First version for game "Hase und Igel".

= 0.3.4

Last version for game "Mississippi Queen".

- Renamed Turn#direction to Turn#turn_steps to make clearer that a number should be given, not a Direction instance.
- Corrected generation of XML for Push-actions

= 0.3.3

- Corrected checking/updating of coal for decelerations.

= 0.3.2

- Corrected some return types in the documentation (thanks to wollw!).

= 0.3.1

- Fixed bug: Coal was not read from server-XML (thanks to wollw!)

= 0.3.0

- Fixed bug where wrong (old) method getMove was called, the new name is
  move_requested
- Improved end game handling

= 0.2.0

- First working version for Mississippi Queen

= 0.1.5

- Fixed bug in reservation code.

= 0.1.4

- Added support for reservation ID to let clients work on contest system.

= 0.1.3

- Fixed bug in makeClearBoard method (thanks to wollw!).

= 0.1.2

- Fixed bug in == (test for equality) method of connections (thanks to
  wollw!).
- Fixed link in readme to code of conduct.
- Removed trailing whitespace.

= 0.1.1

Compatibility to Ruby 1.9 (source encoding issues)

= 0.1.0

First complete version.
