= 0.3.4

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
