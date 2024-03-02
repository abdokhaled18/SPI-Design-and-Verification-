use strict;
use warnings;
use diagnostics;
use File::Path; 
use File::Path qw/make_path/;
use Cwd;



# say prints a line followed by a newline
use feature 'say';
 
# Use a Perl version of switch called given when
use feature "switch";

# General Args
my $moduleName = "SPI";
my $sv_ext = ".sv";
my $designName = "SPI";
my $runDo = "${\($moduleName)}_run.do";
my $dir = cwd();

# UVM Files 
my $sequenceItem = $moduleName."_sequence_item".$sv_ext;
my $sequence = $moduleName."_sequence".$sv_ext;
my $driver = $moduleName."_driver".$sv_ext;
my $monitor = $moduleName."_monitor".$sv_ext;
my $sequencer = $moduleName."_sequencer".$sv_ext;
my $agent = $moduleName."_agent".$sv_ext;
my $scoreboard = $moduleName."_scoreboard".$sv_ext;
my $subscriber = $moduleName."_subscriber".$sv_ext;
my $env = $moduleName."_env".$sv_ext;
my $test = $moduleName."_test".$sv_ext;
my $top = $moduleName."_top".$sv_ext;
my $intf = $moduleName."_intf".$sv_ext;
my $pkg = $moduleName."_pkg".$sv_ext;

rmtree("$dir/UVM_$moduleName/");

mkdir("UVM_$moduleName") or die ("The directory already EXISTED !!");;

chdir "./UVM_$moduleName";

# Generating Agent
open my $fh_agent, '>', $agent
  or die "Can't open file : $!";

print $fh_agent <<"DONATE";

class ${\($moduleName)}_agent extends uvm_agent;

	// [Registeration] Add utilites to make driver more effcient
	`uvm_component_utils(${\($moduleName)}_agent);
	
	// Intantiate hierarchy components
	${\($moduleName)}_driver 		  m_drv;
	${\($moduleName)}_monitor 		m_mnt;
	${\($moduleName)}_sequencer 	m_sqncr;
	
	// [Construction] A default contructor to create handle for parent
	function new (string name = "${\($moduleName)}_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	// Phases only exists in components
	// [Build phase] create handles for used components in this scope
	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		\$display("This is agent build phase");	
		
		// Create instances for components
		m_drv	  =	${\($moduleName)}_driver::type_id::create("m_drv",this);
		m_mnt	  =	${\($moduleName)}_monitor::type_id::create("m_mnt",this);
		m_sqncr	=	${\($moduleName)}_sequencer::type_id::create("m_sqncr",this);
	endfunction
	
	// [Connect phase] Connects used ports with corresponding implementations or exports
	virtual function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		\$display("This is agent connect phase");

		// Connect Driver with Sequencer
		m_drv.seq_item_port.connect(m_sqncr.seq_item_export);
	endfunction
	
	// [run_phase] Do the operation needed in this scope
	virtual task run_phase (uvm_phase phase);
		super.run_phase(phase);
		\$display("This is agent run phase");

	endtask

endclass

DONATE
close $fh_agent or die "Couldn't Close File : $!";

# Generating Driver
open my $fh_driver, '>', $driver
  or die "Can't open file : $!";

print $fh_driver <<"DONATE";
class ${\($moduleName)}_driver extends uvm_driver #(${\($moduleName)}_sequence_item);

	// Instanstiations
	${\($moduleName)}_sequence_item seq_transaction;
	virtual ${\($moduleName)}_intf drv_vif;

	// [Registeration] Add utilites to make driver more effcient
	`uvm_component_utils(${\($moduleName)}_driver);

	// [Construction] A default contructor to create handle for parent
	function new (string name = "${\($moduleName)}_driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	// Phases only exists in components
	// [Build phase] create handles for used components in this scope
	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		\$display("This is driver build phase");

		// Check Whether the interface is existed
		if(!(uvm_config_db #(virtual ${\($moduleName)}_intf)::get(this,"","${\($moduleName)}_vif",drv_vif)))
      		`uvm_fatal(get_full_name(),"Error in getting virtual handle at driver!")

		// Create Handels
		seq_transaction = ${\($moduleName)}_sequence_item::type_id::create("seq_transaction");

	endfunction
	
	// [Connect phase] Connects used ports with corresponding implementations or exports
	virtual function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		\$display("This is driver connect phase");
	endfunction
	
	// [run_phase] Do the operation needed in this scope
	virtual task run_phase (uvm_phase phase);
		super.run_phase(phase);
		\$display("This is driver run phase");

		forever begin

			// Get next transaction from sequencer
			seq_item_port.get_next_item(seq_transaction);
			
			// Send transaction to DUT (Virtual interface that driving DUT)
        // Write Your Interface Assignments Here!

			`uvm_info(get_type_name(),\$sformatf(""),UVM_MEDIUM);
				
			seq_item_port.item_done();

			#10;
		end

	endtask
endclass

DONATE
close $fh_driver or die "Couldn't Close File : $!";

# Generating Env
open my $fh_env, '>', $env
  or die "Can't open file : $!";

print $fh_env <<"DONATE";
class ${\($moduleName)}_env extends uvm_env;

	// [Registeration] Add utilites to make driver more effcient
	`uvm_component_utils(${\($moduleName)}_env);
	`define MON_HIER m_agent.m_mnt

	// Intantiate hierarchy components
	${\($moduleName)}_agent 		  m_agent;
	${\($moduleName)}_scoreboard 	m_scrbd;
	${\($moduleName)}_subscriber 	m_sbscrb;

	// [Construction] A default contructor to create handle for parent
	function new (string name = "${\($moduleName)}_env", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	// Phases only exists in components
	// [Build phase] create handles for used components in this scope
	virtual function void build_phase (uvm_phase phase);	
		super.build_phase(phase);
		\$display("This is env build phase");	
		
		// Create instances for components
		m_agent	 = ${\($moduleName)}_agent::type_id::create("m_agent",this);
		m_scrbd	 = ${\($moduleName)}_scoreboard::type_id::create("m_scrbd",this);
		m_sbscrb = ${\($moduleName)}_subscriber::type_id::create("m_sbscrb",this);
	endfunction
	
	// [Connect phase] Connects used ports with corresponding implementations or exports
	virtual function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		\$display("This is env connect phase");

		// Connect agent with scoreboard and subscriber
		`MON_HIER.mnt_analysis_port.connect(m_scrbd.scrbd_analysis_export);
		`MON_HIER.mnt_analysis_port.connect(m_sbscrb.analysis_export);
	endfunction
	
	// [run_phase] Do the operation needed in this scope
	virtual task run_phase (uvm_phase phase);
		super.run_phase(phase);
		\$display("This is env run phase");

	endtask

endclass

DONATE
close $fh_env or die "Couldn't Close File : $!";

# Generating Monitor
open my $fh_monitor, '>', $monitor
  or die "Can't open file : $!";

print $fh_monitor <<"DONATE";
class ${\($moduleName)}_monitor extends uvm_monitor;

	// Instantiations 
	virtual ${\($moduleName)}_intf mnt_vif;
	${\($moduleName)}_sequence_item seq_transaction;
	uvm_analysis_port #(${\($moduleName)}_sequence_item) mnt_analysis_port;
	
	// [Registeration] Add utilites to make driver more effcient
	`uvm_component_utils(${\($moduleName)}_monitor);

	// [Construction] A default contructor to create handle for parent
	function new (string name = "${\($moduleName)}_monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	// Phases only exists in components
	// [Build phase] create handles for used components in this scope
	virtual function void build_phase (uvm_phase phase);	
		super.build_phase(phase);
		\$display("This is monitor build phase");

		// Check Whether the interface is existed
		if(!(uvm_config_db #(virtual ${\($moduleName)}_intf)::get(this,"","${\($moduleName)}_vif",mnt_vif)))
      		`uvm_fatal(get_full_name(),"Error in getting virtual handle at monitor!")

		// Create Handels
		seq_transaction = ${\($moduleName)}_sequence_item::type_id::create("seq_transaction");
		mnt_analysis_port = new ("mnt_analysis_port",this);
	endfunction
	
	// [Connect phase] Connects used ports with corresponding implementations or exports
	virtual function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		\$display("This is monitor connect phase");
	endfunction
	
	// [run_phase] Do the operation needed in this scope
	virtual task run_phase (uvm_phase phase);
		super.run_phase(phase);
		\$display("This is monitor run phase");
		
		forever begin

			// Receive transaction from DUT (Virtual interface monitoring DUT)
          // Write Your Interface Assignments Here!

			`uvm_info(get_type_name(),\$sformatf(""),UVM_MEDIUM);

			// Sent the transaction to subscriber and scoreboard for analysis
			mnt_analysis_port.write(seq_transaction);

			#10;
		end
	endtask

endclass

DONATE
close $fh_monitor or die "Couldn't Close File : $!";

# Generating Subscriber
open my $fh_subscriber, '>', $subscriber
  or die "Can't open file : $!";

print $fh_subscriber <<"DONATE";
class ${\($moduleName)}_subscriber extends uvm_subscriber #(${\($moduleName)}_sequence_item);

	// Instantiations
	${\($moduleName)}_sequence_item seq_transaction;

	// Cover Groups
	covergroup ${\($moduleName)}_Covergroup;

		// Write Your Cover Points Here ! 
	
  endgroup


	// [Registeration] Add utilites to make driver more effcient
	`uvm_component_utils(${\($moduleName)}_subscriber);
	
	// [Construction] A default contructor to create handle for parent
	function new (string name = "${\($moduleName)}_subscriber", uvm_component parent = null);
		super.new(name, parent);
		${\($moduleName)}_Covergroup = new();
	endfunction

	// Phases only exists in components
	// [Build phase] create handles for used components in this scope
	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		\$display("This is subscriber build phase");	

		// Create Handels
		seq_transaction = ${\($moduleName)}_sequence_item::type_id::create("seq_transaction");
	endfunction
	
	// Ovrriding write method called in monitor
	virtual function void write (${\($moduleName)}_sequence_item t);
	
	// Receive transaction from monitor
	seq_transaction = t;
	//`uvm_info(get_type_name(),\$sformatf(""),UVM_MEDIUM);
	// Apply coverage
	${\($moduleName)}_Covergroup.sample();
	endfunction

	// [Connect phase] Connects used ports with corresponding implementations or exports
	virtual function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		\$display("This is subscriber connect phase");
	endfunction

	// [run_phase] Do the operation needed in this scope
	virtual task run_phase (uvm_phase phase);
		super.run_phase(phase);
		\$display("This is subscriber run phase");
	endtask

endclass

DONATE
close $fh_subscriber or die "Couldn't Close File : $!";

# Generating Scoreboard
open my $fh_scoreboard, '>', $scoreboard
  or die "Can't open file : $!";

print $fh_scoreboard <<"DONATE";
class ${\($moduleName)}_scoreboard extends uvm_scoreboard;

	// Instanstiations
	${\($moduleName)}_sequence_item seq_transaction;
	uvm_tlm_analysis_fifo #(${\($moduleName)}_sequence_item) ${\($moduleName)}_tlm_analysis_fifo;
	uvm_analysis_export #(${\($moduleName)}_sequence_item) scrbd_analysis_export;

	// [Registeration] Add utilites to make driver more effcient
	`uvm_component_utils(${\($moduleName)}_scoreboard);

	// [Construction] A default contructor to create handle for parent
	function new (string name = "${\($moduleName)}_scoreboard", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	// Phases only exists in components
	// [Build phase] create handles for used components in this scope
	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		\$display("This is scoreboard build phase");		

		${\($moduleName)}_tlm_analysis_fifo = new("${\($moduleName)}_tlm_analysis_fifo",this);
		scrbd_analysis_export = new("scrbd_analysis_export",this);
	endfunction
	
	// [Connect phase] Connects used ports with corresponding implementations or exports
	virtual function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		\$display("This is scorboard connect phase");
		scrbd_analysis_export.connect(${\($moduleName)}_tlm_analysis_fifo.analysis_export);
	endfunction
	
	// [run_phase] Do the operation needed in this scope
	virtual task run_phase (uvm_phase phase);
		super.run_phase(phase);
		\$display("This is scorboard run phase");

		forever begin
			${\($moduleName)}_tlm_analysis_fifo.get(seq_transaction);

      // Write Your Output Conditions Here!

		end
	endtask

endclass

DONATE
close $fh_scoreboard or die "Couldn't Close File : $!";

# Generating Test 
open my $fh_test, '>', $test
  or die "Can't open file : $!";

print $fh_test <<"DONATE";
class ${\($moduleName)}_test extends uvm_test;

	// [Registeration] Add utilites to make driver more effcient
	`uvm_component_utils(${\($moduleName)}_test);
	`define SQNCR_HIERARCHY m_env.m_agent.m_sqncr

	// Intantiate hierarchy components
	${\($moduleName)}_env m_env;
	${\($moduleName)}_sequence m_sqnc;

	// [Construction] A default contructor to create handle for parent
	function new (string name = "${\($moduleName)}_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	// Phases only exists in components
	// [Build phase] create handles for used components in this scope
	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		\$display("This is test build phase");	
		
		// Create instances for components
		m_env	  = ${\($moduleName)}_env::type_id::create("m_env",this);
		m_sqnc	= ${\($moduleName)}_sequence::type_id::create("m_sqnc");
	endfunction
	
	// [Connect phase] Connects used ports with corresponding implementations or exports
	virtual function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		\$display("This is test connect phase");
	endfunction
	
	// [End of elaboration phase]
	virtual function void end_of_elaboration_phase (uvm_phase phase);
		// Printing uvm hierarchy (mostly) (not sure yet!!)	
		uvm_top.print_topology();
	endfunction
	
	// [run_phase] Do the operation needed in this scope
	virtual task run_phase (uvm_phase phase);
		super.run_phase(phase);
		\$display("This is test run phase");

		phase.raise_objection(this);

		// Start Sequence operation
		m_sqnc.start(`SQNCR_HIERARCHY);
		
		phase.drop_objection(this);
	endtask

endclass

DONATE
close $fh_test or die "Couldn't Close File : $!";

# Generating Sequencer
open my $fh_sequencer, '>', $sequencer
  or die "Can't open file : $!";

print $fh_sequencer <<"DONATE";
class ${\($moduleName)}_sequencer extends uvm_sequencer #(${\($moduleName)}_sequence_item);

	// [Registeration] Add utilites to make driver more effcient
	`uvm_component_utils(${\($moduleName)}_sequencer);

	// [Construction] A default contructor to create handle for parent
	function new (string name = "${\($moduleName)}_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	// Phases only exists in components
	// [Build phase] create handles for used components in this scope
	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		\$display("This is sequencer build phase");		
	endfunction
	
	// [Connect phase] Connects used ports with corresponding implementations or exports
	virtual function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		\$display("This is sequencer connect phase");
	endfunction
	
	// [run_phase] Do the operation needed in this scope
	virtual task run_phase (uvm_phase phase);
		super.run_phase(phase);
	endtask

endclass

DONATE
close $fh_sequencer or die "Couldn't Close File : $!";

# Generating Sequence
open my $fh_sequence, '>', $sequence
  or die "Can't open file : $!";

print $fh_sequence <<"DONATE";
class ${\($moduleName)}_sequence extends uvm_sequence;
	
	// Instanctiation
	${\($moduleName)}_sequence_item seq_transaction;

	// [Registeration] Add utilites to make driver more effcient
	`uvm_object_utils(${\($moduleName)}_sequence);

	function new (string name = "${\($moduleName)}_sequence");
		super.new(name);
	endfunction
	
	task pre_body();
		// Create Handels
		seq_transaction = ${\($moduleName)}_sequence_item::type_id::create("seq_transaction");
	endtask
	
	task body();
		
			// Start new tranaction
			start_item(seq_transaction);
			
			// Generate test tranaction [Randomize required inputs]
			void'(seq_transaction.randomize());
			`uvm_info(get_type_name(),\$sformatf(""),UVM_MEDIUM);
			
			// End transaction preperation
			finish_item(seq_transaction);
		
	endtask
	
endclass

DONATE
close $fh_sequence or die "Couldn't Close File : $!";

# Generating Sequence Item
open my $fh_sequenceItem, '>', $sequenceItem
  or die "Can't open file : $!";

print $fh_sequenceItem <<"DONATE";
class ${\($moduleName)}_sequence_item extends uvm_sequence_item;
	// [Registeration] Add utilites to make driver more effcient
	`uvm_object_utils(${\($moduleName)}_sequence_item);
    
	function new (string name = "${\($moduleName)}_sequence_item");
		super.new(name);
	endfunction
	
	// Parameters

	// Define DUT I/Os Here!!
	
	// Define constraints

endclass
DONATE
close $fh_sequenceItem or die "Couldn't Close File : $!";

# Generating Top tb
open my $fh_top, '>', $top
  or die "Can't open file : $!";

print $fh_top <<"DONATE";
`include "uvm_macros.svh"
import uvm_pkg::*;
import ${\($moduleName)}_pkg ::*; 

module ${\($moduleName)}_top;
 
${\($moduleName)}_intf ${\($moduleName)}_vif1 ();
initial begin

uvm_config_db #(virtual ${\($moduleName)}_intf)::set(null,"uvm_test_top*","${\($moduleName)}_vif",${\($moduleName)}_vif1); 
run_test("${\($moduleName)}_test");

end

endmodule
DONATE
close $fh_top or die "Couldn't Close File : $!";

# Generating Interface
open my $fh_intf, '>', $intf
  or die "Can't open file : $!";

print $fh_intf <<"DONATE";
interface ${\($moduleName)}_intf #(parameter );
    
    // Write your Code Here!

endinterface
DONATE
close $fh_intf or die "Couldn't Close File : $!";

# Generating Package
open my $fh_pkg, '>', $pkg
  or die "Can't open file : $!";

print $fh_pkg <<"DONATE";
package ${\($moduleName)}_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "${\($moduleName)}_sequence_item.sv"
`include "${\($moduleName)}_sequence.sv"

`include "${\($moduleName)}_driver.sv"
`include "${\($moduleName)}_monitor.sv"
`include "${\($moduleName)}_sequencer.sv"

`include "${\($moduleName)}_agent.sv"
`include "${\($moduleName)}_scoreboard.sv"
`include "${\($moduleName)}_subscriber.sv"

`include "${\($moduleName)}_env.sv"
`include "${\($moduleName)}_test.sv"

endpackage
DONATE

close $fh_pkg or die "Couldn't Close File : $!";

# Generating run.do file
open my $fh_do, '>', $runDo
  or die "Can't open file : $!";

print $fh_do <<"DONATE";
puts "----------------------------------"
puts "-- [RUN] QUIT SIMULATION"
quit -sim

puts "-- [RUN] DELETING WORK LIBRARY..."
RD /S /Q work
puts "-- [RUN] DELETING DONE !!"

puts "----------------------------------"
puts "-- [RUN] CREATING WORK LIBRARY..."
vlib work
puts "-- [RUN] CREATION DONE !!"

puts "----------------------------------"
puts "-- [RUN] COMPILING FILE"
vlog -work work -vopt -sv ${\($moduleName)}_pkg.sv ${\($moduleName)}_top.sv  ${\($moduleName)}_intf.sv ${\($designName)}.v +cover

puts "----------------------------------"
puts "-- [RUN] OPENING SIMULATION"
# vsim ${\($moduleName)}_top -coverage -do "set NoQuitOnFinish 1; run -all; coverage report -codeAll -cvg -verbose"

DONATE

close $fh_do or die "Couldn't Close File : $!";