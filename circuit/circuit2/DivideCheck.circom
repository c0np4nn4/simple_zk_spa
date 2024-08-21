pragma circom 2.1.9;

template assign() // 할당 연산(1)이면 1 나머지는 0
{
    signal input asin;
    signal asinter;
    signal output asout;
    asinter <-- asin==1?1:0;
    asout <== asinter;
}

template additional() // 덧셈 연산 (2)이면 1 나머지는 0
{
    signal input adin;
    signal adinter;
    signal output adout;
    adinter <-- adin==2?1:0;
    adout <== adinter;
}

template mutiplication() // 곱셈 연산 (3)이면 1 나머지는 0
{
    signal input mpin;
    signal mpinter;
    signal output mpout;
    mpinter <-- mpin==3?1:0;
    mpout <== mpinter;
}

template check_constant() // 어떤 값이 변수라면 1 상수라면 0
{
    signal input ccin;
    signal ccinter;
    signal output ccout;
    ccinter <-- (ccin<0)?(ccin+1)%2:ccin%2; // 음수 일때는 modulo로 표현되어서 +1 해줘야 원래 홀짝성과 같다
    ccout <== ccinter;
}

template DivideCheck(n)
{
    signal input syntax_tree[n][4]; // 입력 값
    signal output safe; // 출력 값
    signal output dk[16];
    signal safe_checker[17]; // i번째 줄 코드까지의 검사 결과
    var variable[17]; // 변수 값 저장 / 코드 16줄을 받으니 변수는 최대 16개 / 쓰레기 값들을 0번째 index로 보내기 위해 17로 선언 // 양수는 1 음수는 3 T는 7 // 계산의 편리성을 위해 이렇게 둔다
    for (var i = 0; i < 16; i++)
    {
        variable[i] = 0; // 변수들 초기값 설정
    }
    safe_checker[0] <-- 1; // 코드의 초기 상태는 안전하다고 설정
    component as[16]; component ad[16]; component mp[16]; component cc[16][2]; // 각 줄의 연산을 위한 컴포넌트 선언
    for ( var i = 0; i < 16; i++) // 한 줄 씩 분석
    {
        as[i]=assign(); as[i].asin <== syntax_tree[i][0]; // 할당 연산인지 체크
        ad[i]=additional(); ad[i].adin <== syntax_tree[i][0]; // 덧셈 연산인지 체크
        mp[i]=mutiplication(); mp[i].mpin <== syntax_tree[i][0]; // 곱셈 연산인지 체크
        var check_variable; check_variable = syntax_tree[i][1]%2; // 변수/상수 체크하는 변수 // 변수라면 1 상수라면 0 // 사실 (0, 0, 0, 0) 거르기 위해서 존재
        var which_variable; which_variable = (syntax_tree[i][1]+1)/2; which_variable=which_variable*check_variable; // 각 변수 구분 ex) 1 => 1, 3 => 2, 5 => 3 ...
        variable[which_variable] = variable[which_variable]+as[i].asout*(syntax_tree[i][2]>0?1:(syntax_tree[i][2]<0?3:7)); // 할당 연산 양수라면 1 // 음수라면 3 // T라면 7
        cc[i][0]=check_constant(); cc[i][0].ccin <== syntax_tree[i][2]; // 할당 연산이 아닌 경우를 대비하여 좌항 원소의 변수/상수 체크
        cc[i][1]=check_constant(); cc[i][1].ccin <== syntax_tree[i][3]; // 할당 연산이 아닌 경우를 대비하여 우항 원소의 변수/상수 체크
        var lhs; lhs=cc[i][0].ccout==1?variable[(syntax_tree[i][2]+1)/2]:4; // 좌항 원소, 변수라면 변수값 대입 // 상수라면 일단 4
        lhs=lhs==4?(syntax_tree[i][2]>0?1:4):lhs; // 좌항 원소, 양수라면 1 대입 // 아니라면 일단 4
        lhs=lhs==4?(syntax_tree[i][2]<0?3:7):lhs; // 좌항 원소, 음수라면 3 대입 // 아니라면 7
        var rhs; rhs=cc[i][1].ccout==1?variable[(syntax_tree[i][3]+1)/2]:4; // 우항 원소, 변수라면 변수값 대입 // 상수라면 일단 4
        rhs=rhs==4?(syntax_tree[i][3]>0?1:4):rhs; // 우항 원소, 양수라면 1 대입 // 아니라면 일단 4
        rhs=rhs==4?(syntax_tree[i][3]<0?3:7):rhs; // 우항 원소, 음수라면 3 대입 // 아니라면 7
        variable[which_variable] = variable[which_variable]+ad[i].adout*((lhs+rhs)==2?1:(lhs+rhs==6?3:7)); // 덧셈 연산 양수+양수는 1 // 음수+음수는 3 // 나머지는 T(7)
        variable[which_variable] = variable[which_variable]+mp[i].mpout*((lhs+rhs)==4?3:(lhs+rhs<7?1:7)); // 곱셈 연산 양수*양수, 음수*음수는 1 // 양수*음수는 3 // 나머지는 T(7)
        var middle_checker = mp[i].mpout==1?(rhs==7?0:1):1;
        safe_checker[i+1] <-- safe_checker[i]*middle_checker;
    }
    safe <== safe_checker[16]; // 마지막 줄까지 분석한 결과 대입
    safe === 1; // safe==1 즉, 안전해야한다는 제약 // 안전하지 않으면 증명이 만들어지지 못한다.
}