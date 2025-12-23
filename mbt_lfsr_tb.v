// MIT License

// Copyright (c) 2025 Kaveh Fazli

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/***************************************************************************
 *
 * Module: mbt_lfsr_tb
 *
 * Author: Kaveh Fazli
 *
 * Description:  Testbench for mbt_lfsr module.
 *               Thiis testbench shows some features and examples of instantiation
 *               of mbt_lfsr.
 *               It is not meant for the complete verification of the module 
 *
 * Parameters:   None
 *
 * output Ports: None
 *
 * input Ports:  None
 *
 * Dependencies: mbt_lfsr 
 *
 * Revision: Revision 1.00 - File Created
 *
 ****************************************************************************/

`timescale 1ns / 1ps // Recommended timescale directive

module mbt_lfsr_tb;

  reg reset = 0;
  reg seed_str = 0;

  initial begin
     # 3 reset = 1;
     # 13 reset = 0;

     # 43 seed_str = 1;
     # 53 seed_str = 0;

     # 2000 $finish;
  end

  reg clk = 0;
  always #5 clk = ~clk;

  integer clk_num = 0;

// Default WIDTH and TAPs, different TPUTs (throughput)
  wire value_1b;
  mbt_lfsr #(.TPUT(1)) lfsr__def_1b (value_1b, clk, reset, 1'b0, 26'b0);

  wire [7:0] value_8b;
  mbt_lfsr #(.TPUT(8)) lfsr__def_8b (value_8b, clk, reset, 1'b0, 26'b0);

  wire [8:0] value_9b;
  mbt_lfsr #(.TPUT(9)) lfsr__def_9b (value_9b, clk, reset, 1'b0, 26'b0);

  // seed_str is inserted during clk# 4-8 and the output is stable at the seed
  wire [7:0] value_8b_s;
  mbt_lfsr #(.TPUT(8)) lfsr__def_8b_s (value_8b_s, clk, reset, seed_str, 26'b10100101_00000000_11111111_11 ) ;


//------------------------------------------------------------------------
// The output of the following instantiation are not connected.
// They only show some valid instantiations


  mbt_lfsr #(.WIDTH(30), .TPUT(6), .TAP3(16), .TAP2(15), .TAP1(1), .TAP0(0) ) 
             lfsr_30_4 (, clk, reset, 1'b0, 30'b0);

//  Similar to above, but Compilation Error, because TPUT is big
//  mbt_lfsr #(.WIDTH(30), .TPUT(7), .TAP3(16), .TAP2(15), .TAP1(1), .TAP0(0) ) 
//             lfsr_30_4 (, clk, reset, 1'b0, 30'b0);


  // 16 bit throughput from 2-tap 35-bit LFSR
  mbt_lfsr #(.WIDTH(35), .TPUT(16), .TAP1(2), .TAP0(0) ) 
             lfsr_35_16 (, clk, reset, 1'b0, 35'b0);

  // 24 bit throughput from 2-tap 52-bit LFSR
  mbt_lfsr #(.WIDTH(52), .TPUT(24), .TAP1(3), .TAP0(0) ) 
             lfsr_52_24 (, clk, reset, 1'b0, 52'b0);

  // 24 bit throughput from 6-tap 72-bit LFSR
  mbt_lfsr #(.WIDTH(72), .TPUT(24), .TAP5(22), .TAP4(14), .TAP3(11), .TAP2(10), .TAP1(6), .TAP0(0) ) 
             lfsr_72_24 (, clk, reset, 1'b0, 72'b0);



  always @(posedge clk)
  begin
    if (reset) begin
      clk_num <= -1;
    end else  begin
      if ((clk_num & 7) == 0) $display("----");
      $display("%03d  %b  %b  %b  %b", clk_num, value_1b, value_8b, value_9b, value_8b_s);
      clk_num <= clk_num + 1;
    end
  end

 
  initial
  begin
   $dumpfile("lfsr_wave.vcd");
   $dumpvars(0);
   $display("\nclk# 1b    8b        9b     8b w seed @ #4\n");
  end


endmodule 