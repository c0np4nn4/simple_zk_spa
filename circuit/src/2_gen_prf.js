const snarkjs = require("snarkjs");
const fs = require("fs");

async function proof_generator() {
  // JSON 파일을 입력으로 사용
  const input = JSON.parse(fs.readFileSync("../parser/result.json"));

  // SnarkJS를 이용해 증명 생성
  const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    input,
    "./circuit/circuit_js/circuit.wasm",
    "./keys/circuit_final.zkey"
  );

  fs.writeFileSync("./proof.json", JSON.stringify(proof, null, 2));
  fs.writeFileSync("./publicInputSignals.json", JSON.stringify(publicSignals, null, 2));

  // publicSignals에서 safe 값을 확인
  console.log("Public Signal - Safe:", publicSignals[0]); // safe 값이 publicSignals[0]에 저장됨
  console.log("Proof & publicInput Generated!");
}

proof_generator().then(() => {
  process.exit(0);
});

