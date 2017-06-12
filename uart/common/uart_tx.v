// ----------------------------------------------------------------------------
// 
// 
// ----------------------------------------------------------------------------
module uart_tx(
  input clk,
  input en,
  input rst,
  input [7:0] txdata,
  input transmit,
  output tx_pin,
  output tx_busy
);

// ----------------------------------------------------------------------------
reg tx_busy_reg;
reg [3:0] bitcnt;
reg [10:0] txdata_latched;

// ----------------------------------------------------------------------------
// Main transmission process
// ----------------------------------------------------------------------------
always @(posedge clk) begin
  if(rst == 1) begin
    bitcnt <= 4'd0;
    tx_busy_reg <= 1'b0;
  // --------------------------------------------------------------------------
  // Wait for transmit signal at IDLE state with high frequency
  // --------------------------------------------------------------------------
  end else if(bitcnt == 4'd0) begin
    if(transmit == 1) begin
      // LSB first format: 2 STOP bits + Actual Data + START bit
      txdata_latched <= {2'd3, txdata, 1'b0};
      tx_busy_reg <= 1'b1;
      bitcnt <= 1'b1;
    end else begin
      tx_busy_reg <= 1'b0;
    end
  // --------------------------------------------------------------------------
  // Shift the register bit by bit with baudrate enable pulse
  // --------------------------------------------------------------------------
  end else if(en) begin
    if(bitcnt == 4'd11) begin
      bitcnt <= 0;      
    end else begin
      bitcnt <= bitcnt + 1;
    end          
    txdata_latched = {1'b1, txdata_latched[10:1]};
  end
end

// ----------------------------------------------------------------------------
assign tx_busy = tx_busy_reg;
assign tx_pin = txdata_latched[0];

endmodule
