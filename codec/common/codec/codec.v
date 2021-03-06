// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// * ADC data is left adjusted.
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
  output reg [23:0] LCH_ADC,
  output reg [23:0] RCH_ADC,
  output reg        ADC_Update,
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
reg [1:0] bclk_cnt;
reg [7:0] lrck_cnt;
reg [15:0] pdn_cnt;

// ----------------------------------------------------------------------------
reg [63:0] adcRegister;
reg [63:0] dacRegister;

// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
always @(posedge clk) begin
  if(rst == 1) begin
    PDN <= 0;
    MCLK <= 0;
    LRCK <= 0;
    BCLK <= 1;
    LCH_ADC <= 0;
    RCH_ADC <= 0;
    lrck_cnt <= 0;
    bclk_cnt <= 0;    
    ADC_Update <= 0;
    dacRegister <= 0;
    adcRegister <= 0;
    pdn_cnt <= 16'hFFFF;
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
        bclk_cnt <= 2'd2;

        if(BCLK) begin        
          if(!lrck_cnt & !LRCK) begin          
            dacRegister[23:00] <= LCH_DAC;
            dacRegister[55:32] <= RCH_DAC;            
            RCH_ADC <= adcRegister[63:40];
            LCH_ADC <= adcRegister[31:08];
            ADC_Update <= 1;      
          end else begin
            ADC_Update <= 0;      
            dacRegister <= {dacRegister[62:0], 1'b0};         
          end
        end

        if(!BCLK) begin  
          adcRegister <= {adcRegister[62:0], SDTI};    
        end
      
      // -----------------------------------------------------------------------
      end else begin
        bclk_cnt <= bclk_cnt - 1;      
      end
    
    // ------------------------------------------------------------------------
    end else begin
      pdn_cnt <= pdn_cnt - 1;
    end
  end
end

// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
assign SDTO = dacRegister[63];

endmodule