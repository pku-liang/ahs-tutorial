#include"adder.h"
#include<cstdlib>
#include<chrono>
#include<iostream>

int main(int argc, char ** argv) {
  int cnt = atoi(argv[1]);
  adder_8bit();
  auto start = std::chrono::system_clock::now();

  printf("%4s,%4s,%8s,%4s,%12s,%10s,%17s\n",
         "A", "B", "Carry_In", "Sum", "Expected_Sum", "Carry_Out", "Expected_Carry_Out");
  for(auto i = 0; i < cnt; i++) {
    a = rand();
    b = rand();
    carry_in = rand() & 1;
    adder_8bit();

    int expected_sum = (a + b + carry_in) % 256;
    int expected_carry_out = (a + b + carry_in) >> 8;
    printf("%4d,%4d,%8d,%4d,%12d,%10d,%17d\n", 
           a, b, carry_in, sum, expected_sum, carry_out, expected_carry_out);
    if(sum != expected_sum || carry_out != expected_carry_out) {
      fprintf(stderr, "ERROR: Mismatch detected!\n");
      fprintf(stderr, "  Inputs:  a=%d, b=%d, carry_in=%d\n", a, b, carry_in);
      fprintf(stderr, "  Outputs: sum=%d (expected %d), carry_out=%d (expected %d)\n",
              sum, expected_sum, carry_out, expected_carry_out);
    }
  }
  auto stop = std::chrono::system_clock::now();
  std::cout << std::chrono::duration_cast<std::chrono::microseconds>(stop - start).count() << std::endl;
  return 0;
}