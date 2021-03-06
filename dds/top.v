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
  // --------------------------------------------------------------------------
  // output LED0,
  // output LED1,
  // output LED2,
  // output LED3,
  // output LED4,
  // output LED5,
  // output LED6,
  // output LED7,
  // --------------------------------------------------------------------------
  // output DBG0,
  // output DBG1,
  // output DBG2,
  // output DBG3,
  // output DBG4,
  // output DBG5,
  // output DBG6,
  // output DBG7,
  // --------------------------------------------------------------------------
  output DAC0,
  output DAC1,
  output DAC2,
  output DAC3,
  output DAC4,
  output DAC5,
  output DAC6,
  output DAC7,  
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
  wire [15:0] sin;
  wire [1:0] quadSampleState;
  reg [31:0] phaseInc;

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
    .txdata(txData),
    .tx_start(txSend),
    .tx_pin(TX_reg),
    .tx_busy(txBusy)
  );

  // --------------------------------------------------------------------------
  uart_rx #(
    .CLKDIV(60)
  )
  uart_rx_inst(
    .clk(clk60),
    .rst(rst),
    .rxdata(rxData),
    .rx_pin(RX),
    .rxvalid(rxValid),
    .rxack(rxack)
  );  

  // ----------------------------------------------------------------------------
  always @(*) begin
    case(addr)
      7'h01: rdat = phaseInc;
      7'h02: rdat = tmp32;
      default: rdat = 32'hDEADC0DE;
    endcase
  end

  // ----------------------------------------------------------------------------
  always @(posedge clk60) begin
    if(rst) begin
      phaseInc <= 32'd100000;
    end else begin
      if(we) begin
        case(addr)
          7'h01: phaseInc <= wdat;
          7'h02: tmp32 <= wdat;
        endcase
      end
    end
  end

  // ----------------------------------------------------------------------------
  dds dds_inst(
    .clk(clk60),
    .rst(rst),
    .phaseInc(phaseInc),
    .sin(sin),
    .quadSampleState(quadSampleState)
  );

  // ----------------------------------------------------------------------------
  cmd cmd_inst(
    .clk(clk60),
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
  assign {DAC7, DAC6, DAC5, DAC4, DAC3, DAC2, DAC1, DAC0} = {sin[15:8] + 8'h80};
  
  // --------------------------------------------------------------------------
  // assign {DBG0, DBG1, DBG2, DBG3, DBG4, DBG5, DBG6, DBG7} = {debugSignals};
  // assign {LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7} = {debugSignals};
  // assign debugSignals = {
  //   RX, TX_reg, we, txSend, txBusy, quadSampleState[0], 
  //   quadSampleState[1], clk12
  // };  

  // --------------------------------------------------------------------------
  assign TX = TX_reg;

endmodule
