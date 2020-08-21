"""
y − y0 = m(x − x0)
(x0, y0) = (floor^(1/n), y(floor^(1/n)))
(x0, y0) = (floor^(1/n), floor - A)
y = 0
− y0 = mx − mx0
x = x0 - y0/m
m = y'(x0) = n*x0^(n-1) = n*floor^((n-1)/n)
x = floor^(1/n) - (floor - A)/m
x = floor^(1/n) - floor/m + A/m
x = floor^(1/n)(n-1)/n + A/(n*floor^((n-1)/n))
"""
def initial_value_function(n):
    print(f"""
    function _getInitialValue{n}(uint256 base) internal pure returns (uint256) {{
        if (base < 11 * 10**17) return (base + {n - 1} * FIXED_1) / {n};
        else if (base < 12 * 10**17) return {1.1**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 1.1**((n-1)/n) * 10**18:.0f};
        else if (base < 13 * 10**17) return {1.2**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 1.2**((n-1)/n) * 10**18:.0f};
        else if (base < 14 * 10**17) return {1.3**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 1.3**((n-1)/n) * 10**18:.0f};
        else if (base < 15 * 10**17) return {1.4**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 1.4**((n-1)/n) * 10**18:.0f};
        else if (base < 16 * 10**17) return {1.5**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 1.5**((n-1)/n) * 10**18:.0f};
        else if (base < 17 * 10**17) return {1.6**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 1.6**((n-1)/n) * 10**18:.0f};
        else if (base < 18 * 10**17) return {1.7**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 1.7**((n-1)/n) * 10**18:.0f};
        else if (base < 19 * 10**17) return {1.8**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 1.8**((n-1)/n) * 10**18:.0f};
        else if (base < 2 * 10**18) return {1.9**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 1.9**((n-1)/n) * 10**18:.0f};
        else if (base < 5 * 10**18) return {2.0**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 2.0**((n-1)/n) * 10**18:.0f};
        else if (base < 10 * 10**18) return {5**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 5**((n-1)/n) * 10**18:.0f};
        else if (base < 50 * 10**18) return {10**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 10**((n-1)/n) * 10**18:.0f};
        else if (base < 10**20) return {50**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 50**((n-1)/n) * 10**18:.0f};
        else if (base < 10**21) return {100**(1/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 100**((n-1)/n) * 10**18:.0f};
        else if (base < 10**22) return {10**(3/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 10**(3*(n-1)/n) * 10**18:.0f};
        else if (base < 10**23) return {10**(4/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 10**(4*(n-1)/n) * 10**18:.0f};
        else if (base < 10**24) return {10**(5/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 10**(5*(n-1)/n) * 10**18:.0f};
        else if (base < 10**27) return {10**(6/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 10**(6*(n-1)/n) * 10**18:.0f};
        else if (base < 10**30) return {10**(9/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 10**(9*(n-1)/n) * 10**18:.0f};
        else return {10**(12/n) * (n-1) / n * 10**18:.0f} + base * FIXED_1 / {n * 10**(12*(n-1)/n) * 10**18:.0f};
    }}""")

for i in range(2, 11):
    initial_value_function(i)
