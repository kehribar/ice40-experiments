// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
module clockgen(
  input clk, 
  output clkout
);
   
// The following code multiplies the 12 MHz on the board to 60 MHz 
// (12 MHz * 80 / 16) using a PLL VCO Frequency of 960 MHz (12 MHz * 80):

SB_PLL40_CORE #(
  .FEEDBACK_PATH("SIMPLE"),
  .PLLOUT_SELECT("GENCLK"),
  .DIVR(4'b0000),
  .DIVF(7'b1001111),
  .DIVQ(3'b100),
  .FILTER_RANGE(3'b001)
) 
pll_inst(
  .RESETB(1'b1),
  .BYPASS(1'b0),
  .REFERENCECLK(clk),
  .PLLOUTCORE(clkout)
);

endmodule