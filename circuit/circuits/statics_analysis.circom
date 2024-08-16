pragma circom 2.1.9;

template Statics_analysis() {
    signal input syntax_tree[4][4];
    signal output vari[4][4];
    vari <== syntax_tree;
}

component main = Statics_analysis();
