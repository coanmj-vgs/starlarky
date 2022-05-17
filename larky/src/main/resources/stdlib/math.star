load("@stdlib//larky", "larky")
load("@stdlib//c99math", _c99math="c99math")


pi = _c99math.PI
pow = _c99math.pow
sqrt = _c99math.sqrt
fabs = _c99math.fabs
ceil = _c99math.ceil
log = _c99math.log
floor = _c99math.floor


def gcd(x, y):
    term = int(y)
    r_p, r_n = abs(x), abs(term)
    for _while_ in range(larky.WHILE_LOOP_EMULATION_ITERATION):
        if r_n <= 0:
            break
        q = r_p // r_n
        r_p, r_n = r_n, r_p - q * r_n
    return r_p


math = larky.struct(
    __name__='math',
    pi=pi,
    pow=pow,
    sqrt=sqrt,
    fabs=fabs,
    ceil=ceil,
    log=log,
    floor=floor,
    gcd=gcd,
)
