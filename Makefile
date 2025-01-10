clean:
	rm -rf firtool*
	rm -rf firrtl*
	cd cmt2 && cargo clean && cd ..
	rm -rf hector/build
	cd hestia && cargo clean && cd ..
	rm -rf popa/build
	make -C iverilog clean
	rm -rf ksim/build ksim/install ksim/third_party/lemon* ksim/third_party/circt/build ksim/third_party/circt/llvm/build
	rm -rf llvm-project/install