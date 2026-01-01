// MIT License

// Copyright (c) 2026 Kaveh Fazli

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
 *               This testbench shows some features and examples of instantiation
 *               of mbt_lfsr.
 *               It is not meant for the complete verification of the module 
 *               Three groups of instantiation:
 *               G1: The outputs of the same LFSR with different TPUT are collected
 *                   and will be compared at the end of the simulation
 *               G2: Outputs of the same LFSR with different TPUT 
 *                   are displayed on screen for the first 100 clocks for visual check
 *               G2: Outputs are not connected. Only shows the instantiation options
 * Parameters:   None
 *
 * output Ports: None
 *
 * input Ports:  None
 *
 * Dependencies: mbt_lfsr 
 *
 * Revision: Rev 1.00 - File Created
 *           Rev 2.00 - Parameter limitations revised in DUT. 
 *                      More detailed tests added to the tb 
 *
 ****************************************************************************/

`timescale 1ns / 1ps

module mbt_lfsr_tb;

  localparam TOT_CLK = 1000;

  reg reset = 0;
  reg seed_str = 0;

  initial begin
     # 3 reset = 1;
     # 13 reset = 0;

     # 43 seed_str = 1;
     # 53 seed_str = 0;

     // sim will be finished before this point because of TOT_CLK
     # 1000000 $finish;
  end

  reg clk = 0;
  always #5 clk = ~clk;

  integer clk_num = 0;

//------------------------------------------------------------------------
// G1
// Three similar LFSRs with different throughput sizes.
// The outputs of them are collected and will be compared at the end of the simulation.
// This is a basic verification of the throughput mechanism.
// For WIDTH = 30 and MAX(TAP) = 16 
// Max TPUT we can get is 30 - 16 = 14 

  localparam TPUT_1 = 5;
  localparam COLL_1 = (TOT_CLK * TPUT_1);
  reg [COLL_1 - 1 : 0] coll_1 ; // output collector. LSB old, MSB new
  wire [TPUT_1-1 : 0] tput_1;
  mbt_lfsr #(.WIDTH(30), .TPUT(TPUT_1), .TAP3(16), .TAP2(15), .TAP1(1), .TAP0(0) ) 
             lfsr_30_1 (tput_1, clk, reset, 1'b0, 30'b0);

  localparam TPUT_2 = 6;
  localparam COLL_2 = (TOT_CLK * TPUT_2);
  reg [COLL_2 - 1 : 0] coll_2 ;
  wire [TPUT_2-1 : 0] tput_2;
  mbt_lfsr #(.WIDTH(30), .TPUT(TPUT_2), .TAP3(16), .TAP2(15), .TAP1(1), .TAP0(0) ) 
             lfsr_30_2 (tput_2, clk, reset, 1'b0, 30'b0);

  localparam TPUT_3 = 14;
  localparam COLL_3 = (TOT_CLK * TPUT_3);
  reg [COLL_3 - 1 : 0] coll_3 ;
  wire [TPUT_3-1 : 0] tput_3;
  mbt_lfsr #(.WIDTH(30), .TPUT(TPUT_3), .TAP3(16), .TAP2(15), .TAP1(1), .TAP0(0) ) 
             lfsr_30_3 (tput_3, clk, reset, 1'b0, 30'b0);

//------------------------------------------------------------------------
// G2
// The output of the following instantiation are not collected.
// The outpus are displayed for visual check for 100 clocks

//-----------
// G2-A
// Default WIDTH and TAPs, different TPUTs (throughput)

  wire def_1b;
  mbt_lfsr #(.TPUT(1)) lfsr_def_1b (def_1b, clk, reset, 1'b0, 28'b0);

  wire [7:0] def_8b;
  mbt_lfsr #(.TPUT(8)) lfsr_def_8b (def_8b, clk, reset, 1'b0, 28'b0);

  wire [24:0] def_25b;
  mbt_lfsr #(.TPUT(25)) lfsr_def_25b (def_25b, clk, reset, 1'b0, 28'b0);

  // seed_str is inserted during clk# 4-8 and the output is stable at the seed
  wire [15:0] def_16b_s;
  mbt_lfsr #(.TPUT(16)) lfsr_def_16b_s (def_16b_s, clk, reset, seed_str, 28'b10101010_11001100_11111111_1111 ) ;

//-----------
// G2-B
// Non-default LFSRs 

  wire [6:0] ndef_7;
  mbt_lfsr #(.WIDTH(30), .TPUT(7), .TAP3(16), .TAP2(15), .TAP1(1), .TAP0(0) ) 
             lfsr_30_7 (ndef_7, clk, reset, 1'b0, 30'b0);

  wire [13:0] ndef_14;
  mbt_lfsr #(.WIDTH(30), .TPUT(14), .TAP3(16), .TAP2(15), .TAP1(1), .TAP0(0) ) 
             lfsr_30_14 (ndef_14, clk, reset, 1'b0, 30'b0);

//  Same as the above LFSR, but Compilation Error, because TPUT is big
//  mbt_lfsr #(.WIDTH(30), .TPUT(15), .TAP3(16), .TAP2(15), .TAP1(1), .TAP0(0) ) 
//             lfsr_30_15 (, clk, reset, 1'b0, 30'b0);

//------------------------------------------------------------------------
// G3
// The output of the following instantiation are not connected.
// They only show some valid instantiations

  // 16 bit throughput from 2-tap 35-bit LFSR
  wire [15:0] value_16b;
  mbt_lfsr      #(.WIDTH(35), .TPUT(16), .TAP1(2), .TAP0(0) ) 
      lfsr_35_16 (, clk, reset, 1'b0, 35'b0);

  // 24 bit throughput from 2-tap 52-bit LFSR
  wire [23:0] value_24b;
  mbt_lfsr      #(.WIDTH(52), .TPUT(24), .TAP1(3), .TAP0(0) ) 
      lfsr_52_24 (value_24b, clk, reset, 1'b0, 52'b0);

  // 50 bit throughput from 6-tap 72-bit LFSR
  wire [49:0] value_50b;
  mbt_lfsr      #(.WIDTH(72), .TPUT(50), .TAP5(22), .TAP4(14), .TAP3(11),
                                         .TAP2(10), .TAP1(6), .TAP0(0) ) 
      lfsr_72_24 (value_50b, clk, reset, 1'b0, 72'b0);

//------------------------------------------------------------------------

  integer ii, min_coll;

  always @(posedge clk)
  begin
    if (reset) begin
      clk_num <= -1;
    end else  begin
      //--------------------------------------------------
      //end of sim checks
      if (clk_num == TOT_CLK) begin 
        $display(  "────────────────────────────────────────────────────────────────────────────────────\n");

// G1
// Three similar LFSRs with different throughput sizes.
// The outputs of them are collected and will be compared at the end of the simulation.



        $display("G1 group test");
        $display("The outputs of 3 similar LFSRs with TPUT are collected");
        $display("First and last 100 bits displayed."); 
        $display("First 100 bits are similar, last 100 bits not\n");
        $display("%8d bits collected with TPUT: %2d", COLL_1, TPUT_1);
        $display("%b", coll_1[99:0]);
        $display("%b", coll_1[COLL_1-1:COLL_1-100]);
        $display("%8d bits collected with TPUT: %2d", COLL_2, TPUT_2);
        $display("%b", coll_2[99:0]);
        $display("%b", coll_2[COLL_2-1:COLL_2-100]);
        $display("%8d bits collected with TPUT: %2d", COLL_3, TPUT_3);
        $display("%b", coll_3[99:0]);
        $display("%b", coll_3[COLL_3-1:COLL_3-100]);
        min_coll = (COLL_1 < COLL_2) ? COLL_1 : COLL_2;
        min_coll = (min_coll < COLL_3) ? min_coll : COLL_3;

        $display("\nThe collected stream is checked to the size of the smallest one");
        $display("checking %4d bits", min_coll);
        // check the collected stream to the size of the smallest one
        for(ii=0; ii < min_coll; ii=ii+1) begin
          if ((coll_1[ii] !== coll_2[ii]) || (coll_1[ii] !== coll_3[ii])) begin
            $display("Mismatch at %d", ii );
            $display("coll_1 [ %d ] = %b", ii, coll_1[ii] );
            $display("coll_2 [ %d ] = %b", ii, coll_2[ii] );
            $display("coll_3 [ %d ] = %b", ii, coll_3[ii] );
            $finish;
          end
        end  
        $display("%8d bits checked, all matched\n", COLL_1);
  
        $finish;
      end
      //--------------------------------------------------
      // collecting the otput of 3 similar LFSRs
      coll_1 <= {tput_1, coll_1[ COLL_1 - 1 : TPUT_1 ]}; //shift tput_1 into coll_1 from msb
      coll_2 <= {tput_2, coll_2[ COLL_2 - 1 : TPUT_2 ]}; 
      coll_3 <= {tput_3, coll_3[ COLL_3 - 1 : TPUT_3 ]}; 

      // display only the first 100 clocks
      if (clk_num < 100) begin  
        if ((clk_num & 7) == 0) $display("────│                                        │                   │");
        $display("%03d │ %b  %b  %b │ %b  │ %b  %b", clk_num, def_1b, def_8b, def_25b, def_16b_s, ndef_7, ndef_14 );
      end
      clk_num <= clk_num + 1;
    end
  end

 
  initial
  begin
   $dumpfile("lfsr_wave.vcd");
   $dumpvars(0);
   $display("\n    │         Default LFSRs in Group G2-A        seed @ CLK#4-8  │  Non-default G2-B");
   $display(  "clk#│ 1b    8b            25b                │ 10101010_11001100 │  7b      14b  ");
   $display(  "────────────────────────────────────────────────────────────────────────────────────");
  end


endmodule 