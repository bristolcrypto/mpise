#include <stdio.h>

#define ROL32(x,n) (((x << (n)) & 0x00000000FFFFFFFF) | ((x & 0x00000000FFFFFFFF) >> (32 - (n))))
#define ROR32(x,n) (((x & 0x00000000FFFFFFFF) >> (n)) | ((x << (32 - (n))) & 0x00000000FFFFFFFF))
#define ROL64(x,n) (((x) << (n)) | ((x) >> (64 - (n))))
#define ROR64(x,n) (((x) >> (n)) | ((x) << (64 - (n))))

static uint64_t lfsr(uint64_t x)
{
  uint64_t bit = (x ^ (x >> 1)) & 1;
  return (x >> 1) | (bit << 62);
}

extern uint64_t test_maddhu(uint64_t a, uint64_t b, uint64_t c);
extern uint64_t test_maddlu(uint64_t a, uint64_t b, uint64_t c);
extern uint64_t test_maddu(uint64_t a, uint64_t b, uint64_t* c);

uint64_t gold_maddhu(uint64_t a, uint64_t b, uint64_t c){
    unsigned __int128 m = (__uint128_t) a * (__uint128_t) b;
    uint64_t r = (m>>64) + c;
    return r;
}

uint64_t gold_maddlu(uint64_t a, uint64_t b, uint64_t c){
    uint64_t r = (a * b) + c;
    return r;
}

uint64_t gold_maddu(uint64_t a, uint64_t b, uint64_t * c){
    unsigned __int128 m = (__uint128_t) a * (__uint128_t) b + (__uint128_t) *c;
    uint64_t r = (uint64_t)m;
    *c = (m >>64); 
    return r;
}

int main() {
    
    int fail = 0;  

    uint64_t lhs = 0xABCDEF0123456789; 
    uint64_t rhs = 0xCAFECAFEDEADBEAD;

    uint64_t r3 = 0x0000000000000007;

    printf("# RV64 ISE Instruction Test \n");

    test_maddhu(lhs, rhs,r3);
    test_maddlu(lhs, rhs,r3);

    for (uint64_t i=0;i<5;i++){

    printf("\nlhs: %llx, rhs: %llx\n", lhs, rhs);
     
    // maddhu    
    uint64_t result = test_maddhu(lhs, rhs, i);
    uint64_t expect = gold_maddhu(lhs, rhs, i);

    if(result != expect) {
        printf("test_maddhu [FAIL]\n");
        printf("Expected: %llx, got: %llx\n", expect, result);
        fail = 1;
    }

    // maddlu
    result = test_maddlu(lhs, rhs, i);
    expect = gold_maddlu(lhs, rhs, i);

    if(result != expect) {
        printf("test_maddlu [FAIL]\n");
        printf("Expected: %llx, got: %llx\n", expect, result);
        fail = 1;
    }

    // maddu
    uint64_t ct = r3;
    uint64_t cg = r3;

    result = test_maddu(lhs, rhs, &ct);    
    expect = gold_maddu(lhs, rhs, &cg);

    if(result != expect) {
        printf("test_maddu LSB [FAIL]\n");
        printf("Expected: %llx, got: %llx\n", expect, result);
        fail = 1;
    }

    if(ct != cg) {
        printf("test_maddu MSB [FAIL]\n");
        printf("Expected: %llx, got: %llx\n", cg, ct);
        fail = 1;
    }
    rhs = lfsr(lhs);
    lhs = lfsr(rhs);
    r3  = lfsr(r3);
    }
    return fail;

}

