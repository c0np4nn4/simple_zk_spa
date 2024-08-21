pragma circom 2.1.9;


include "components/AssignComponent.circom";
include "components/SummationComponent.circom";
include "components/DivisionComponent.circom";

template DivideCheck(n) {
    signal input syntax_tree[n][4];
    signal output safe;

    signal tracked_values[16];

    for (var i = 0; i < 16; i++) {
        tracked_values[i] <== 0;
    }

    signal is_assign[n];
    signal is_summation[n];
    signal is_division[n];
    signal is_lhs[16][n];
    signal is_rhs1[16][n];
    signal is_rhs2[16][n];
    signal is_rhs2_zero[n];
    signal is_rhs2_top[n];
    signal rhs2_is_zero;
    signal rhs2_is_top;

    signal tmp_lhs;
    signal tmp_rhs1;
    signal tmp_rhs2;

    signal assign_result;
    signal summation_result;
    signal division_result;

    signal tmp_check_zero;
    signal tmp_check_top;

    component assign = AssignComponent();
    component summation = SummationComponent();
    component division = DivisionComponent();

    for (var i = 0; i < n; i++) {
        is_assign[i] <== 1 - (syntax_tree[i][0] - 1) * (syntax_tree[i][0] - 1);
        is_summation[i] <== 1 - (syntax_tree[i][0] - 2) * (syntax_tree[i][0] - 2);
        is_division[i] <== 1 - (syntax_tree[i][0] - 3) * (syntax_tree[i][0] - 3);

        for (var j = 0; j < 16; j++) {
            tmp_lhs <== syntax_tree[i][1] - (j * 2 + 1);
            tmp_rhs1 <== syntax_tree[i][2] - (j * 2 + 1);
            tmp_rhs2 <== syntax_tree[i][3] - (j * 2 + 1);

            is_lhs[j][i] <== 1 - tmp_lhs * tmp_lhs;
            is_rhs1[j][i] <== 1 - tmp_rhs1 * tmp_rhs1;
            is_rhs2[j][i] <== 1 - tmp_rhs2 * tmp_rhs2;

            assign.is_assign <== is_assign[i];
            assign.is_lhs <== is_lhs[j][i];
            assign.rhs_value <== syntax_tree[i][2];
            assign_result <== assign.assign_result;

            summation.is_summation <== is_summation[i];
            summation.is_lhs <== is_lhs[j][i];
            summation.lhs_value <== tracked_values[j];
            summation.rhs1_value <== is_rhs1[j][i] * tracked_values[j];
            summation.rhs2_value <== is_rhs2[j][i] * tracked_values[j];
            summation_result <== summation.summation_result;

            division.is_division <== is_division[i];
            division.is_lhs <== is_lhs[j][i];
            division.lhs_value <== tracked_values[j];
            division.rhs_value <== is_rhs2[j][i] * tracked_values[j];
            division_result <== division.division_result;

            tracked_values[j] <== assign_result + summation_result + division_result + (1 - is_lhs[j][i]) * tracked_values[j];
        }

        rhs2_is_zero <== 0;
        rhs2_is_top <== 0;

        for (var k = 0; k < 16; k++) {
            tmp_check_zero <== is_rhs2[k][i] * (tracked_values[k] == 0 ? 1 : 0);
            tmp_check_top <== is_rhs2[k][i] * (tracked_values[k] == 3 ? 1 : 0);

            rhs2_is_zero <== rhs2_is_zero + tmp_check_zero;
            rhs2_is_top <== rhs2_is_top + tmp_check_top;
        }

        is_rhs2_zero[i] <== rhs2_is_zero;
        is_rhs2_top[i] <== rhs2_is_top;

        assert(is_division[i] * (1 - is_rhs2_zero[i]) * (1 - is_rhs2_top[i]) == 1);
    }

    safe <== 1;
}

