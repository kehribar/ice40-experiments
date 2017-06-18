// ----------------------------------------------------------------------------
// 
// 
// ----------------------------------------------------------------------------
// <ihsan@kehribar.me> - 2017
// ----------------------------------------------------------------------------
module top
(
  // --------------------------------------------------------------------------
  input clk12,
  output LED0,
  output LED1,
  output LED2,
  output LED3,
  output LED4,
  output LED5,
  output LED6,
  output LED7,
  // --------------------------------------------------------------------------
  output DBG0,
  output DBG1,
  output DBG2,
  output DBG3,
  output DBG4,
  output DBG5,
  output DBG6,
  output DBG7,
  // --------------------------------------------------------------------------
  input RX,
  output TX  
);

  // --------------------------------------------------------------------------
  reg TX_reg;
  reg fifo_full;
  reg fifo_empty;

  // --------------------------------------------------------------------------
  wire rst;
  wire clk60;
  wire rxack;
  wire tx_busy;
  wire rxvalid;
  wire tx_start;
  wire [7:0] test_char;
  wire [7:0] debugSignals;

  // --------------------------------------------------------------------------
  reg [8:0] used_slots;
  reg [8:0] free_slots;
  reg [7:0] fifo_din;
  reg [7:0] fifo_dout;
  reg fifo_shift_in;
  reg fifo_shift_out;

  // --------------------------------------------------------------------------
  clockgen #()
  clockgen_inst(
    .clk(clk12),
    .clkout(clk60),
    .reset(rst)
  );

  // --------------------------------------------------------------------------
  uart_tx #(
    .CLKDIV(15)
  )
  uart_tx_inst(
    .clk(clk60),
    .rst(rst),
    .txdata(fifo_dout),
    .tx_start(tx_start),
    .tx_pin(TX_reg),
    .tx_busy(tx_busy)
  );

  // --------------------------------------------------------------------------
  uart_rx #(
    .CLKDIV(15)
  )
  uart_rx_inst(
    .clk(clk60),
    .rst(rst),
    .rxdata(fifo_din),
    .rx_pin(RX),
    .rxvalid(rxvalid),
    .rxack(rxack)
  );  

  // --------------------------------------------------------------------------
  fifo #()
  fifo_inst(
    .clk(clk60),
    .resetn(!rst),
    .din(fifo_din),
    .dout(fifo_dout),
    .shift_in(fifo_shift_in),
    .shift_out(fifo_shift_out),
    .used_slots(used_slots),
    .free_slots(free_slots),
  );

  // --------------------------------------------------------------------------
  assign fifo_shift_in = rxvalid & rxack;
  assign fifo_shift_out = tx_start & (!tx_busy);

  // --------------------------------------------------------------------------
  always @(posedge clk60) begin
    if(rst) begin
      rxack <= 0;
      tx_start <= 0;
    end else begin
      // ----------------------------------------------------------------------
      if(used_slots != 9'b0) begin
        tx_start <= 1;        
      end else begin
        tx_start <= 0;        
      end    
      // ----------------------------------------------------------------------
      if(rxvalid & (free_slots != 9'b0)) begin
        rxack <= 1;        
      end else begin
        rxack <= 0;        
      end    
      // ----------------------------------------------------------------------
    end
  end

  // --------------------------------------------------------------------------
  assign {DBG0, DBG1, DBG2, DBG3, DBG4, DBG5, DBG6, DBG7} = {debugSignals};
  assign {LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7} = {debugSignals};
  assign debugSignals = {RX, TX_reg, rxack, tx_start, fifo_shift_in, fifo_shift_out, 1'b0, rst};  

  // --------------------------------------------------------------------------
  assign TX = TX_reg;

endmodule
