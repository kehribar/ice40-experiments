// ----------------------------------------------------------------------------
// Objective of this example is to demonstrate relatively complex instantiation
// structures with multiple files and directories.
// ----------------------------------------------------------------------------
// <ihsan@kehribar.me> - 2017
// ----------------------------------------------------------------------------
module top (
  input  clk12,
  output LED0,
  output LED1,
  output LED2,
  output LED3,
  output LED4,
  output LED5,
  output LED6,
  output LED7,  
);

  wire rst;
  wire clk60;
  wire [7:0] counter;

  clockgen #()
  clockgen_inst(
    .clk(clk12),
    .clkout(clk60),
    .reset(rst)
  );

  higherlevel #()
  higherlevel_inst(
    .clk(clk60),
    .rst(rst),
    .counter_out(counter)
  );

  assign {LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7} = counter;

endmodule
