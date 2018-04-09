
module KeyBoardHero
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		HEX0, 
		HEX1,
		HEX2,
		HEX3
		
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	
	wire increment_counter;
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial ground
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "backimg.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	wire [6:0] datain;
	wire load_x, load_y, load_r, load_c, ld_alu_out;
	wire go, loadEn;
	
	wire left, right, middle;
	
	assign left = KEY[3];
	assign middle = KEY[2];
	assign right = KEY[1];
	
	datapath d1(draw_clock, resetn, middle, left, right, x, y, colour, data_result, combo_result);
	rate_divider drawing_clock(CLOCK_50, 28'b0000000000000000000000000011, draw_clock, 1'b1);

	
	wire [7:0] data_result;
	wire [7:0] combo_result;

	hex_decoder H0(
        .hex_digit(data_result[3:0]), 
        .segments(HEX0)
        );
        
    hex_decoder H1(
        .hex_digit(data_result[7:4]), 
        .segments(HEX1)
        );
	hex_decoder H2(
        .hex_digit(combo_result[3:0]), 
        .segments(HEX2)
        );
        
    hex_decoder H3(
        .hex_digit(combo_result[7:4]), 
        .segments(HEX3)
        );


    
endmodule

module counter_5bit(Q_OUT, EN, CLK, CLR);
	output reg [4:0] Q_OUT;
	input CLK, CLR, EN;

	always @(posedge CLK)
	begin
		if (EN == 1'b1 | CLR == 1'b1)
		begin
//		Q_OUT <= CLR == 1'b1 or Q_OUT = 1'b1111 ? 0 : Q_OUT + 1'b1;
			if (CLR == 1'b1 | Q_OUT == 5'b11111)
				Q_OUT[4:0] <= 0;
			else if (CLK == 1'b1)
			   Q_OUT[4:0] <= Q_OUT[4:0] + 5'b00001;
		end
	end
endmodule

module datapath(
    input clk,
	 input resetn,
	 input middle, 
	 input left,
	 input right,
    output reg [7:0] x,
	 output reg [6:0] y,
	 output reg [2:0] colour,
	 output reg [7:0] data_result,
	 output reg [7:0] combo_result
    ); 	
	reg [4:0] bool;
	 
   reg [7:0] x_pos;
	reg [6:0] y_pos;
	
	reg [27:0] counter;
	reg [27:0] counter2;

   reg [7:0] x_alu;
	reg [6:0] y_alu;
	reg[4:0] count;
	reg[4:0] clear;
	reg[4:0] draw;
	
	reg [7:0] x_2;
	reg [6:0] y_2;
	reg [7:0] x_3;
	reg [6:0] y_3;
	reg [7:0] x_4;
	reg [6:0] y_4;

	
	always@(posedge clk) begin
	    if(!resetn) begin
			  bool <= 4'd0;
			  data_result <= 0;
			  combo_result <= 0;
       end
		 else if (counter == 28'd50000) begin 
			  if (bool == 4'd0) begin 
					if(count == 4'd2) begin
								
						if (~left) begin
							x_pos <= 60;
							if(x_pos <= x_2 && y_pos <= y_2) begin
								data_result <= data_result + 1;
								combo_result <= combo_result + 1;
							
							end
							else begin
								combo_result <= 0;
	
							end
					
						
						end 
						if(~right) begin
							x_pos <= 80;
								if(x_pos <= x_3 && y_pos <= y_3) begin
									data_result <= data_result + 1;
									combo_result <= combo_result + 1;
									
								end
								else begin
									combo_result <= 0;
									
								end
							
						end
						
						if(~middle) begin
							x_pos <= 70;
								
								if(x_pos <= x_4 && y_pos <= y_4) begin
									data_result <= data_result + 1;
									combo_result <= combo_result + 1;
									
								end
								else begin
									combo_result <= 0;
								end
						end
						count <= 4'd0;
					end

					y_pos <= 100;
					bool <= 1;
			  end
			 
			  else if(bool == 4'b1) begin
					y <= y_pos;
					x <= x_pos;
					colour <= 3'b111;
					
					bool <= 3;
					clear <=1;
			  end
			
			  else if (bool == 4'd4) begin
				
					bool <= 5;
			  end
			 
			  else if(bool == 4'd10) begin
			  
			  
					bool <= 2;
			  end
			  
			 
			
			  else if(bool == 4'd9) begin
			

					if(y_2 == 120) begin
					
						x_2 <= 60;
						y_2 <= 0;
					end
					
					else if(y_3 == 120) begin

				
						
						x_3 <= 70;
						
						y_3 <= 0;

					end
					
					else if(y_4 == 120) begin
	
						x_4 <= 80;
						
						y_4 <= 0;
					
					end 
		
					bool <= 0;
					
			  end
			
			  else if(bool == 4'd5) begin
				

					bool <= 6;
			  end 
		
			  else if(bool == 4'd3) begin
					
					

					if(x_2 <= 0) begin
						x_2 <= 60;
					 end

					 if(x_3 <= 0) begin
						x_3 <= 70;
						y_3 <= 90;
					 end
	
					 if(x_4 <= 0) begin
						x_4 <= 80;
						y_4 <= 100;
					 end
					 
					 y_2 <= y_2 + 1;
					 y_3 <= y_3 + 1;
					 y_4 <= y_4 + 1;
					 
					 draw <= 1;
					 bool <= 4;
			  end
	
			  else if (bool == 4'd2)begin

					x <= x_pos;
					y <= y_pos;
					colour <=3'b111;
					
					bool <= 9;
			  end
		
			  else if (bool == 4'd6) begin
					
					 
					 
					 bool <= 7;
			  
			  end

			  else if (bool == 4'd7) begin
					bool <= 8;
			  end
			 
			  else if (bool == 4'd8) begin
				
					bool <= 2;
			  end
			  
			  
			 
			  
			  
			  counter <= 28'd0;
			  
			  
			  count <= count + 1;

	    end
		 
		 else begin
			
		 	counter <= counter + 1;
			
			
			 if(clear == 4'd1) begin
			  
			  
					x <= x_2;
					y <= y_2;
					
					colour <= 1'b000;
					clear <= 2;
			  end
			
			  else if(clear == 4'd2) begin
			  
			  
					x <= x_3;
					y <= y_3;
					clear <= 3;
			  end
			  // if clear = 3, signal for erasing the 3rd falling block
			  else if(clear == 4'd3) begin
			  
			  
					x <= x_4;
					y <= y_4;
					clear <= 0;
			  end
			  
			  
			  // if draw = 1, draw the 1st falling block
			  if(draw == 4'd1) begin
					x <= x_2;
					y <= y_2;
				

					colour <= 3'b111;
					draw <= 2;
			  
			  end

			  // if draw = 2, draw the 2nd falling block
			  else if(draw == 4'd2) begin
			  
					x <= x_3;
					y <= y_3;
				

					colour <= 3'b111;
					draw <= 3;
			  end
			  // if draw = 3, draw the 3rd falling block
			  else if(draw == 4'd3) begin
			  
					x <= x_4;
					y <= y_4;
				

					colour <= 3'b111;
					draw <= 0;
			  end
	    end
end
endmodule

// hex display
module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule

module rate_divider(clock, divide_by, out_signal, reset_b);
  reg [27:0] stored_value;
  input reset_b;
  output out_signal;

  input [27:0] divide_by; // 28 bit
  input clock;

  assign out_signal = (stored_value == 1'b0);

  // begin always block
  always @ (posedge clock)
    begin
      // reset
      if (reset_b == 1'b0) begin
          stored_value <= 0;
	      end
      // stored value is 0
      else if (stored_value == 1'b0)
        begin
          // 28'b1011111010111100001000000000; | 200 million
          // 28'b0101111101011110000100000000; | 100 million
          // 28'b0010111110101111000010000000; | 50 million
          // 28'b0000000000000000000000010000; | 16
          stored_value <= divide_by;
        end
      // decrement by 1 if stored value is not 0
      else
          stored_value <= stored_value - 1'b1;
    end
endmodule