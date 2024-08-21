pragma circom 2.1.9;

include "SafeInverse.circom";

template DivisionComponent() {
    signal input is_division;
    signal input is_lhs;
    signal input lhs_value;
    signal input rhs_value;
    signal output division_result;

    component inv_calculator = SafeInverse();
    inv_calculator.in <== rhs_value;

    signal tmp;
    tmp <== lhs_value * inv_calculator.out;

    signal adjusted_division;
    adjusted_division <== is_lhs * tmp;

    division_result <== is_division * adjusted_division;
}
