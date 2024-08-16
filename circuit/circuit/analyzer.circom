pragma circom 2.1.8;

template DivideCheck(n) {
    signal input syntax_tree[n][4];  // n x 4 크기의 syntax_tree 입력
    signal output safe;              // 안전 여부 출력 (1: safe, 0: unsafe)

    signal check_division[n];        // 현재 연산이 division(3)인지 확인
    signal check_t_value[n];         // 네 번째 값이 T인지 확인 (1인지 확인)

    // 중간 계산 결과를 저장할 신호
    signal intermediate_is_safe[n + 1];
    intermediate_is_safe[0] <== 1;    // 초기값을 1로 설정

    // 안전 여부 결정: division인데 T 값이 아닌 경우는 unsafe (0)
    signal intermediate_not_safe[n];
    for (var i = 0; i < n; i++) {
        // operation type이 3인 경우를 확인 (syntax_tree[i][0] == 3)
        check_division[i] <== 1 - (syntax_tree[i][0] - 3) * (syntax_tree[i][0] - 3);

        // 네 번째 값이 1인지 확인 (syntax_tree[i][3] == 1)
        check_t_value[i] <== 1 - (syntax_tree[i][3] - 1) * (syntax_tree[i][3] - 1);

        // 중간 not_safe 값을 계산하여 배열에 저장
        intermediate_not_safe[i] <== check_division[i] * (1 - check_t_value[i]);

        // intermediate_is_safe 값 갱신
        intermediate_is_safe[i + 1] <== intermediate_is_safe[i] * (1 - intermediate_not_safe[i]);
    }

    // 최종 안전 여부를 final_is_safe로 전달
    signal final_is_safe;
    final_is_safe <== intermediate_is_safe[n];

    // 결과를 is_safe에 할당
    safe <== final_is_safe;
}

component main = DivideCheck(16);
