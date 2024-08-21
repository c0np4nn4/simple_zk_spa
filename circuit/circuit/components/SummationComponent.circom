pragma circom 2.1.9;

// Summation 연산을 처리하는 컴포넌트
template SummationComponent() {
    signal input is_summation;
    signal input is_lhs;
    signal input lhs_value;
    signal input rhs1_value;
    signal input rhs2_value;
    signal output summation_result;

    signal tmp_sum1;
    signal tmp_sum2;
    tmp_sum1 <== lhs_value + rhs1_value;
    tmp_sum2 <== tmp_sum1 + rhs2_value;

    signal tmp <== is_lhs * tmp_sum2;
    summation_result <== is_summation * tmp;
}
