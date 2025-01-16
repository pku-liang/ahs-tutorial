demo:
	iverilog -g2012 kernel/demo_gemm.sv testbench/demo_tb.sv utils/lib.sv -o demo_gemm.vvp
	vvp demo_gemm.vvp

gemm:
	iverilog -g2012 kernel/gemm.sv testbench/gemm_tb.sv utils/lib.sv -o gemm.vvp
	vvp gemm.vvp
