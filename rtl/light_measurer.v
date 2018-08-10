`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.08.2018 18:45:22
// Design Name: 
// Module Name: light_measurer
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


module light_measurer #(
  parameter PERIOD_IN_PEAKS        = 20,
  // SIZE_OF_PERIOD_COUNTER depends of PERIOD_IN_PEAKS
  parameter SIZE_OF_PERIOD_COUNTER = 5
)(
  input               clk_i,
  input               rst_i,
  
  output [7 : 0]      leds,
  
  // SPI interface signals
  output              cs_o,
  output              sck_o,
  input               sdo_i
);

wire                                      rd_req;   
         
wire                                      valid_spi;
wire    [7 : 0]                           value_spi;

wire                                      pwm_out;

reg     [SIZE_OF_PERIOD_COUNTER - 1 : 0]  counter;

pmod_als_rd pmod_als_rd_0 (
  .clk_i          ( clk_i     ),
  .rst_i          ( rst_i     ),
  
  // read request strobe
  .rd_req_i       ( rd_req    ),
  
  // value state strobe and value from spi
  .valid_o        ( valid_spi ),
  .value_o        ( value_spi ),
  
  // SPI interface signals
  .cs_o           ( cs_o      ),
  .sck_o          ( sck_o     ),
  .sdo_i          ( sdo_i     )
);

pwm_gen #(
  // the size is equal to spi value size
  .SIZE_OF_VALUE  ( 8         )
) pwm_gen_0 (
  .clk_i          ( clk_i     ),
  .rst_i          ( rst_i     ),
  
  // setting of pwm 
  .set_i          ( valid_spi ),
  .value_i        ( value_spi ),
  
  .pwm_o          ( pwm_out   ) 
);

assign rd_req = !counter;

assign leds = { 8 { pwm_out } };

always @( posedge clk_i or posedge rst_i )
  if ( rst_i )
    counter <= 0;
  else 
    if (counter != ( PERIOD_IN_PEAKS - 1 ) )
      counter <= counter + 1;
    else
      counter <= 0;

endmodule