pragma circom 2.1.9;

template SafeInverse() {
    signal input x;
    signal output inv_x;

    // 역원 계산이 가능한지 체크 (0이 아니어야 함)
    signal is_non_zero;
    is_non_zero <== x == 0 ? 0 : 1;

    // x * inv_x == is_non_zero 조건을 추가
    inv_x * x === is_non_zero;

    // 만약 x가 0이면 inv_x를 0으로 강제
    inv_x <== is_non_zero * inv_x;
}
