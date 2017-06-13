// ----------------------------------------------------------------------------
// 
// 
// ----------------------------------------------------------------------------
module uart_tx #(
  parameter CLKDIV = 128
)(
  input clk,
  input rst,
  input [7:0] txdata,
  input transmit,
  output tx_pin,
  output tx_busy
);

// ----------------------------------------------------------------------------
parameter WIDTH = $clog2(CLKDIV);
reg [(WIDTH-1):0] txcnt;

// ----------------------------------------------------------------------------
reg tx_busy_reg;
reg [3:0] bitcnt;
reg [10:0] txdata_latched;

// ----------------------------------------------------------------------------
// Main transmission process
// ----------------------------------------------------------------------------
always @(posedge clk) begin
  // --------------------------------------------------------------------------
  if(rst == 1) begin
    txcnt <= 0;
    bitcnt <= 4'b0;
    tx_busy_reg <= 1'b0;
  // --------------------------------------------------------------------------
  //
  // --------------------------------------------------------------------------
  end else if(bitcnt == 4'd0) begin
    if(transmit == 1) begin
      // LSB first format: 2 STOP bits + Actual Data + START bit
      txdata_latched <= {2'd3, txdata, 1'b0};
      tx_busy_reg <= 1'b1;
      bitcnt <= 1'b1;
      txcnt <= CLKDIV;
    end else begin
      tx_busy_reg <= 1'b0;
    end
  // --------------------------------------------------------------------------
  //
  // --------------------------------------------------------------------------
  end else if(txcnt) begin
    txcnt <= txcnt - 1;
  // --------------------------------------------------------------------------
  // 
  // --------------------------------------------------------------------------
  end else begin
    if(bitcnt == 4'd11) begin
      bitcnt <= 0;      
    end else begin
      bitcnt <= bitcnt + 1;
    end        
    txcnt <= CLKDIV;
    txdata_latched = {1'b1, txdata_latched[10:1]};
  end
end

// ----------------------------------------------------------------------------
assign tx_busy = tx_busy_reg;
assign tx_pin = txdata_latched[0];

endmodule
