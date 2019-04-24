require evr_timestamp_buffer,v2.6.1
require evr_seq_calc,v0.9.2

epicsEnvSet("SYS", "LabS-Utgard-VIP:TS")
epicsEnvSet("PCI_SLOT", "1:0.0")
epicsEnvSet("DEVICE", "EVR-2")
epicsEnvSet("EVR", "$(DEVICE)")
epicsEnvSet("CHIC_SYS", "LabS-Utgard-VIP:")
epicsEnvSet("CHOP_DRV", "Chop-Drv-01")
epicsEnvSet("CHIC_DEV", "TS-$(DEVICE)")
epicsEnvSet("BUFFSIZE", "100")
epicsEnvSet("MRF_HW_DB", "evr-pcie-300dc-ess.db")
epicsEnvSet("E3_MODULES", "/epics/iocs/e3")
epicsEnvSet("EPICS_CMDS", "/epics/iocs/cmds")


< "$(EPICS_CMDS)/mrfioc2-common-cmd/st.evr.cmd"

# Load timestamp buffer database
iocshLoad("$(evr_timestamp_buffer_DIR)/evr_timestamp_buffer.iocsh", "CHIC_SYS=$(CHIC_SYS), CHIC_DEV=$(CHIC_DEV), CHOP_DRV=$(CHOP_DRV), SYS=$(SYS), BUFFSIZE=$(BUFFSIZE)")

# Load the sequencer configuration script
iocshLoad("$(evr_seq_calc_DIR)/evr_seq_calc.iocsh", "DEV1=$(CHOP_DRV)01:, DEV2=$(CHOP_DRV)02:, DEV3=$(CHOP_DRV)03:, DEV4=$(CHOP_DRV)04:, SYS_EVRSEQ=$(CHIC_SYS), EVR_EVRSEQ=$(CHIC_DEV):")

iocInit()

# Global default values
# Set the frequency that the EVR expects from the EVG for the event clock
dbpf $(SYS)-$(DEVICE):Time-Clock-SP 88.0525

# Set delay compensation target. This is required even when delay compensation
# is disabled to avoid occasionally corrupting timestamps.
dbpf $(SYS)-$(DEVICE):DC-Tgt-SP 100

######### INPUTS #########

# Set up of UnivIO 0 as Input. Generate Code 10 locally on rising edge.
dbpf $(SYS)-$(DEVICE):In0-Lvl-Sel "Active High"
dbpf $(SYS)-$(DEVICE):In0-Edge-Sel "Active Rising"
dbpf $(SYS)-$(DEVICE):OutFPUV00-Src-SP 61
dbpf $(SYS)-$(DEVICE):In0-Trig-Ext-Sel "Edge"
dbpf $(SYS)-$(DEVICE):In0-Code-Ext-SP 10
dbpf $(SYS)-$(DEVICE):EvtA-SP.OUT "@OBJ=$(EVR),Code=10"
dbpf $(SYS)-$(DEVICE):EvtA-SP.VAL 10

# Set up of UnivIO 1 as Input. Generate Code 11 locally on rising edge.
dbpf $(SYS)-$(DEVICE):In1-Lvl-Sel "Active High"
dbpf $(SYS)-$(DEVICE):In1-Edge-Sel "Active Rising"
dbpf $(SYS)-$(DEVICE):OutFPUV01-Src-SP 61
dbpf $(SYS)-$(DEVICE):In1-Trig-Ext-Sel "Edge"
dbpf $(SYS)-$(DEVICE):In1-Code-Ext-SP 11
dbpf $(SYS)-$(DEVICE):EvtB-SP.OUT "@OBJ=$(EVR),Code=11"
dbpf $(SYS)-$(DEVICE):EvtB-SP.VAL 11

######### OUTPUTS #########
#Set up delay generator 0 to trigger on event 14
dbpf $(SYS)-$(DEVICE):DlyGen0-Width-SP 1000 #1ms
dbpf $(SYS)-$(DEVICE):DlyGen0-Delay-SP 0 #0ms
dbpf $(SYS)-$(DEVICE):DlyGen0-Evt-Trig0-SP 14

#Set up delay generator 1 to trigger on event 14
dbpf $(SYS)-$(DEVICE):DlyGen1-Evt-Trig0-SP 14
dbpf $(SYS)-$(DEVICE):DlyGen1-Width-SP 2860 #1ms
dbpf $(SYS)-$(DEVICE):DlyGen1-Delay-SP 0 #0ms

#Set up delay generator 2 to trigger on event 17
dbpf $(SYS)-$(DEVICE):DlyGen2-Width-SP 1000 #1ms
dbpf $(SYS)-$(DEVICE):DlyGen2-Delay-SP 0 #0ms
dbpf $(SYS)-$(DEVICE):DlyGen2-Evt-Trig0-SP 17
dbpf $(SYS)-$(DEVICE):OutFPUV02-Src-SP 2 #Connect output2 to DlyGen-2

#Set up delay generator 3 to trigger on event 18
dbpf $(SYS)-$(DEVICE):DlyGen3-Width-SP 1000 #1ms
dbpf $(SYS)-$(DEVICE):DlyGen3-Delay-SP 0 #0ms
dbpf $(SYS)-$(DEVICE):DlyGen3-Evt-Trig0-SP 18
dbpf $(SYS)-$(DEVICE):OutFPUV03-Src-SP 3 #Connect output3 to DlyGen-3

######## Sequencer #########
#dbpf $(SYS)-$(DEVICE):Base-Freq 14.00000064
dbpf $(SYS)-$(DEVICE):End-Event-Ticks 4

# Load sequencer setup
dbpf $(SYS)-$(DEVICE):SoftSeq0-Load-Cmd 1

# Enable sequencer
dbpf $(SYS)-$(DEVICE):SoftSeq0-Enable-Cmd 1

# Select run mode, "Single" needs a new Enable-Cmd every time, "Normal" needs Enable-Cmd once
dbpf $(SYS)-$(DEVICE):SoftSeq0-RunMode-Sel "Normal"

# Load sequence events and corresponding tick lists
#system "/bin/bash /epics/iocs/cmds/labs-utgard-evr2/conf_evr_seq.sh"

# Use ticks or microseconds
dbpf $(SYS)-$(DEVICE):SoftSeq0-TsResolution-Sel "Ticks"

# Select trigger source for soft seq 0, trigger source 0, delay gen 0
dbpf $(SYS)-$(DEVICE):SoftSeq0-TrigSrc-0-Sel 0

# Commit all the settings for the sequnce
# commit-cmd by evrseq!!! dbpf $(SYS)-$(DEVICE):SoftSeq0-Commit-Cmd "1"


# Hints for setting input PVs from client
#caput -a $(SYS)-$(DEVICE):SoftSeq0-EvtCode-SP 2 17 18
#caput -a $(SYS)-$(DEVICE):SoftSeq0-Timestamp-SP 2 0 12578845
#caput -n $(SYS)-$(DEVICE):SoftSeq0-Commit-Cmd 1
######### TIME STAMP #########

dbpf LabS-Utgard-VIP:Chop-Drv-0101:Freq-SP.INP "LabS-VIP:Chop-Drv-0101:Spd_SP CPP"
dbpf LabS-Utgard-VIP:Chop-Drv-0102:Freq-SP.INP "LabS-VIP:Chop-Drv-0101:Spd_SP CPP"
