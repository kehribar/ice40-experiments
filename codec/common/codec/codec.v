// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// * ADC is not yet implemented.
// * DAC data is right adjusted.
// * Frequency ratios between generated clocks:
//     MCLK: clk  / 2
//     BCLK: MCLK / 3
//     LRCK: MCLK / 192
// ----------------------------------------------------------------------------
module codec(
  // -------------------------------------------------------------------------- 
  input clk,
  input rst,
  // --------------------------------------------------------------------------
  input [23:0] LCH_DAC,
  input [23:0] RCH_DAC,
  // --------------------------------------------------------------------------
  output reg PDN,
  output reg LRCK,
  output reg BCLK,
  output     SDTO,
  input      SDTI,
  output reg MCLK
  // --------------------------------------------------------------------------  
);

// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
reg BCLK_d;
reg [1:0] bclk_cnt;
reg [7:0] lrck_cnt;
reg [15:0] pdn_cnt;
reg [31:0] dacRegister;
reg [23:0] LCH_DAC_latched;
reg [23:0] RCH_DAC_latched;

// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
always @(posedge clk) begin
  if(rst == 1) begin
    PDN <= 0;
    MCLK <= 0;
    LRCK <= 0;
    BCLK <= 0;
    BCLK_d <= 0;    
    lrck_cnt <= 0;
    bclk_cnt <= 0;    
    pdn_cnt <= 16'hFFFF;
    dacRegister <= 0;
  end else begin

    // ------------------------------------------------------------------------
    // Wait for initial power down pulse ...
    // ------------------------------------------------------------------------    
    if(!pdn_cnt) begin
      PDN <= 1;

      // ----------------------------------------------------------------------
      // Generate master clock
      // ----------------------------------------------------------------------
      MCLK <= !MCLK;

      // ----------------------------------------------------------------------
      // Generate f_sampling clock
      // ----------------------------------------------------------------------
      if(!lrck_cnt) begin
        LRCK <= !LRCK;
        lrck_cnt <= 8'd191;        
      end else begin
        lrck_cnt <= lrck_cnt - 1;      
      end

      // ----------------------------------------------------------------------
      // Generate bit clock and shift data in / out
      // ----------------------------------------------------------------------      
      if(!bclk_cnt) begin
        BCLK <= !BCLK;
        BCLK_d <= BCLK;
        bclk_cnt <= 2'd2;
        if(BCLK_d & !BCLK) begin
          if(!lrck_cnt) begin        
            LCH_DAC_latched <= LCH_DAC;
            RCH_DAC_latched <= RCH_DAC;
            if(LRCK) begin
              dacRegister[23:0] <= LCH_DAC_latched;
            end else begin
              dacRegister[23:0] <= RCH_DAC_latched;          
            end
          end else begin
            dacRegister <= {dacRegister[30:0], 1'b0};
          end
        end
      end else begin
        bclk_cnt <= bclk_cnt - 1;      
      end

    end else begin
      pdn_cnt <= pdn_cnt - 1;
    end
  end
end

// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
assign SDTO = dacRegister[31];

endmodule