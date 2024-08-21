pragma circom 2.1.9;

// Assign 연산을 처리하는 컴포넌트
template AssignComponent() {
    signal input is_assign;
    signal input is_lhs;
    signal input rhs_value;
    signal output assign_result;

    signal tmp <== is_lhs * rhs_value;
    assign_result <== is_assign * tmp;
}
