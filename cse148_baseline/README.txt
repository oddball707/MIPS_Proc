CSE148 Baseline Design v1.2 (1/11/11)
by Pravin Prabhu & Todor Mollov

//==============================================================================
Changelog:
(1/11/11)	v1.2 released
		- Now completely implementable in hardware!
		- Renamed some top-level signals to more closely match H&P
			clasic 5-stage pipeline design

(1/9/11)	v1.1 released
		- Changed cache sizes (smaller)
		- Fixed bug in ForwardingUnit
		- Fixed bug in dcache
		- Made dcache & icache have correct address alignments

(1/5/11)	v1.0 released


//==============================================================================
Getting Started:
	To get started with the baseline design, it is recommended that you first
download modelsim (student edition). Modelsim can be found at 

http://model.com/


	You should also install QuartusII so you can eventually deploy your design
to actual hardware. The QuartusII web install package can be downloaded from
Altera's website at:

http://www.altera.com/products/software/quartus-ii/web-edition/qts-we-index.html


	I recommend that you use a text editor other than Modelsim or Quartus's 
built in editor -- notepad++ is an excellent alternative and even has syntax
highlighting for verilog.


(Other tips to help get started)
	The included files in the reference folder provide full documentation as
to how instructions should execute -- you will probably be consulting these 
files often.

	When simulating your design, you can load wavesetup.do which will 
automatically add and organize most signals in the design. Note that new signals
you add yourself will not be in the default wavesetup.do file, but you can save
them yourself to the file.

	To choose your compiled benchmark to run, simply open test_mips_cpu.v and 
change the parameter to 'readmemh' which is found near the end of the file.
Note that you must use an absolute path (I think this is a bug in modelsim) to
the hex file you wish to load. The base benchmarks are nqueens.hex, esift.hex,
qsort.hex and coin.hex. Descriptions as to what each of the benchmarks do can
be found in the ref folder under 'benchmarks.pdf'. The included c files serve
as good representations of what to expect of each binary. Please note that in
some cases the included hex file does not exactly match the included disassembly
file! Note: The included benchmarks.pdf should only be consulted for information
about the execution behavior of each benchmark. The other information in the
document that outlines switch behavior and loading from flash is no longer
relevant to the design.

	After you program your design to the hardware, you can check its
performance by toggling the switches and examining the 7 segment display output.
The decoding is as follows:

Switches 0 and 1 form a binary number (00 = both off, 01, 10, 11)

00:	Displays pass/done/fail status on HEX2, HEX1, and HEX0.
	Displays lower 8 bits of the address going into IMEM.

01:	Displays the number of cycles that the cpu took to reach the done state.

02:	Displays the number of (non-noop) instructions executed in total.

	Thus, to calculate CPI, you would toggle the switches to first display
the total number of cycles that your design completed in and then divide
by the total number of instructions that the design executed to complete 
the benchmark.

//==============================================================================
Details About the Design:
	The baseline design implements a subset of the MIPS32 ISA. The provided
benchmarks -- nqueens, qsort, coin, and esift -- will be used in this class to
gauge the performance increases obtained through your processor enhancements.

	The nomenclature of wires is as follows: A wire/register typically has
three components [TAG]_[DIRECTION]_[NAME]. TAG refers to the meta-unit associated
with the signal. For example, all signals that have to do with the DECODE stage
will be prefixed with DEC_. Next is DIRECTION -- it's either i_ or o_ depending
on whether the signal is an input or output in the given context. For example,
all input ports on the ALU will be labeled as i_(name), and all outputs will
be labeled as o_(name). Finally, NAME is meant to convey the actual purpose of
the signal. By using this convention, it is usually relatively easy to identify
where a signal is, its I/O direction, and get some idea of its purpose.

	The design follows strongly from the 5-stage MIPS pipeline presented in 
Computer Organization and Design (Hennessy and Patterson). The pipeline stages
are laid out as follow:

	Instruction Fetch -> Decode -> Execute -> Mem Access -> Write-Back
		
	Important caveats to note include the fact that branch resolution happens in
the execute stage and not the decode stage. This is done for regularity, though
pushing branch resolution back to decode would technically improve performance.
Second, keep in mind that IFetch and Mem both access the same main memory -- 
there is a level of arbitration outside of both of these stages that decides
which of these sources will be given access to main memory when competing for
resources. Third, full forwarding is enabled. This means that an instruction
executing in a later stage (such as Mem) can have its result directly fed to an
earlier stage if an instruction requires it. However, there are still scenarios
that present hazards in the pipeline, and when adding your own logic, it is
important to carefully consider hazard implications of said logic.


//==============================================================================
Tips for Optimizations:
[Branch Predictors]
	One of the more important optimizations to consider is a branch predictor.
The processor currently always flushes the instruction following the delay slot
on resolving a branch in execute (i.e. it implicitly assumes not-taken). In
reality, most branches _are_ taken -- especially in code that contains loops
(as do many of the benchmarks...)

	A branch predictor typically resides parallel to the Decode stage, looking
for possible branches and making predictions. When a branch is seen, a
speculation bit can set to 1 and the PC can be told to branch/not branch. When
the branch is resolved, the instruction can be flushed if it was incorrect.

[Caches]
	Another good consideration would be to improve upon the basic caches
provided in the design. The caches could be upgraded, for example, to victim
caches, lockup-free caches (useful if you're planning on going OOO), etc...
Using the cache interface should be relatively straightforward -- the signaling
is as follows:

	1.) Output a ready signal when your cache is ready to accept a request.
	2.) Take down the ready signal when processing begins.
	3.) If it's a read, output valid=1 signal when the data being outputted from
		the cache is correct.
	3.b) If it's a write, output valid=1 signal when the data has been
		successfully written to the cache.
	3.c) Keep valid=0 at all other times. (of course, you can 'fake' having
		completed an operation if you want, which could be useful for getting
		more write ops in)
	4) Bring the ready signal up again when ready to process another request.
	
	An important note about the caches is that they interface with main memory
which is inherently bursty. See the basic caches to get a feel for how to
communicate with main memory (an important note is that all requests to main
memory should be shifted left by 1 bit, as main memory actually transacts in
16 bit values internally).


//==============================================================================
Questions/Comments

	If you find any bugs, I would greatly appreciate any information about them 
-- please contact me (Pravin Prabhu) via email (pprabhu@ucsd.edu) or through my
office hours.

	Happy hardware hacking!