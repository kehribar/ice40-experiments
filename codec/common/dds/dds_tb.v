// ----------------------------------------------------------------------------
// ...
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

// ----------------------------------------------------------------------------
module top_tb();

// ----------------------------------------------------------------------------
reg clk, rst;
reg [31:0] phaseInc;
wire signed [15:0] sin;
wire [1:0] quadSampleState;

// ----------------------------------------------------------------------------
// Initialize all variables and run the test
initial begin
  $dumpfile("dds_tb.vcd");
  clk <= 1;
  rst <= 1;
  phaseInc <= 32'd2000000;
  #50 rst <= 0;
  #25000 phaseInc <= 32'd4000000;  
  #25000 phaseInc <= 32'd90000000;  
  #25000 $finish;
end

// ----------------------------------------------------------------------------
// Log the variables
always @(posedge clk) begin
  if(rst == 0) begin
    $display("%g,%d,%d",$time,sin,quadSampleState);
  end
end

// ----------------------------------------------------------------------------
// Simulation clock generator
always begin
  #1 clk = ~clk;
end

// ----------------------------------------------------------------------------
// Connect DUT to test bench
dds dds_inst(
  .clk(clk),
  .rst(rst),
  .phaseInc(phaseInc),
  .sin(sin),
  .quadSampleState(quadSampleState)
);

endmodule
