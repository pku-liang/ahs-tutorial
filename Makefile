clean:
	rm -rf firtool*
	rm -rf firrtl*
	rm -rf cmt2/target
	rm -rf hector/build
	rm -rf hestia/target
	rm -rf popa/build
	make -C iverilog clean
	rm -rf ksim/build ksim/install ksim/third_party/lemon* ksim/third_party/circt/build ksim/third_party/circt/llvm/build
	rm -rf llvm-project/install
