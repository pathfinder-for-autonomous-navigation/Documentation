====================================
Desktop Operation of Flight Software
====================================

One of the great things about PAN's flight software is that it can run both on a tiny ARM-based microcontroller
(the Teensy 3.5/3.6) and on any Linux or Mac platform. We call the latter version of flight software the
`native binary`, because our build system, `PlatformIO <http://platformio.org>`_, calls desktop platforms
the "native" platform. The key differences between the two platforms are how we manage communication with
the flight software and how hardware is managed.

Communicating with Flight Software
==================================

