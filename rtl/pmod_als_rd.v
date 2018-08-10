`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.08.2018 18:47:02
// Design Name: 
// Module Name: pmod_als_rd
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pmod_als_rd (
  input               clk_i,
  input               rst_i,
  
  // read request strobe
  input               rd_req_i,
  
  // value state strobe and value from spi
  output  reg         valid_o,
  output  reg [7 : 0] value_o,
  
  // SPI interface signals
  output  reg         cs_o,
  output              sck_o,
  input               sdo_i
);

reg [3 : 0] counter;

assign sck_o = clk_i;

always @( negedge clk_i or posedge rst_i )
  if ( rst_i )
    counter <= ~0;
  else 
    // the transfer request is handled only when module is idle (i. e. cs_o == 1)
    // ( ~counter ) is equivalent to ( counter != <maxvalue of counter> )
    if ( ( rd_req_i && cs_o ) || ( ~counter ) )
      counter <= counter + 1;
    
always @( negedge clk_i or posedge rst_i )
  if ( rst_i )
    cs_o <= 1;
  else
    if ( rd_req_i && cs_o )
      cs_o <= 0;
    else
      if ( !( ~counter ) )
        cs_o <= 1;

always @( posedge clk_i or posedge rst_i )
  if ( rst_i )
    value_o <= 0;
  else
    // if the counter state is 0 - nothing is doing (delay for ADC); 1, 2, 3 - leading zeroes
    // 4, ..., 11 - information bits; 12, ..., 15 - trailng zeroes
    if ( !cs_o && ( 4 <= counter ) && ( counter <= 11 ) )
      value_o[11 - counter] <= sdo_i;

always @( posedge clk_i or posedge rst_i )
  if ( rst_i )
    valid_o <= 0;
  else 
    if ( !cs_o && ( counter == 11 ) )
      valid_o <= 1;
    else 
      valid_o <= 0;

endmodule
