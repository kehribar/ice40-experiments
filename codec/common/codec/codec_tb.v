// ----------------------------------------------------------------------------
// ...
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

// ----------------------------------------------------------------------------
module top_tb();

// ----------------------------------------------------------------------------
reg clk, rst;

// ----------------------------------------------------------------------------
wire LRCK;
wire BCLK;
wire MCLK;
wire SDTI;
wire SDTO;
wire PDN;

reg [23:0] testData;

// ----------------------------------------------------------------------------
// Initialize all variables and run the test
initial begin
  $dumpfile("codec_tb.vcd");
  $dumpvars(0, codec_inst);
  clk <= 1;
  rst <= 1;  
  testData <= 24'hFFFFFF;
  #50 rst <= 0;
  #2500 $finish;
end

// ----------------------------------------------------------------------------
// Log the variables
// always @(posedge clk) begin
//   if(rst == 0) begin
//     // ... 
//   end
// end

// ----------------------------------------------------------------------------
// Simulation clock generator
always begin
  #1 clk = ~clk;
end

codec codec_inst(
  .clk(clk),
  .rst(rst),
  .LCH_DAC(testData),
  .RCH_DAC(testData),
  // .SDTI(SDTI),
  .PDN(PDN),
  .LRCK(LRCK),
  .BCLK(BCLK),
  .SDTO(SDTO),
  .MCLK(MCLK)
);

endmodule
