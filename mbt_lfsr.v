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
 * Module: mbt_lfsr
 *
 * Author: Kaveh Fazli
 *
 * Description: This is a general parameterized multi-bit throughput LFSR
 *              Can be used for 2- 4- or 6- tap LFSRs
 *              No limitation on the Width
 *              Limitation on Throghput is defined by TAPs and width. 
 *              The following equation must be satisfied:
 *              MAX(TAPs) < WIDTH - Throghput
 *
 * Parameters:
 *              WIDTH: The number of LFSR register bits
 *              TPUT:  The number of throughput bits generated every clock, so the size of out port
 *              TAP0-TAP5: the location of LFSR taps
 *                         valid numbers 0 to WIDTH - 1 
 *                         Leave unused TAPs to 0
 *
 * output Ports:
 *              out: TPUT-bit output, connected to the most significant bits of the LFSR register
 *
 * input Ports:
 *              clk: posedge
 *              reset: active high
 *              seed_str: strobe to load seed_val to LFSR registers. active high
 *              seed_val: WIDTH-bit seed value to be loaded to LFSR registers
 *
 * Comments: For examples of instantiation see file mbt_lfsr_tb.v
 *
 * Dependencies: None 
 *
 * Revision: Rev 1.00 - File Created
 * Revision: Rev 2.00 - Parameter limitations revised
 *
 ****************************************************************************/

`timescale 1ns / 1ps

module mbt_lfsr(out, clk, reset, seed_str, seed_val);

  parameter WIDTH = 28; //# of LFSR bits (n)
  parameter TPUT = 8;   //# of TPUT bits (k)
  // Up to 6 taps can be defined. Leave unused TAPs to 0
  parameter TAP0 = 0;
  parameter TAP1 = 3;
  parameter TAP2 = 0;
  parameter TAP3 = 0;
  parameter TAP4 = 0;
  parameter TAP5 = 0;

  output  wire [TPUT-1:0] out;
  input   wire clk, reset;
  input   wire seed_str;
  input   wire [WIDTH-1:0] seed_val;


  //This generate block works as assertion in pure Verilog
  //Checks parameters and causes compilation error in case of wrong param 
  generate
    localparam MAX_T01 = (TAP0 > TAP1) ? TAP0 : TAP1;
    localparam MAX_T23 = (TAP2 > TAP3) ? TAP2 : TAP3;
    localparam MAX_T45 = (TAP4 > TAP5) ? TAP4 : TAP5;
    localparam MAX_T0123 = (MAX_T01 > MAX_T23) ? MAX_T01 : MAX_T23;
    localparam MAX_T = (MAX_T0123 > MAX_T45) ? MAX_T0123 : MAX_T45;
    //I know, the above lines can be combined into a large line
    //But it is more readable and debuggable this way
  
    if (MAX_T  > (WIDTH - TPUT)) begin : CHK_PARAMS
      // This invalid line generates compilation error
      invalid_line();
    end else begin : PARAMS_PASS
      // MAX_T =< (WIDTH - TPUT)
      // Do nothing
    end
  endgenerate  

  reg  [WIDTH-1:0]  lfsr_reg;
  wire [TPUT-1:0]   lfsr_fb;

  // feedback is repeated TPUT times
  genvar i;
  generate
    for (i = 0; i < TPUT; i = i + 1) begin
      assign lfsr_fb[i] = lfsr_reg[TAP0+i]^lfsr_reg[TAP1+i]^lfsr_reg[TAP2+i]^lfsr_reg[TAP3+i]^lfsr_reg[TAP4+i]^lfsr_reg[TAP5+i];  
    end
  endgenerate

  assign out = lfsr_reg[WIDTH - 1 : WIDTH - TPUT];

  always @(posedge clk or posedge reset)
    if (reset)
      lfsr_reg <= {WIDTH{1'b1}};
    else begin
    if(seed_str)
      lfsr_reg <= seed_val;
      else begin
        lfsr_reg [WIDTH - TPUT - 1 : 0] <= lfsr_reg [WIDTH - 1 : TPUT]; 
        lfsr_reg [WIDTH - 1 : WIDTH - TPUT] <= lfsr_fb;
      end
    end
endmodule 