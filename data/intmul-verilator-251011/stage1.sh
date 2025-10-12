rm -rf collected-results
unzip collected-results.zip
WORK_DIR="$(pwd)"
SOURCE_LOG_DIR="${WORK_DIR}/data/intmul-verilator-251011/collected-results"
rm -rf rv32_mpise_*
rm -rf rv64_mpise_*
rm -rf source-logs
mkdir source-logs

TARGET_LIST="rv32_mpise_00 rv32_mpise_01 rv32_mpise_10 rv32_mpise_11 rv64_mpise_00 rv64_mpise_01 rv64_mpise_10 rv64_mpise_11"
for t in ${TARGET_LIST};
do
	mkdir -p source-logs/$t/cva6-logs
	cp ${SOURCE_LOG_DIR}/$t/out_2025-10-10/veri-testharness-pk_sim/*.log.iss source-logs/$t/cva6-logs
	cp ${SOURCE_LOG_DIR}/$t/out_2025-10-11/veri-testharness-pk_sim/*.log.iss source-logs/$t/cva6-logs
done
#
