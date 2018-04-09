
module keyboardhero
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
	
	//These hex_decoders are for the score value HEX0 represent the lower and HEX1 represent higher
	 
	hex_decoder SCORE0(
        .hex_digit(score[3:0]), 
        .segments(HEX0)
        );
        
   hex_decoder SCORE1(
        .hex_digit(score[7:4]), 
        .segments(HEX1)
        );
	//These hex_decoders are for the combo value HEX0 represent the lower and HEX1 represent higher 	  
	hex_decoder COMBO2(
        .hex_digit(combo[3:0]), 
        .segments(HEX2)
        );
   hex_decoder COMBO3(
        .hex_digit(combo[7:4]), 
        .segments(HEX3)
        );

	wire key3, key2, key1;
	wire [7:0] score;
	wire [7:0] combo;
	assign key3 = KEY[3];
	assign key2 = KEY[2];
	assign key1 = KEY[1];
	
	// Instansiate datapath
	keyboard_hero display(.clk(draw_clock), .resetn(resetn), .key3(key3), .key2(key2), .key1(key1), .x(x), .y(y), .colour(colour), .score(score), .combo(combo));
	// Taken from https://github.com/choyiny/FPGANoTatsujin/blob/master/components/rate_divider.v
	rate_divider drawing_clock(CLOCK_50, 28'b011, draw_clock, 1'b1);
    
endmodule

module keyboard_hero(
    input clk,
	 input resetn,
	 input key3, 
	 input key2,
	 input key1,
	 output reg [2:0] colour,
	 output reg [7:0] score,
	 output reg [7:0] combo,
	 output reg [7:0] x,
	 output reg [6:0] y
    ); 	
	// input registers
   reg [7:0] x_pos;
	reg [7:0] x_right;
	reg [7:0] x_middle;
	reg [6:0] y_pos;
	
	reg [27:0] counter;
	reg [27:0] counter2;
	
   // output
   reg [7:0] x_alu;
	reg [6:0] y_alu;
	reg [4:0] count;
	reg [4:0] clear;
	reg [4:0] draw;
	
	// different falling blocks x and y registers
	reg [7:0] x_2;
	reg [6:0] y_2;
	reg [7:0] x_3;
	reg [6:0] y_3;
	reg [7:0] x_4;
	reg [6:0] y_4;
	reg [7:0] x_5;
	reg [1:0] y_2en = 1'b0;
	reg [1:0] y_3en = 1'b0;
	reg [1:0] y_4en = 1'b0;
	reg [6:0] state = 7'd0;
	
	//this will allow the blocks to fall down to create a random sequence of blocks
	//random1 y2 (drawclk, y_2en);
	//random1 y3 (drawclk, y_3en);
	//random1 y4 (drawclk, y_4en);
	
	always@(posedge clk) begin
		 // if reset is pressed score and combo starts at 0
	    if(!resetn) begin
			  state <= 0;
			  score <= 0;
			  combo <= 0;
       end
		 
		 //initial state to determine the x pos for the key pos
		 else if (state == 0) begin 
			if (~key3) begin
				 x_pos <= 60;
				 //if the y_pos of the keyblock matches the y pos of the first block add point
				 if(x_pos <= x_2 && y_pos <= y_2) begin
					score <= score + 1;
					combo <= combo + 1;
							
				 end
				 //otherwise combo starts back at 0
				 else begin
					 combo <= 0;
				 end
			end
		   if(~key2) begin
				  x_pos <= 70;
				  //if the y_pos of the keyblock matches the y pos of the second block add point
				  if(x_pos <= x_4 && y_pos <= y_4) begin
				     score <= score + 1;
					  combo <= combo + 1;
				  end
				  //otherwise combo starts back at 0
				  else begin
				      combo <= 0;
				  end
			end	
			if(~key1) begin
				 x_pos <= 80;
				 //if the y_pos of the keyblock matches the y pos of the third block add point
				 if(x_pos <= x_3 && y_pos <= y_3) begin
					 score <= score + 1;
					 combo <= combo + 1;
				 end
				  //otherwise combo starts back at 0
				 else begin
					 combo <= 0;
				 end
			end
			//initial y pos and state move
			y_pos <= 110;
			state <= 1;
		  end
		// state for drawing the keypos
		else if(state == 4'd1) begin
					y <= y_pos;
					x <= x_pos;
					colour <= 3'b111;
					
					state <= 2;
					clear <=1;
			  end
		//state for x initial pos of the block falling down and movement of y block
		else if(state == 4'd2) begin
					
					

					if(x_2 <= 0) begin
						x_2 <= 60;
					 end

					 if(x_3 <= 0) begin
						x_3 <= 70;
						y_3 <= 70;
					 end
	
					 if(x_4 <= 0) begin
						x_4 <= 80;
						y_4 <= 80;
					 end
					 // move y block by 1 if the y2en is enabled from random generator
					 
					 //if(y_2en == 1'b1)begin
						y_2 <= y_2 + 1;
					 //end
					 //if(y_3en == 1'b1)begin
						y_3 <= y_3 + 1;
					 //end
					 //if(y_2en == 1'b1)begin
						y_4 <= y_4 + 1;
					 //end
					 draw <= 1;
					 state <= 4;
			  end
		
		//this state is for reseting the blocks after reached the bottom
		else if(state == 4'd3) begin
			

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
		
					state <= 0;
					
			  end

		 //this is for drawing the blocks falling down and erasing them
		 //this was taken from https://github.com/nathan78906/CaveCatchers/blob/master/cavecatchers.v
		 else begin
			
			
			
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
		
			  else if(clear == 4'd3) begin
			  
			  
					x <= x_4;
					y <= y_4;
					clear <= 0;
			  end
			  
			  if(draw == 4'd1) begin
					x <= x_2;
					y <= y_2;
				

					colour <= 3'b111;
					draw <= 2;
			  
			  end

		
			  else if(draw == 4'd2) begin
			  
					x <= x_3;
					y <= y_3;
				

					colour <= 3'b111;
					draw <= 3;
			  end
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

// This is the random generator taken from https://github.com/bryanlimy/flappybird-verilog/blob/master/background.v
module random1(ccc, height);
  input ccc;
  output reg [1:0] height;
  

  reg [0:3] fib = 4'b1111;

  always @ ( posedge ccc )
    fib <= {fib[3]^fib[2], fib[0:2]};

  always begin
    case (fib)
      0 : height <= 1'b1;
      1 : height <= 1'b0;
      2 : height <= 1'b1;
      3 : height <= 1'b0;
      4 : height <= 1'b1;
      5 : height <= 1'b0;
      6 : height <= 1'b1;
      7 : height <= 1'b0;
      8 : height <= 1'b1;
      9 : height <= 1'b0;
      10 : height <= 1'b1;
      11 : height <= 1'b0;
      12 : height <= 1'b1;
      13 : height <= 1'b0;
      14 : height <= 1'b1;
      15 : height <= 1'b0;
    endcase
  end
endmodule


//rate divider module taken from https://github.com/choyiny/FPGANoTatsujin/blob/master/components/rate_divider.v
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
          stored_value <= divide_by;
        end
      // decrement by 1 if stored value is not 0
      else
          stored_value <= stored_value - 1'b1;
    end
endmodule
