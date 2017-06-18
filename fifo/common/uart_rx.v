// ----------------------------------------------------------------------------
// 
// 
// ----------------------------------------------------------------------------
module uart_rx #(
  parameter CLKDIV = 128
)(
  input clk,
  input rst,
  input rx_pin,
  output [7:0] rxdata,
  output rxvalid,
  input rxack  
);

// ----------------------------------------------------------------------------
localparam integer HALF_PERIOD = CLKDIV/2;
reg [$clog2(3*HALF_PERIOD):0] rxcnt;

// ----------------------------------------------------------------------------
reg rx_pin_d;
reg rx_busy_reg;
reg [3:0] bitcnt;
reg [7:0] rxdata_reg;

// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
always @(posedge clk) begin
  // --------------------------------------------------------------------------
  if(rst == 1) begin
    rxcnt <= 0;
    bitcnt <= 0;
    rxdata <= 0;
    rx_pin_d <= 0;
    rxdata_reg <= 0;
    rx_busy_reg <= 0;
    rxvalid <= 0;
  // --------------------------------------------------------------------------
  //
  // --------------------------------------------------------------------------
  end else if(!rx_busy_reg) begin        
    if((rx_pin == 0)&&(rx_pin_d == 1)) begin
      bitcnt <= 8;
      rxdata_reg <= 0;
      rx_busy_reg <= 1;
      rxcnt <= ((3*HALF_PERIOD)-1);    
    end
    rx_pin_d <= rx_pin;
    if(rxack) begin
      rxvalid <= 0;  
    end
  // --------------------------------------------------------------------------
  //
  // --------------------------------------------------------------------------
  end else if(rxcnt) begin
    rxcnt <= rxcnt - 1;
  // --------------------------------------------------------------------------
  // 
  // --------------------------------------------------------------------------
  end else begin
    rxcnt <= (CLKDIV-1);
    if(bitcnt == 0) begin
      rxvalid <= 1;
      rx_busy_reg <= 0;
      rxdata <= rxdata_reg;
    end else begin
      bitcnt <= bitcnt - 1;      
      rxdata_reg = {rx_pin, rxdata_reg[7:1]};
    end            
  end
end

endmodule
