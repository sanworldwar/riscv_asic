.PHONY: anvlog elab wave clean all
 
OUTPUT = simv
 
TB_TOP_MODULE = openriscv_sopc_tb
 
FSDB_FILE = ${TB_TOP_MODULE}.fsdb
 
ALL_DEFINE = +define+DUMP_VPD +define+DISPLAY
 
ANVLG = vlogan -timescale=1ns/1ps -sverilog -nc +v2k -kdb ${ALL_DEFINE} -f filelist.f

CM = -cm line+cond+fsm+branch+tgl
 
CM_NAME = -cm_name ${OUTPUT}
 
CM_DIR = -cm_dir ./${OUTPUT}.vdb

ELAB = vcs \
	  -timescale=1ns/1ps -sverilog -nc +v2k -kdb ${ALL_DEFINE} -f filelist.f \
	  +define+SIMULATION \
	  ${CM} \
	  ${CM_NAME} \
	  ${CM_DIR} \
	  +incdir+../rtl/core/ \
	  -full64 -R  -debug_all \
	  -l compile.log \
	  -o ${OUTPUT} \
	  -lca -kdb \
	  -P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a \
 
 
WAVE = verdi -simflow -top ${TB_TOP_MODULE} -ssf ${FSDB_FILE} -l sim.log &
 
 
 
REPORT_CM = urg -dir ./${OUTPUT}.vdb -format both -report ./cm_report
 
all: elab wave

anvlog:
	${ANVLG}
 
elab:
	${ELAB}
 
 
 
wave:
	${WAVE}
 
report_cm:
	${REPORT_CM}
 
 
print-%  : ; @echo $* = $($*)
 
 
clean:
	rm -rf ./csrc DVEfiles simv* *.vpd *.key *.log *.vpd novas* *.fsdb verdiLog \
	cm_report*
	find ./work -type f -exec rm -f {} \;
