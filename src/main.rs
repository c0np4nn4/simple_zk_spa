use serde_json::json;
use std::collections::HashMap;
use std::fs::{self, File};
use std::io::Write;

#[derive(Debug, Clone)]
enum OperationType {
    NoOp,
    Assign,
    Summation,
    Divide,
}

#[derive(Debug, Clone)]
struct ParsedOperation {
    operation_type: OperationType,
    lhs_variable: i64,
    var_or_val_1: i64,
    var_or_val_2: i64,
}

fn parse_rust_code(code: &str) -> (HashMap<String, i64>, Vec<ParsedOperation>) {
    let mut var_env: HashMap<String, i64> = HashMap::new();
    let mut operations: Vec<ParsedOperation> = vec![];
    let mut var_index = 1;

    for line in code.lines() {
        let line = line.trim();

        if line.starts_with("let") {
            let parts: Vec<&str> = line.split_whitespace().collect();

            // Ensure parts are valid and the variable type is correctly ignored
            if parts.len() >= 4 && parts[0] == "let" && parts[1].ends_with(":") {
                // 변수명에서 ':' 제거
                let lhs_var = parts[1].trim_end_matches(':').to_string();

                // Track the variable with an odd index
                let lhs_index = var_index;
                var_env.insert(lhs_var.clone(), lhs_index);
                var_index += 2;

                // Parsing assignment expressions
                if line.contains('=') {
                    let rhs_expression =
                        line.split('=').nth(1).unwrap().trim_end_matches(';').trim();
                    let rhs_parts: Vec<&str> = rhs_expression.split_whitespace().collect();

                    if rhs_parts.len() == 1 {
                        // Assign operation (e.g., let a: i64 = 10;)
                        let value = get_var_or_val(rhs_parts[0], &var_env);
                        operations.push(ParsedOperation {
                            operation_type: OperationType::Assign,
                            lhs_variable: lhs_index,
                            var_or_val_1: value,
                            var_or_val_2: 0,
                        });
                    } else if rhs_parts.len() == 3 {
                        // Handle summation and division (e.g., let z: i64 = x + y;)
                        let op = rhs_parts[1];
                        let var_or_val_1 = get_var_or_val(rhs_parts[0], &var_env);
                        let var_or_val_2 = get_var_or_val(rhs_parts[2], &var_env);

                        match op {
                            "+" => operations.push(ParsedOperation {
                                operation_type: OperationType::Summation,
                                lhs_variable: lhs_index,
                                var_or_val_1,
                                var_or_val_2,
                            }),
                            "/" => operations.push(ParsedOperation {
                                operation_type: OperationType::Divide,
                                lhs_variable: lhs_index,
                                var_or_val_1,
                                var_or_val_2,
                            }),
                            _ => operations.push(ParsedOperation {
                                operation_type: OperationType::NoOp,
                                lhs_variable: 0,
                                var_or_val_1: 0,
                                var_or_val_2: 0,
                            }),
                        }
                    } else {
                        operations.push(ParsedOperation {
                            operation_type: OperationType::NoOp,
                            lhs_variable: 0,
                            var_or_val_1: 0,
                            var_or_val_2: 0,
                        });
                    }
                }
            }
        }
    }

    (var_env, operations)
}

fn parse_value(value: &str) -> i64 {
    value.parse::<i64>().unwrap_or(0) * 2
}

fn get_var_or_val(token: &str, var_env: &HashMap<String, i64>) -> i64 {
    if let Some(&val) = var_env.get(token) {
        val
    } else {
        parse_value(token)
    }
}

fn main() {
    let file_path = "example.rs";

    let code = fs::read_to_string(file_path).expect("Failed to read the file");

    let (var_env, operations) = parse_rust_code(&code);

    let parsed_program: Vec<Vec<i64>> = operations
        .iter()
        .map(|op| match op.operation_type {
            OperationType::Assign => vec![1, op.lhs_variable, op.var_or_val_1, 0],
            OperationType::Summation => vec![2, op.lhs_variable, op.var_or_val_1, op.var_or_val_2],
            OperationType::Divide => vec![3, op.lhs_variable, op.var_or_val_1, op.var_or_val_2],
            OperationType::NoOp => vec![0, 0, 0, 0],
        })
        .collect();

    let output = json!({
        "var_env": var_env,
        "syntax_tree": parsed_program,
    });

    let mut file = File::create("result.json").expect("Failed to create file");
    file.write_all(output.to_string().as_bytes())
        .expect("Failed to write to file");

    println!("Parsing completed. Result saved to result.json.");
}
