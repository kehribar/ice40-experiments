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
  clockgen #()
  clockgen_inst(
    .clk(clk12),
    .clkout(clk60),
    .reset(rst)
  );

  // --------------------------------------------------------------------------
  uart_tx #(
    .CLKDIV(60)
  )
  uart_tx_inst(
    .clk(clk60),
    .rst(rst),
    .txdata(test_char),
    .tx_start(tx_start),
    .tx_pin(TX_reg),
    .tx_busy(tx_busy)
  );

  // --------------------------------------------------------------------------
  uart_rx #(
    .CLKDIV(60)
  )
  uart_rx_inst(
    .clk(clk60),
    .rst(rst),
    .rxdata(test_char),
    .rx_pin(RX),
    .rxvalid(rxvalid),
    .rxack(rxack)
  );  

  // --------------------------------------------------------------------------
  assign tx_start = rxvalid;
  assign rxack = tx_busy & rxvalid;
  
  // --------------------------------------------------------------------------
  assign {DBG0, DBG1, DBG2, DBG3, DBG4, DBG5, DBG6, DBG7} = {debugSignals};
  assign {LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7} = {debugSignals};
  assign debugSignals = {RX, TX_reg, 1'b0, rxack, tx_start, 1'b1, 1'b1, 1'b1};  

  // --------------------------------------------------------------------------
  assign TX = TX_reg;

endmodule
