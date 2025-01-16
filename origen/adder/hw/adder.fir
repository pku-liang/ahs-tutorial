circuit adder_8bit: @[adder2.sv:1.1-11.10]
  module adder_8bit: @[adder2.sv:1.1-11.10]
    output carry_out: UInt<1> @[adder2.sv:6.24-6.33]
    output sum: UInt<8> @[adder2.sv:5.24-5.27]
    input carry_in: UInt<1> @[adder2.sv:4.24-4.32]
    input b: UInt<8> @[adder2.sv:3.24-3.25]
    input a: UInt<8> @[adder2.sv:2.24-2.25]

    wire _add_adder2_sv_9_2_Y: UInt<9> @[adder2.sv:9.31-9.47]
    wire _add_adder2_sv_9_1_Y: UInt<9> @[adder2.sv:9.31-9.36]
    wire _add_adder2_sv_9_2: UInt<9> @[adder2.sv:9.31-9.47]
    wire _add_adder2_sv_9_1: UInt<9> @[adder2.sv:9.31-9.36]
    wire _0: UInt<9>


    _add_adder2_sv_9_2 <= add(_add_adder2_sv_9_1_Y, asUInt(pad(carry_in, 9))) @[adder2.sv:9.31-9.47]
    _add_adder2_sv_9_1 <= add(pad(a, 9), asUInt(pad(b, 9))) @[adder2.sv:9.31-9.36]
    _0 <= _add_adder2_sv_9_2_Y

    _add_adder2_sv_9_2_Y <= bits(_add_adder2_sv_9_2, 8, 0) @[adder2.sv:9.31-9.47]
    _add_adder2_sv_9_1_Y <= bits(_add_adder2_sv_9_1, 8, 0) @[adder2.sv:9.31-9.36]
    carry_out <= bits(_0, 8, 8) @[adder2.sv:6.24-6.33]
    sum <= bits(_0, 7, 0) @[adder2.sv:5.24-5.27]

