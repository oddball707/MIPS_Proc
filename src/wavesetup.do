onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/IFETCH/i_Clk
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/IFETCH/i_Reset_n
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/IFETCH/i_Stall
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/IFETCH/i_Load
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/IFETCH/i_Load_Address
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/IFETCH/o_PC
add wave -noupdate -divider -height 32 {IF -> DEC}
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/PIPE_IF_DEC/i_Clk
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/PIPE_IF_DEC/i_Reset_n
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/PIPE_IF_DEC/i_Flush
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/PIPE_IF_DEC/i_Stall
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/PIPE_IF_DEC/i_PC
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/PIPE_IF_DEC/i_Instruction
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/PIPE_IF_DEC/o_PC
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/PIPE_IF_DEC/o_Instruction
add wave -noupdate -divider -height 32 DECODER
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/i_PC
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/i_Instruction
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Uses_ALU
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_ALUCTL
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Is_Branch
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Branch_Target
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Jump_Reg
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Mem_Valid
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Mem_Mask
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Mem_Read_Write_n
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Uses_RS
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_RS_Addr
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Uses_RT
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_RT_Addr
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Uses_Immediate
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Immediate
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Writes_Back
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/o_Write_Addr
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/Opcode
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DECODE/Func
add wave -noupdate -divider -height 32 REGFILE
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/REGFILE/i_Clk
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/REGFILE/i_RS_Addr
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/REGFILE/i_RT_Addr
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/REGFILE/i_Write_Enable
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/REGFILE/i_Write_Addr
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/REGFILE/i_Write_Data
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/REGFILE/o_RS_Data
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/REGFILE/o_RT_Data
add wave -noupdate -format Literal -radix hexadecimal -expand /test_mips_cpu/MIPS_CPU/REGFILE/Register
add wave -noupdate -divider -height 32 ALU
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/DEC_o_Uses_Immediate
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DEC_o_RT_Data
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/DEC_o_Immediate
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/ALU/i_Valid
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/ALU/i_ALUCTL
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/ALU/i_Operand1
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/ALU/i_Operand2
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/ALU/o_Valid
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/ALU/o_Result
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/ALU/o_Branch_Valid
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/ALU/o_Branch_Outcome
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/ALU/o_Pass_Done_Value
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/ALU/o_Pass_Done_Change
add wave -noupdate -divider -height 32 {ALU -> MEM}
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_Clk
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_Reset_n
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_Flush
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_Stall
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_ALU_Result
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/o_ALU_Result
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_Mem_Valid
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/o_Mem_Valid
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_Mem_Mask
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/o_Mem_Mask
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_Mem_Read_Write_n
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/o_Mem_Read_Write_n
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_Mem_Write_Data
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/o_Mem_Write_Data
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_Writes_Back
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/o_Writes_Back
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/i_Write_Addr
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_EX_MEM/o_Write_Addr
add wave -noupdate -divider -height 32 HDU
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_Clk
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_Reset_n
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_FlashLoader_Done
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_DEC_Uses_RS
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_DEC_RS_Addr
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_DEC_Uses_RT
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_DEC_RT_Addr
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_IF_Done
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_EX_Writes_Back
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_EX_Uses_Mem
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_EX_Write_Addr
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_EX_Branch
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_MEM_Uses_Mem
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_MEM_Writes_Back
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_MEM_Write_Addr
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_MEM_Done
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_WB_Writes_Back
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/i_WB_Write_Addr
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/o_IF_Stall
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/o_IF_Smash
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/o_DEC_Stall
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/o_DEC_Smash
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/o_EX_Stall
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/o_EX_Smash
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/o_MEM_Stall
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/o_MEM_Smash
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/o_WB_Stall
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/o_WB_Smash
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/r_Branch_IF_Smash
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/HAZARD_DETECTION_UNIT/r_IF_Smash_Transient
add wave -noupdate -divider -height 32 D_CACHE
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_Clk
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_Reset_n
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_Valid
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_Mem_Mask
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_Address
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_Read_Write_n
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_Write_Data
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/o_Ready
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/o_Valid
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/o_Data
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/o_MEM_Valid
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/o_MEM_Read_Write_n
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/o_MEM_Address
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/o_MEM_Data
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_MEM_Valid
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_MEM_Data_Read
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_MEM_Last
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_MEM_Data
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/r_i_BlockOffset
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/r_i_Index
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/r_i_Tag
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/r_i_Write_Data
add wave -noupdate -format Logic -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/r_i_Read_Write_n
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_BlockOffset
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_Index
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i_Tag
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/Populate_Data
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/State
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/i
add wave -noupdate -format Literal -radix hexadecimal /test_mips_cpu/MIPS_CPU/D_CACHE/Gen_Count
add wave -noupdate -divider -height 32 {MEM -> WB}
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_MEM_WB/i_Clk
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_MEM_WB/i_Reset_n
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_MEM_WB/i_Flush
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_MEM_WB/i_Stall
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_MEM_WB/i_WriteBack_Data
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_MEM_WB/o_WriteBack_Data
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_MEM_WB/i_Writes_Back
add wave -noupdate -format Logic /test_mips_cpu/MIPS_CPU/PIPE_MEM_WB/o_Writes_Back
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_MEM_WB/i_Write_Addr
add wave -noupdate -format Literal /test_mips_cpu/MIPS_CPU/PIPE_MEM_WB/o_Write_Addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {522636641 ps} 0} {{Cursor 2} {524245000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {523937382 ps} {524552618 ps}
