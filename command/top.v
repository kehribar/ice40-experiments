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
  wire txBusy;
  wire rxValid;
  wire txSend;
  wire [7:0] debugSignals;

  // --------------------------------------------------------------------------
  wire we;
  wire [6:0] addr;
  reg [31:0] rdat;
  wire [31:0] wdat;
  reg [7:0] rxData;
  reg [7:0] txData;

  // --------------------------------------------------------------------------
  reg [31:0] tmp32;
  wire rxack;

  // --------------------------------------------------------------------------
  clockgen #()
  clockgen_inst(
    .clk(clk12),
    .clkout(clk60),
    .reset(rst)
  );

  // --------------------------------------------------------------------------
  uart_tx #(
    .CLKDIV(12)
  )
  uart_tx_inst(
    .clk(clk12),
    .rst(rst),
    .txdata(txData),
    .tx_start(txSend),
    .tx_pin(TX_reg),
    .tx_busy(txBusy)
  );

  // --------------------------------------------------------------------------
  uart_rx #(
    .CLKDIV(12)
  )
  uart_rx_inst(
    .clk(clk12),
    .rst(rst),
    .rxdata(rxData),
    .rx_pin(RX),
    .rxvalid(rxValid),
    .rxack(rxack)
  );  

  // ----------------------------------------------------------------------------
  always @(*) begin
    case(addr)
      7'h0F: rdat = tmp32 + 'hFF;
      default: rdat = 32'hDEADC0DE;
    endcase
  end

  // ----------------------------------------------------------------------------
  always @(posedge clk12) begin
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
    .clk(clk12),
    .rst(rst),
    .rxData(rxData),
    .txData(txData),
    .txSend(txSend),
    .rxValid(rxValid),
    .txBusy(txBusy),
    .we(we),
    .addr(addr),
    .rdat(rdat),
    .wdat(wdat),
    .rxack(rxack)
  );

  // --------------------------------------------------------------------------
  assign {DBG0, DBG1, DBG2, DBG3, DBG4, DBG5, DBG6, DBG7} = {debugSignals};
  assign {LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7} = {debugSignals};
  assign debugSignals = {RX, TX_reg, we, txSend, txBusy, rxValid, rxack, clk12};  

  // --------------------------------------------------------------------------
  assign TX = TX_reg;

endmodule
