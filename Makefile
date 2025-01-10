clean:
	rm -rf firtool*
	rm -rf firrtl*
	cd cmt2 && cargo clean && cd ..
	rm -rf hector/build
	cd hestia && cargo clean && cd ..
	rm -rf popa/build
	rm -rf ksim/build ksim/install ksim/third_party/lemon* ksim/third_party/circt
	rm -rf llvm-project
	rm -rf iverilog