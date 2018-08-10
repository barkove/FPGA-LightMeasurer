`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.08.2018 16:38:49
// Design Name: 
// Module Name: tb_light_measurer
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


module tb_light_measurer();

parameter CLOCK_SEMI_PERIOD_NS = 5;

reg           clk, rst;

wire  [7 : 0] future_leds;

// SPI interface signals
wire          cs_o, sck_o;
reg           sdo_i;
  
light_measurer #(
  .PERIOD_IN_PEAKS        ( 300         ),
  // SIZE_OF_PERIOD_COUNTER depends of PERIOD_IN_PEAKS
  .SIZE_OF_PERIOD_COUNTER ( 9           )
) light_measurer_0 (
  .clk_i                  ( clk         ),
  .rst_i                  ( rst         ),
  
  .leds                   ( future_leds ),
  
  // SPI interface signals
  .cs_o                   ( cs_o        ),
  .sck_o                  ( sck_o       ),
  .sdo_i                  ( sdo_i       )
);

task clock_start();
  begin
    clk = 0;
    forever #CLOCK_SEMI_PERIOD_NS 
      clk = ~clk;
  end
endtask

integer i;

task adc_says(
  input [7 : 0] value
);
  begin
    // 1, 2, 3 - leading zeroes
    for ( i = 1; i <= 3; i = i + 1 )
      begin
        @( negedge sck_o );
        sdo_i = 0;
      end
    // 4, ..., 11 - information bits
    for ( i = 4; i <= 11; i = i + 1)
      begin
        @( negedge sck_o );
        sdo_i = value[11 - i];
      end
    // 12, ..., 15 - trailng zeroes
    for ( i = 12; i <= 15; i = i + 1 )
      begin
        @( negedge sck_o );
        sdo_i = 0;
      end
  end
endtask
  
reg [7 : 0]  test_value_from_adc; 

initial
  begin
    test_value_from_adc = 10;
    rst = 1;
    #CLOCK_SEMI_PERIOD_NS;
    rst = 0;
    clock_start();
  end
  
always @( negedge cs_o )
  begin
    adc_says(test_value_from_adc);
    test_value_from_adc = test_value_from_adc + 10;
  end

endmodule
