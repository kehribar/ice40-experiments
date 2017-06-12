// ----------------------------------------------------------------------------
// 
// 
// ----------------------------------------------------------------------------
// <ihsan@kehribar.me> - 2017
// ----------------------------------------------------------------------------
module top(
  input clk12,
  output LED0,
  output LED1,
  output LED2,
  output LED3,
  output LED4,
  output LED5,
  output LED6,
  output LED7,
  input RX,
  output TX  
);

  // --------------------------------------------------------------------------
  reg rst;
  reg clk60;
  reg clken;
  reg tx_reg;
  reg tx_busy;
  reg tx_start;
  reg tx_busy_d;
  reg [7:0] test_char;

  // --------------------------------------------------------------------------
  clockgen #()
  clockgen_inst(
    .clk(clk12),
    .clkout(clk60),
    .reset(rst)
  );
  
  // --------------------------------------------------------------------------
  always @(posedge clk60) begin
    if(rst == 1) begin   
      tx_start <= 1'b1;
      tx_busy_d <= 1'b1;
      test_char <= 8'b0;
    end else begin    
      if((tx_busy == 1'b0)&&(tx_busy_d == 1'b1)) begin
        test_char <= test_char + 1;
        tx_start <= 1'b1;              
      end else begin
        tx_start <= 1'b0;     
      end
      tx_busy_d <= tx_busy;
    end
  end

  // --------------------------------------------------------------------------
  clken_gen #(
    .DIV_RATIO(60-1) // (60MHz / 1MBaud) = 60
  )
  clken_gen_inst(
    .clk(clk60),
    .rst(rst),
    .clken(clken)
  );

  // --------------------------------------------------------------------------
  uart_tx #()
  uart_inst(
    .clk(clk60),
    .en(clken),
    .rst(rst),
    .txdata(test_char),
    .transmit(tx_start),
    .tx_pin(tx_reg),
    .tx_busy(tx_busy)
  );

  // --------------------------------------------------------------------------
  assign TX = tx_reg;
  assign {LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7} = {8{test_char}};

endmodule
