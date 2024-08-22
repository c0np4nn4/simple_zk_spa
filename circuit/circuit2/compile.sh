cd ..
cd ..
cd parser
cargo run
cd ..
cd circuit/circuit2
circom main.circom --r1cs --wasm --sym -l components/
result_json_path="/mnt/c/Users/taotr/simple_zk_spa/parser/result.json"
node main_js/generate_witness.js main_js/main.wasm "$result_json_path" witness.wtns