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
  testData <= 24'hA5A5AF;
  #50 rst <= 0;
  #205000 $finish;
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

wire [23:0] adcVal;

codec codec_inst(
  .clk(clk),
  .rst(rst),
  .LCH_DAC(testData),
  .RCH_DAC(adcVal),
  .RCH_ADC(adcVal),
  .SDTI(1'b1),
  .PDN(PDN),
  .LRCK(LRCK),
  .BCLK(BCLK),
  .SDTO(SDTO),
  .MCLK(MCLK)
);

endmodule
