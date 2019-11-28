===========
Serializers
===========

Serializers are the workhorse unit of telemetry processing. Each state field
that's readable or writable from the ground houses an instance of a serializer,
which can be used to convert the value of the state field to/from a bitstream
representation.

You read that right: I said `bitstream` representation. Due to the limited 70-byte
downlink packet size, PAN serializers take compression to an extreme degree and
squeeze every available bit out of the bandwidth. This is achieved by realizing that
fields on the spacecraft have a limited range of values, or have a limited range of
resolution that we care about on the ground. Using this realization, we can specify
a fixed-point scheme for compressing state fields at compile time.

As an example, suppose we have an unsigned integer ``x`` representing the state of a state machine that
has 11 total states. Since 11 is less than 16, note that we only need four bits to actually represent
the value of the state field. So a serializer for ``x`` would compress `x` down to 4 bits, rather than
the 32 bits that it would usually take, or the 8 bits that it would take if we naively reduced `x` 
down to an unsigned character. Using schemes like this all across our spacecraft, we've found that
compressing at the bit level reduces our telemetry size by up to 60%.

Serializers allow conversion to/from a bitstream representation, but also allow conversions
to/from an ASCII representation of the internally containe data. This is useful for transacting
data over a USB link when operating the flight software in testing mode. In summary, the following methods
are exposed by Serializer:

- ``serialize``: Converts a given value into a bitstream, which is stored internally within the Serializer object.
- ``deserialize``: Converts the internally stored bitstream into a value and writes it to an input pointer.
- ``deserialize``: An overload of deserialize takes the ASCII-encoded value provided in an input character buffer and converts the given value into a bitstream, which is then internally stored.
- ``get_bit_array``: Gets a reference to the internal bitstream (this is useful for downlinking).
- ``set_bit_array``: Sets the internal bitstream (useful for uplinks.)
- ``print``: Converts the internally stored bitstream into an ASCII value that can be printed to a screen.

Constructing a serializer requires specifying the number of bits desired in the representation of its value,
along with "minimum" and "maximum" parameters specifying the bounds of the value. For certain serializers (this
will be explained in the upcoming sections), there are available default parameters that preclude the need for
specifying some of these three values.

Serializer is defined for the following basic types, which are explained in more detail in the hyperlinked sections:

- `Boolean Serializer`_
- `Integer Serializer`_
- `GPS Time Serializer`_
- `Quaternion Serializer`_
- `Vector Serializer`_

Boolean Serializer
==================
Type name: ``Serializer<bool>``

Booleans are the simplest serializer to implement: a boolean's value is either a 1 or a 0, so it can be
represented by a bitstream of size 1. The constructor for a boolean serializer accepts no arguments since none
are required.

Integer Serializer
==================
Type names: ``Serializer<unsigned int>``, ``Serializer<signed int>``, ``Serializer<unsigned char>``, ``Serializer<signed char>``

I described integer serializers in some detail in the introductory section, but here I'll go into greater
detail.

There are a few kinds of constructors for integer serializers:

- There's the "standard" constructor that requires three arguments, ``min``, ``max``, and ``bitsize``.
- There's a constructor accepting only ``min`` and ``max``, which automatically computes the required bitsize needed to represent the full range of the possible integer values (i.e. ``bitsize`` = :math:`\lceil \log_2(\texttt{max} - \texttt{min}) \rceil`).
- For `unsigned int` and `unsigned char` serializers, there's a constructor accepting only ``max``. Internally this just calls the constructor we just mentioned, but sets ``min`` to 0.
- Also for `unsigned int` and `unsigned char` serializers, there's a no-argument constructor that sets ``max`` to 2^32 - 1 for ``unsigned int`` serializers and to 2^8 - 1 for ``unsigned char`` serializers.

These serializers, in general, work as follows: the specified ``bitsize`` provides 
TODO

GPS Time Serializer
===================
Type name: ``Serializer<gps_time_t>``
TODO

Quaternion Serializer
=====================
Type name: ``Serializer<f_quat_t>``, ``Serializer<d_quat_t>``
TODO

Vector Serializer
=================
Type name: ``Serializer<f_vec_t>``, ``Serializer<d_vec_t>``
TODO
