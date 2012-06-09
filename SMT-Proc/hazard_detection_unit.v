/* hazard_detection_unit.v
* Author: Pravin P. Prabhu
* Last Revision: 1/5/11
* Abstract:
*	Contains all of the nightmarish logic for determining when the processor
* should stall, and how it should stall. You are not expected to understand this.
*/
module hazard_detection_unit	#(	parameter DATA_WIDTH=32,
									parameter ADDRESS_WIDTH=32,
									parameter REG_ADDR_WIDTH=5
							)
							(
								input i_Clk,
								input i_Reset_n,
							
								//==============================================
								// Info about processor's overall state
								input i_FlashLoader_Done,						// Whether the flashloader has completed operation yet or not
								input i_Done,										// Whether we have observed the 'done' signal or not
							
								//==============================================
								// Hazard in DECODE?
								input i_DEC_Uses_RS,								// DEC wants to use RS
								input [REG_ADDR_WIDTH-1:0] i_DEC_RS_Addr,		// RS request addr.
								input i_DEC_Uses_RT,								// DEC wants to use RT
								input [REG_ADDR_WIDTH-1:0] i_DEC_RT_Addr,		// RT request addr.
								input i_DEC_Branch_Instruction,						// There is a branch inst. in DEC.
								
								//===============================================
								// Feedback from IF
								input i_IF_Done,									// If IF's value has reached steady state
								
								// Feedback from EX
								input i_EX_Writes_Back,								// EX is valid for analysis
								input i_EX_Uses_Mem,
								input [REG_ADDR_WIDTH-1:0] i_EX_Write_Addr,							// What EX will write to
								input i_EX_Branch,									// If EX says we are branching
								input [ADDRESS_WIDTH-1:0] i_EX_Branch_Target,
								
								// Feedback from MEM
								input i_MEM_Uses_Mem,									// If it's a memop
								input i_MEM_Writes_Back,							// MEM is valid for analysis
								input [REG_ADDR_WIDTH-1:0] i_MEM_Write_Addr,			// What MEM will write to
								input i_MEM_Done,									// If MEM's value has reached steady state								
								
								
								// Feedback from WB
								input i_WB_Writes_Back,								// WB is valid for analysis
								input [REG_ADDR_WIDTH-1:0] i_WB_Write_Addr,							// What WB will write to

								//===============================================
								// Branch hazard handling
								output o_IF_Branch,
								output [ADDRESS_WIDTH-1:0] o_IF_Branch_Target,
								
								//===============================================
								// IFetch validation
								output reg o_IF_Stall,
								output o_IF_Smash,
								
								// DECODE validation
								output reg o_DEC_Stall,						// Causes decode stage to stall
								output reg o_DEC_Smash,							// Smashes out contents of decode stage
								
								// EX validation
								output reg o_EX_Stall,
								output reg o_EX_Smash,
								
								// MEM validation
								output reg o_MEM_Stall,
								output reg o_MEM_Smash,
								
								output reg o_WB_Stall,
								output reg o_WB_Smash
							);
	// Consts
	localparam FALSE = 1'b0;
	localparam TRUE = 1'b1;
	
		// Internal wiring
	wire Executing = i_FlashLoader_Done && !i_Done;			// If 1, then we are currently executing code.

			// Registers for latching branches during stall periods
	reg r_Branch_IF_Hazard_Smash;							// If 1, then we must smash the next inst coming out of IF -- there was a branch while it was busy.
	reg r_IF_Smash_Transient;
	reg r_IF_Load;
	reg [ADDRESS_WIDTH-1:0] r_IF_Load_Address;
	
		// Branch handling
	assign o_IF_Smash = (r_Branch_IF_Hazard_Smash || r_IF_Smash_Transient);
	assign o_IF_Branch = i_EX_Branch || r_IF_Load;
	assign o_IF_Branch_Target = i_EX_Branch ? i_EX_Branch_Target : r_IF_Load_Address;
	
		// Hazard prevention: Smash IF instructions that are partway
		// fetched as we recognize a branch. Stop the instruction that
		// will emerge from imem from propogating through the pipeline
		// erroneously.
	always @(posedge i_Clk or negedge i_Reset_n)
	begin
		if( !i_Reset_n )
		begin
			r_Branch_IF_Hazard_Smash <= FALSE;
		end
		else
		begin
			if( i_EX_Branch && !i_IF_Done )				// Hazard - if we had to branch during IMEM's busy period (likely), then record the smash request in this register. Smash inst upon it being ready.
			begin
				r_Branch_IF_Hazard_Smash <= TRUE;
			end
			else if( i_IF_Done && r_Branch_IF_Hazard_Smash )		// Inst from IMEM is now valid - we must smash it. Account for the smash on this cycle by pulling down reg'd smash signal.
			begin
				r_Branch_IF_Hazard_Smash <= FALSE;
			end
		end
	end

		// Hazard prevention: If we recognize a branch, but IF is stalling,
		// then we should record the branch and apply it as soon as IF is
		// done stalling.
	always @(posedge i_Clk or negedge i_Reset_n)
	begin
		if( !i_Reset_n )
		begin
			r_IF_Load <= FALSE;
			r_IF_Load_Address <= {ADDRESS_WIDTH{1'bx}};
		end
		else
		begin
			if( o_IF_Stall &&
				i_EX_Branch )
			begin
				// Branch during a stalling period. Hold on to the branch.
				r_IF_Load <= TRUE;
				r_IF_Load_Address <= i_EX_Branch_Target;
			end
			else if( r_IF_Load && 
					!o_IF_Stall )
			begin
				// Came out of the stall and we had a reg'd branch request. Clear it.
				r_IF_Load <= FALSE;
			end
		end
	end
	
	
	//=============================================
	// Validation
	
		// IF validation
	always @(*)
	begin
		o_IF_Stall <= FALSE;
		r_IF_Smash_Transient <= FALSE;
		
		// If flashloader is done, check for other conditions
		if( Executing )
		begin
			// If next stage is stalling, so is this stage
			if( o_DEC_Stall || !i_IF_Done )	// Also stall on IMEM's output being invalid
			begin
				o_IF_Stall <= TRUE;
			end
			
			// If branching, smash. If output of imem is invalid, smash.
			if( i_EX_Branch || !i_IF_Done )
			begin
				r_IF_Smash_Transient <= TRUE;
			end
		end
		else	// Flashloader not done
		begin
			o_IF_Stall <= TRUE;
			r_IF_Smash_Transient <= TRUE;
		end
	end

		// DEC validation
	always @(*)
	begin
		o_DEC_Stall <= FALSE;
		o_DEC_Smash <= FALSE;
		
		// If flash is done, check for other conditions
		if( Executing )
		begin
		
			// If we have a branch operation in DEC, then we have to keep waiting
			// until the delay slot inst has been successfully read from imem
			if( i_DEC_Branch_Instruction &&
				!i_IF_Done )
			begin
				o_DEC_Smash <= TRUE;	// Do not let the branch go to EX stage
				o_DEC_Stall <= TRUE;		// Hold inst. until IF is ready
			end
		
			// If we have to wait on MEM for decoding, then do so.
			// RS/RT requires waiting on DMEM op in EX
			if( (i_DEC_Uses_RS && 
				i_EX_Writes_Back && 
				i_EX_Uses_Mem && 
				(i_EX_Write_Addr == i_DEC_RS_Addr)) ||
				( i_DEC_Uses_RT && 
				i_EX_Writes_Back && 
				i_EX_Uses_Mem && 
				(i_EX_Write_Addr == i_DEC_RT_Addr) )
				)
			begin
				o_DEC_Smash <= TRUE;
				o_DEC_Stall <= TRUE;
			end

			// Stall if next stage is stalling
			if( o_EX_Stall )
				o_DEC_Stall <= TRUE;
		end
		else
		begin
			o_DEC_Stall <= TRUE;
			o_DEC_Smash <= TRUE;
		end
	end
	
		// EX validation
	always @(*)
	begin
		o_EX_Stall <= FALSE;
		o_EX_Smash <= FALSE;
		
		if( Executing )
		begin
			if( o_MEM_Stall )
				o_EX_Stall <= TRUE;
		end
		else
		begin
			o_EX_Stall <= TRUE;
			o_EX_Smash <= TRUE;
		end
		
	end
	
		// MEM validation
	always @(*)
	begin
		o_MEM_Stall <= FALSE;
		o_MEM_Smash <= FALSE;
		
		if( Executing )
		begin
			if( !i_MEM_Done )
			begin
				o_MEM_Stall <= TRUE;
				o_MEM_Smash <= TRUE;		// Waiting on mem. Don't write back.
			end


			if( o_WB_Stall )
				o_MEM_Stall <= o_WB_Stall;
		end
		else
		begin
			o_MEM_Stall <= TRUE;
			o_MEM_Smash <= TRUE;
		end
	end
	
		// WB validation - never stall or flush wb.
	always @(*)
	begin
		o_WB_Stall <= FALSE;
		o_WB_Smash <= FALSE;
		
		if( Executing )
		begin
		end
		else
		begin
			o_WB_Stall <= TRUE;
			o_WB_Smash <= TRUE;
		end
	end
	
endmodule
