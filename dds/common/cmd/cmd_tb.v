// ----------------------------------------------------------------------------
// ...
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

// ----------------------------------------------------------------------------
module top_tb();

// ----------------------------------------------------------------------------
reg clk, rst;

// ----------------------------------------------------------------------------
wire we;
wire [6:0] addr;
reg [31:0] rdat;
wire [31:0] wdat;

// ----------------------------------------------------------------------------
wire txBusy;
reg rxValid;
wire txSend;
wire [7:0] txData;
reg [7:0] rxData;

// ----------------------------------------------------------------------------
wire TX_reg;
reg TX_pin;
reg [31:0] tmp32;

// ----------------------------------------------------------------------------
// Initialize all variables and run the test
initial begin
  $dumpfile("cmd_tb.vcd");
  $dumpvars(0, cmd_inst);
  $dumpvars(0, uart_tx_inst);
  rxValid <= 0;
  clk <= 1;
  rst <= 1;  
  #50 rst <= 0;
  #10 rxData <= 8'h7f;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #5 rxData <= 8'h99;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #5 rxData <= 8'h55;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #5 rxData <= 8'hAA;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #5 rxData <= 8'h00;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #10 rxData <= 8'h8f;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #250 rxData <= 8'h7f;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #5 rxData <= 8'h99;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #5 rxData <= 8'h55;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #5 rxData <= 8'hAA;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #5 rxData <= 8'h00;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #10 rxData <= 8'h8f;
  #2 rxValid <= 1;
  #2 rxValid <= 0;
  #250 $finish;
end

// ----------------------------------------------------------------------------
// Log the variables
always @(posedge clk) begin
  if(rst == 0) begin
    $display("%g, %d, %d",$time, rxValid, rxData);
    TX_pin <= TX_reg;
  end
end

// ----------------------------------------------------------------------------
// Simulation clock generator
always begin
  #1 clk = ~clk;
end

// ----------------------------------------------------------------------------
always @(*) begin
  case(addr)
    7'h0F: rdat = tmp32 + 'hFF;
    default: rdat = 32'd0;
  endcase
end

// ----------------------------------------------------------------------------
always @(posedge clk) begin
  if(rst) begin
    tmp32 <= 0;
  end else begin
    if(we) begin
      case(addr)
        7'h7F: tmp32 <= wdat;
      endcase
    end
  end
end

// ----------------------------------------------------------------------------
// Connect DUT to test bench
cmd cmd_inst(
  .clk(clk),
  .rst(rst),
  .rxData(rxData),
  .txData(txData),
  .txSend(txSend),
  .rxValid(rxValid),
  .txBusy(txBusy),
  .we(we),
  .addr(addr),
  .rdat(rdat),
  .wdat(wdat)
);

// --------------------------------------------------------------------------
uart_tx #(
  .CLKDIV(1)
)
uart_tx_inst(
  .clk(clk),
  .rst(rst),
  .txdata(txData),
  .tx_start(txSend),
  .tx_pin(TX_reg),
  .tx_busy(txBusy)
);

endmodule
