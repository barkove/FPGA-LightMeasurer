`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.08.2018 18:45:22
// Design Name: 
// Module Name: pwm_gen
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


module pwm_gen #(
  parameter SIZE_OF_VALUE = 8
)(
  input                          clk_i,
  input                          rst_i,
  
  // setting of pwm 
  input                          set_i,
  input  [SIZE_OF_VALUE - 1 : 0] value_i,
  
  output                         pwm_o 
);

reg                         srst;
reg [SIZE_OF_VALUE - 1 : 0] counter;
reg [SIZE_OF_VALUE - 1 : 0] value;

assign pwm_o = ( !rst_i && ( counter < value ) ) ? 1 : 0;

always @( posedge clk_i or posedge rst_i )
  if ( rst_i )
    value <= 0;
  else
    if ( set_i )
      value <= value_i;

always @( posedge clk_i or posedge rst_i )
  if ( rst_i )
    srst <= 0;
  else
    if ( set_i )
      srst <= 1;
    else 
      srst <= 0;

always @( posedge clk_i or posedge rst_i ) 
  if ( rst_i || srst )
    counter <= 0;
  else 
    counter <= counter + 1;

endmodule
