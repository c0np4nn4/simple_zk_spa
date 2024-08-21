pragma circom 2.1.9;

include "components/AssignComponent.circom";
include "components/SummationComponent.circom";
include "components/DivisionComponent.circom";

template DivideCheck(n) {
    signal input syntax_tree[n][4];
    signal output safe;

    signal tracked_values[16][n + 1]; // 각 단계별 값을 저장하기 위한 2D 배열

    for (var i = 0; i < 16; i++) {
        tracked_values[i][0] <== 0; // 초기값 설정
    }

    signal is_assign[n];
    signal is_summation[n];
    signal is_division[n];
    signal is_lhs[16][n];
    signal is_rhs1[16][n];
    signal is_rhs2[16][n];
    signal is_rhs2_zero[16];
    signal is_rhs2_top[16];
    signal rhs2_is_zero[n]; // 반복문 내에서 매 단계별로 값을 저장할 배열
    signal rhs2_is_top[n];  // 반복문 내에서 매 단계별로 값을 저장할 배열

    signal tmp_lhs[16][n];
    signal tmp_rhs1[16][n];
    signal tmp_rhs2[16][n];

    signal assign_result[16];
    signal summation_result[16];
    signal division_result[16];

    signal tmp_check_zero[16];
    signal tmp_check_top[16];

    component assign[16];
    component summation[16];
    component division[16];

    for (var j = 0; j < 16; j++) {
        assign[j] = AssignComponent();
        summation[j] = SummationComponent();
        division[j] = DivisionComponent();
    }


    signal previous_accum_zero[16];
    signal previous_accum_top[16];

    signal tmp_tmp_check_zero[16];
    signal tmp_tmp_check_top[16];

    for (var i = 0; i < n; i++) {
        is_assign[i] <== 1 - (syntax_tree[i][0] - 1) * (syntax_tree[i][0] - 1);
        is_summation[i] <== 1 - (syntax_tree[i][0] - 2) * (syntax_tree[i][0] - 2);
        is_division[i] <== 1 - (syntax_tree[i][0] - 3) * (syntax_tree[i][0] - 3);

        for (var j = 0; j < 16; j++) {
            tmp_lhs[j][i] <== syntax_tree[i][1] - (j * 2 + 1);
            tmp_rhs1[j][i] <== syntax_tree[i][2] - (j * 2 + 1);
            tmp_rhs2[j][i] <== syntax_tree[i][3] - (j * 2 + 1);

            is_lhs[j][i] <== 1 - tmp_lhs[j][i] * tmp_lhs[j][i];
            is_rhs1[j][i] <== 1 - tmp_rhs1[j][i] * tmp_rhs1[j][i];
            is_rhs2[j][i] <== 1 - tmp_rhs2[j][i] * tmp_rhs2[j][i];

            assign[j].is_assign <== is_assign[i];
            assign[j].is_lhs <== is_lhs[j][i];
            assign[j].rhs_value <== syntax_tree[i][2];
            assign_result[j] <== assign[j].assign_result;

            summation[j].is_summation <== is_summation[i];
            summation[j].is_lhs <== is_lhs[j][i];
            summation[j].lhs_value <== tracked_values[j][i];
            summation[j].rhs1_value <== is_rhs1[j][i] * tracked_values[j][i];
            summation[j].rhs2_value <== is_rhs2[j][i] * tracked_values[j][i];
            summation_result[j] <== summation[j].summation_result;

            division[j].is_division <== is_division[i];
            division[j].is_lhs <== is_lhs[j][i];
            division[j].lhs_value <== tracked_values[j][i];
            division[j].rhs_value <== is_rhs2[j][i] * tracked_values[j][i];
            division_result[j] <== division[j].division_result;

            tracked_values[j][i + 1] <== assign_result[j] + summation_result[j] + division_result[j] + (1 - is_lhs[j][i]) * tracked_values[j][i];
        }


        for (var k = 0; k < 16; k++) {
            tmp_tmp_check_zero[k] <== 1 - (tracked_values[k][i + 1] * tracked_values[k][i + 1]);
            tmp_check_zero[k] <== is_rhs2[k][i] * tmp_tmp_check_zero[k];

            tmp_tmp_check_top[k] <== 1 - (tracked_values[k][i + 1] - 3 * tracked_values[k][i + 1] - 3);
            tmp_check_top[k] <== is_rhs2[k][i] * tmp_tmp_check_top[k];

            if (k == 0) {
                previous_accum_zero[k] <== tmp_check_zero[k];
                previous_accum_top[k] <== tmp_check_top[k];
            } else {
                previous_accum_zero[k] <== previous_accum_zero[k - 1] + tmp_check_zero[k];
                previous_accum_top[k] <== previous_accum_top[k - 1] + tmp_check_top[k];
            }
        }

        rhs2_is_zero[i] <== previous_accum_zero[15];
        rhs2_is_top[i] <== previous_accum_top[15];

        is_rhs2_zero[i] <== rhs2_is_zero[i];
        is_rhs2_top[i] <== rhs2_is_top[i];

        assert(is_division[i] * (1 - is_rhs2_zero[i]) * (1 - is_rhs2_top[i]) == 1);
    }

    safe <== 1;
}

