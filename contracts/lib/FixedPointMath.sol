pragma solidity ^0.4.24;

import "@aragon/os/contracts/lib/math/SafeMath.sol";


library FixedPointMath {
    using SafeMath for uint256;

    uint256 private constant FIXED_1 = 10**18;

    function multiplyFixed(uint256 a, uint256 b) internal pure returns (uint256 result) {
        uint256 aInt = integer(a);
        uint256 aFrac = fractional(a);
        uint256 bInt = integer(b);
        uint256 bFrac = fractional(b);

        result = aInt.mul(bInt).mul(FIXED_1);
        result = result.add(aInt.mul(bFrac));
        result = result.add(aFrac.mul(bInt));
        result = result.add(aFrac.mul(bFrac) / FIXED_1);
    }

    function divideFixed(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mul(FIXED_1) / b;
    }

    function powFixed(uint256 base, uint256 exp) internal pure returns (uint256 result) {
        if (exp == 0) {
            return 1;
        }
        if (exp == 1) {
            return base;
        }
        uint256 tmp = base;
        uint256 n = exp;
        while(result == 0 && tmp > 0) {
            if (n & 1 > 0) {
                result = tmp;
            }
            n = n >> 1;
            tmp = multiplyFixed(tmp, tmp);
        }
        while (n > 0 && result > 0) {
            if (n & 1 > 0) {
                result = multiplyFixed(result, tmp);
            }
            n = n >> 1;
            tmp = multiplyFixed(tmp, tmp);
        }
    }

    /*
     * This uses the nth-root algorithm based on Newton's method for finding zeroes.
     * See: https://en.wikipedia.org/wiki/Nth_root_algorithm
     * Initial value is the image of the tangent line to the curve y = x^(1/n)
     * which passes by the point (1, 1)
     * This line is always over, as the derivative of that curve is decreasing from x=1 on
     * Therefore the initial value will always be bigger than the sought value,
     * which seems to behave better for these family of curves.
     */
    function rootFixed(uint256 base, uint256 n, uint256 errorThreshold) internal pure returns (uint256) {
        uint256 initialValue = _getInitialValue(base, n);
        return _rootIteration(base, n, initialValue, errorThreshold);
    }

    function _rootIteration(uint256 base, uint256 n, uint256 previous, uint256 errorThreshold) private pure returns (uint256) {
        // TODO: try to do base / previous.mul(powFixed(previous, n - 2))
        uint256 delta1 = divideFixed(base, powFixed(previous, n - 1));
        bool deltaPositive = false;
        uint256 delta;
        if (delta1 < previous) {
            delta = (previous - delta1) / n;
        } else {
            deltaPositive = true;
            delta = (delta1 - previous) / n;
        }

        uint256 result = deltaPositive ? previous + delta : previous - delta;
        if (delta < errorThreshold) {
            return result;
        }

        return _rootIteration(base, n, result, errorThreshold);
    }

    function rootFixed2(uint256 base, uint256 n, uint256 N, uint256 errorThreshold) internal pure returns (uint256 result) {
        uint256 previous = _getInitialValue(base, n);
        for (uint256 i = 0; i < N; i++) {
            uint256 pow = powFixed(previous, n - 1);
            uint256 delta1 = divideFixed(base, pow);
            bool deltaPositive = false;
            uint256 delta;
            if (delta1 < previous) {
                delta = (previous - delta1) / n;
            } else {
                deltaPositive = true;
                delta = (delta1 - previous) / n;
            }

            result = deltaPositive ? previous + delta : previous - delta;
            if (delta < errorThreshold) {
                return result;
            }
            previous = result;
        }
    }

    function integer(uint256 a) internal pure returns (uint256) {
        return a / FIXED_1;
    }

    function fractional(uint256 a) internal pure returns (uint256) {
        return a % FIXED_1;
    }

    function _getInitialValue(uint256 base, uint n) internal pure returns (uint256) {
        if (n == 2) return _getInitialValue2(base);
        else if (n == 3) return _getInitialValue3(base);
        else if (n == 4) return _getInitialValue4(base);
        else if (n == 5) return _getInitialValue5(base);
        else if (n == 6) return _getInitialValue6(base);
        else if (n == 7) return _getInitialValue7(base);
        else if (n == 8) return _getInitialValue8(base);
        else if (n == 9) return _getInitialValue9(base);
        else if (n == 10) return _getInitialValue10(base);
        // default
        else return (base + (n - 1) * FIXED_1) / n;

    }

    function _getInitialValue2(uint256 base) internal pure returns (uint256) {
        if (base < 11 * 10**17) return (base + 1 * FIXED_1) / 2;
        else if (base < 12 * 10**17) return 524404424085075840 + base * FIXED_1 / 2097617696340303360;
        else if (base < 13 * 10**17) return 547722557505166080 + base * FIXED_1 / 2190890230020664320;
        else if (base < 14 * 10**17) return 570087712549569024 + base * FIXED_1 / 2280350850198276096;
        else if (base < 15 * 10**17) return 591607978309961600 + base * FIXED_1 / 2366431913239846400;
        else if (base < 16 * 10**17) return 612372435695794432 + base * FIXED_1 / 2449489742783177728;
        else if (base < 17 * 10**17) return 632455532033675904 + base * FIXED_1 / 2529822128134703616;
        else if (base < 18 * 10**17) return 651920240520264832 + base * FIXED_1 / 2607680962081059328;
        else if (base < 19 * 10**17) return 670820393249936896 + base * FIXED_1 / 2683281572999747584;
        else if (base < 2 * 10**18) return 689202437604511104 + base * FIXED_1 / 2756809750418044416;
        else if (base < 5 * 10**18) return 707106781186547584 + base * FIXED_1 / 2828427124746190336;
        else if (base < 10 * 10**18) return 1118033988749894912 + base * FIXED_1 / 4472135954999579648;
        else if (base < 50 * 10**18) return 1581138830084189696 + base * FIXED_1 / 6324555320336758784;
        else if (base < 10**20) return 3535533905932737536 + base * FIXED_1 / 14142135623730950144;
        else if (base < 10**21) return 5000000000000000000 + base * FIXED_1 / 20000000000000000000;
        else if (base < 10**22) return 15811388300841895936 + base * FIXED_1 / 63245553203367583744;
        else if (base < 10**23) return 50000000000000000000 + base * FIXED_1 / 200000000000000000000;
        else if (base < 10**24) return 158113883008418971648 + base * FIXED_1 / 632455532033675886592;
        else if (base < 10**27) return 500000000000000000000 + base * FIXED_1 / 2000000000000000000000;
        else if (base < 10**30) return 15811388300841896116224 + base * FIXED_1 / 63245553203367584464896;
        else return 499999999999999991611392 + base * FIXED_1 / 1999999999999999966445568;
    }

    function _getInitialValue3(uint256 base) internal pure returns (uint256) {
        if (base < 11 * 10**17) return (base + 2 * FIXED_1) / 3;
        else if (base < 12 * 10**17) return 688186743637578112 + base * FIXED_1 / 3196806710299831808;
        else if (base < 13 * 10**17) return 708439046121740800 + base * FIXED_1 / 3387729703971702272;
        else if (base < 14 * 10**17) return 727595255374070656 + base * FIXED_1 / 3573415275589298176;
        else if (base < 15 * 10**17) return 745792628054264448 + base * FIXED_1 / 3754394847405583360;
        else if (base < 16 * 10**17) return 763142828368887936 + base * FIXED_1 / 3931112091313344512;
        else if (base < 17 * 10**17) return 779738063523431040 + base * FIXED_1 / 4103942272024072704;
        else if (base < 18 * 10**17) return 795655461284891264 + base * FIXED_1 / 4273206388239193600;
        else if (base < 19 * 10**17) return 810960266076453376 + base * FIXED_1 / 4439181733794846720;
        else if (base < 2 * 10**18) return 825708219753447168 + base * FIXED_1 / 4602109933136747008;
        else if (base < 5 * 10**18) return 839947366596582144 + base * FIXED_1 / 4762203155904598016;
        else if (base < 10 * 10**18) return 1139983964451131136 + base * FIXED_1 / 8772053214638598144;
        else if (base < 50 * 10**18) return 1436289793354589184 + base * FIXED_1 / 13924766500838334464;
        else if (base < 10**20) return 2456020999093591040 + base * FIXED_1 / 40716264248923594752;
        else if (base < 10**21) return 3094392555741852160 + base * FIXED_1 / 64633040700956499968;
        else if (base < 10**22) return 6666666666666667008 + base * FIXED_1 / 300000000000000000000;
        else if (base < 10**23) return 14362897933545887744 + base * FIXED_1 / 1392476650083833085952;
        else if (base < 10**24) return 30943925557418532864 + base * FIXED_1 / 6463304070095653830656;
        else if (base < 10**27) return 66666666666666672128 + base * FIXED_1 / 30000000000000000000000;
        else if (base < 10**30) return 666666666666666622976 + base * FIXED_1 / 2999999999999999949668352;
        else return 6666666666666667016192 + base * FIXED_1 / 299999999999999997114318848;
    }

    function _getInitialValue4(uint256 base) internal pure returns (uint256) {
        if (base < 11 * 10**17) return (base + 3 * FIXED_1) / 4;
        else if (base < 12 * 10**17) return 768085266813333760 + base * FIXED_1 / 4296397994575766528;
        else if (base < 13 * 10**17) return 784976354544079232 + base * FIXED_1 / 4586125402580960768;
        else if (base < 14 * 10**17) return 800842479279330688 + base * FIXED_1 / 4869871542665377792;
        else if (base < 15 * 10**17) return 815817979452957824 + base * FIXED_1 / 5148207205259542528;
        else if (base < 16 * 10**17) return 830011439775241216 + base * FIXED_1 / 5421612021659068416;
        else if (base < 17 * 10**17) return 843511987785523584 + base * FIXED_1 / 5690494112124553216;
        else if (base < 18 * 10**17) return 856393759076569856 + base * FIXED_1 / 5955204537570678784;
        else if (base < 19 * 10**17) return 868719138966201728 + base * FIXED_1 / 6216048153867243520;
        else if (base < 2 * 10**18) return 880541164458013952 + base * FIXED_1 / 6473291914192829440;
        else if (base < 5 * 10**18) return 891905336252040832 + base * FIXED_1 / 6727171322029716480;
        else if (base < 10 * 10**18) return 1121511585915915264 + base * FIXED_1 / 13374806099528439808;
        else if (base < 50 * 10**18) return 1333709557529191936 + base * FIXED_1 / 22493653007613964288;
        else if (base < 10**20) return 1994360961354370560 + base * FIXED_1 / 75212061861727879168;
        else if (base < 10**21) return 2371708245126284288 + base * FIXED_1 / 126491106406735167488;
        else if (base < 10**22) return 4217559938927618048 + base * FIXED_1 / 711311764015569174528;
        else if (base < 10**23) return 7500000000000000000 + base * FIXED_1 / 4000000000000000000000;
        else if (base < 10**24) return 13337095575291922432 + base * FIXED_1 / 22493653007613963534336;
        else if (base < 10**27) return 23717082451262844928 + base * FIXED_1 / 126491106406735168929792;
        else if (base < 10**30) return 133370955752919203840 + base * FIXED_1 / 22493653007613965379829760;
        else return 750000000000000000000 + base * FIXED_1 / 4000000000000000053150220288;
    }

    function _getInitialValue5(uint256 base) internal pure returns (uint256) {
        if (base < 11 * 10**17) return (base + 4 * FIXED_1) / 5;
        else if (base < 12 * 10**17) return 815395901193165312 + base * FIXED_1 / 5396151726494454784;
        else if (base < 13 * 10**17) return 829709831469318528 + base * FIXED_1 / 5785155024015763456;
        else if (base < 14 * 10**17) return 843099161649426816 + base * FIXED_1 / 6167720520355870720;
        else if (base < 15 * 10**17) return 855688300580055040 + base * FIXED_1 / 6544439133039290368;
        else if (base < 16 * 10**17) return 867577416958158848 + base * FIXED_1 / 6915809336112958464;
        else if (base < 17 * 10**17) return 878848434644894208 + base * FIXED_1 / 7282256812104322048;
        else if (base < 18 * 10**17) return 889569268750862976 + base * FIXED_1 / 7644148959359385600;
        else if (base < 19 * 10**17) return 899796890513675776 + base * FIXED_1 / 8001805825189799936;
        else if (base < 2 * 10**18) return 909579591048110464 + base * FIXED_1 / 8355508495130706944;
        else if (base < 5 * 10**18) return 918958683997628032 + base * FIXED_1 / 8705505632961241088;
        else if (base < 10 * 10**18) return 1103783729168971776 + base * FIXED_1 / 18119491591942387712;
        else if (base < 50 * 10**18) return 1267914553968890880 + base * FIXED_1 / 31547867224009666560;
        else if (base < 10**20) return 1749379318309244928 + base * FIXED_1 / 114326262981831606272;
        else if (base < 10**21) return 2009509145207664128 + base * FIXED_1 / 199053585276748660736;
        else if (base < 10**22) return 3184857364427977728 + base * FIXED_1 / 1255943215754789781504;
        else if (base < 10**23) return 5047658755841547264 + base * FIXED_1 / 7924465962305570471936;
        else if (base < 10**24) return 8000000000000000000 + base * FIXED_1 / 49999999999999995805696;
        else if (base < 10**27) return 12679145539688906752 + base * FIXED_1 / 315478672240096512573440;
        else if (base < 10**30) return 50476587558415458304 + base * FIXED_1 / 79244659623055715305783296;
        else return 200950914520766382080 + base * FIXED_1 / 19905358527674846022150914048;
    }

    function _getInitialValue6(uint256 base) internal pure returns (uint256) {
        if (base < 11 * 10**17) return (base + 5 * FIXED_1) / 6;
        else if (base < 12 * 10**17) return 846676556477822848 + base * FIXED_1 / 6495987113284461568;
        else if (base < 13 * 10**17) return 859044434072037248 + base * FIXED_1 / 6984504831209763840;
        else if (base < 14 * 10**17) return 870581256602731008 + base * FIXED_1 / 7466276066366221312;
        else if (base < 15 * 10**17) return 881400772004346880 + base * FIXED_1 / 7941903640589817856;
        else if (base < 16 * 10**17) return 891594328278052608 + base * FIXED_1 / 8411897386656603136;
        else if (base < 17 * 10**17) return 901236455933499264 + base * FIXED_1 / 8876693732627154944;
        else if (base < 18 * 10**17) return 910388802749551488 + base * FIXED_1 / 9336670194457954304;
        else if (base < 19 * 10**17) return 919102974188949248 + base * FIXED_1 / 9792156322790639616;
        else if (base < 2 * 10**18) return 927422626912801280 + base * FIXED_1 / 10243442120474828800;
        else if (base < 5 * 10**18) return 935385040257810944 + base * FIXED_1 / 10690784617684072448;
        else if (base < 10 * 10**18) return 1089717071676525440 + base * FIXED_1 / 22941734739951902720;
        else if (base < 50 * 10**18) return 1223166056351724544 + base * FIXED_1 / 40877524143477678080;
        else if (base < 10**20) return 1599485919722070272 + base * FIXED_1 / 156300219287607443456;
        else if (base < 10**21) return 1795362241693236736 + base * FIXED_1 / 278495330016766787584;
        else if (base < 10**22) return 2635231383473649664 + base * FIXED_1 / 1897366596101027921920;
        else if (base < 10**23) return 3867990694677315584 + base * FIXED_1 / 12926608140191307661312;
        else if (base < 10**24) return 5677433908816345088 + base * FIXED_1 / 88067956057324233162752;
        else if (base < 10**27) return 8333333333333334016 + base * FIXED_1 / 600000000000000016777216;
        else if (base < 10**30) return 26352313834736492544 + base * FIXED_1 / 189736659610102750911660032;
        else return 83333333333333327872 + base * FIXED_1 / 60000000000000001896764932096;
    }

    function _getInitialValue7(uint256 base) internal pure returns (uint256) {
        if (base < 11 * 10**17) return (base + 6 * FIXED_1) / 7;
        else if (base < 12 * 10**17) return 868893305396115584 + base * FIXED_1 / 7595869319065772032;
        else if (base < 13 * 10**17) return 879761225363176704 + base * FIXED_1 / 8184038796467470336;
        else if (base < 14 * 10**17) return 889878741879279360 + base * FIXED_1 / 8765239164526692352;
        else if (base < 15 * 10**17) return 899349803361962624 + base * FIXED_1 / 9340080988063817728;
        else if (base < 16 * 10**17) return 908257733714612864 + base * FIXED_1 / 9909081603072729088;
        else if (base < 17 * 10**17) return 916670400045765632 + base * FIXED_1 / 10472684619816142848;
        else if (base < 18 * 10**17) return 924643848777105280 + base * FIXED_1 / 11031274380389906432;
        else if (base < 19 * 10**17) return 932224926218075008 + base * FIXED_1 / 11585186896701325312;
        else if (base < 2 * 10**18) return 939453207124018048 + base * FIXED_1 / 12134718273940676608;
        else if (base < 5 * 10**18) return 946362440291839104 + base * FIXED_1 / 12680131299694692352;
        else if (base < 10 * 10**18) return 1078713386264422912 + base * FIXED_1 / 27810909164564828160;
        else if (base < 50 * 10**18) return 1190996138034117888 + base * FIXED_1 / 50377997110080634880;
        else if (base < 10**20) return 1498867389934405632 + base * FIXED_1 / 200151128788737425408;
        else if (base < 10**21) return 1654883767614214400 + base * FIXED_1 / 362563227546184712192;
        else if (base < 10**22) return 2299453538811193088 + base * FIXED_1 / 2609315604220459089920;
        else if (base < 10**23) return 3195080331698520064 + base * FIXED_1 / 18778870566958074429440;
        else if (base < 10**24) return 4439549725055323648 + base * FIXED_1 / 135148841021827488677888;
        else if (base < 10**27) return 6168734340009874432 + base * FIXED_1 / 972646846061197280673792;
        else if (base < 10**30) return 16548837676142149632 + base * FIXED_1 / 362563227546184824775507968;
        else return 44395497250553225216 + base * FIXED_1 / 135148841021827741745951014912;
    }

    function _getInitialValue8(uint256 base) internal pure returns (uint256) {
        if (base < 11 * 10**17) return (base + 7 * FIXED_1) / 8;
        else if (base < 12 * 10**17) return 885486896122849664 + base * FIXED_1 / 8695780856515043328;
        else if (base < 13 * 10**17) return 895170390817905024 + base * FIXED_1 / 9383688386213304320;
        else if (base < 14 * 10**17) return 904171829685956352 + base * FIXED_1 / 10064458658439602176;
        else if (base < 15 * 10**17) return 912586536914843776 + base * FIXED_1 / 10738707622326521856;
        else if (base < 16 * 10**17) return 920490817320063616 + base * FIXED_1 / 11406957899449688064;
        else if (base < 17 * 10**17) return 927946741035131904 + base * FIXED_1 / 12069658208515622912;
        else if (base < 18 * 10**17) return 935005505718548480 + base * FIXED_1 / 12727197783562668032;
        else if (base < 19 * 10**17) return 941709856782507520 + base * FIXED_1 / 13379917295386269696;
        else if (base < 2 * 10**18) return 948095866487608320 + base * FIXED_1 / 14028117271803156480;
        else if (base < 5 * 10**18) return 954194266082100480 + base * FIXED_1 / 14672064691274739712;
        else if (base < 10 * 10**18) return 1069988976869620480 + base * FIXED_1 / 32710617358317699072;
        else if (base < 50 * 10**18) return 1166831253142908672 + base * FIXED_1 / 59991536746596466688;
        else if (base < 10**20) return 1426853232834146048 + base * FIXED_1 / 245295025406921539584;
        else if (base < 10**21) return 1555994483784057344 + base * FIXED_1 / 449873060152279236608;
        else if (base < 10**22) return 2074951992453948416 + base * FIXED_1 / 3373572027428658216960;
        else if (base < 10**23) return 2766992952647332352 + base * FIXED_1 / 25298221281347035463680;
        else if (base < 10**24) return 3689844405000094720 + base * FIXED_1 / 189709896452932406083584;
        else if (base < 10**27) return 4920486595415554048 + base * FIXED_1 / 1422623528031138202255360;
        else if (base < 10**30) return 11668312531429083136 + base * FIXED_1 / 599915367465964663851712512;
        else return 27669929526473318400 + base * FIXED_1 / 252982212813470322820756013056;
    }

    function _getInitialValue9(uint256 base) internal pure returns (uint256) {
        if (base < 11 * 10**17) return (base + 8 * FIXED_1) / 9;
        else if (base < 12 * 10**17) return 898352260184454016 + base * FIXED_1 / 9795711982951034880;
        else if (base < 13 * 10**17) return 907079587268309504 + base * FIXED_1 / 10583415319608961024;
        else if (base < 14 * 10**17) return 915182801394692992 + base * FIXED_1 / 11363849915176419328;
        else if (base < 15 * 10**17) return 922749728236018688 + base * FIXED_1 / 12137635652746887168;
        else if (base < 16 * 10**17) return 929850594349524096 + base * FIXED_1 / 12905299058710165504;
        else if (base < 17 * 10**17) return 936542468347257344 + base * FIXED_1 / 13667292656347465728;
        else if (base < 18 * 10**17) return 942872378541879808 + base * FIXED_1 / 14424009345816174592;
        else if (base < 19 * 10**17) return 948879555011728384 + base * FIXED_1 / 15175793306898696192;
        else if (base < 2 * 10**18) return 954597076272357248 + base * FIXED_1 / 15922948412282032128;
        else if (base < 5 * 10**18) return 960053101237605504 + base * FIXED_1 / 16665744821171226624;
        else if (base < 10 * 10**18) return 1062945044000357120 + base * FIXED_1 / 37631296392766808064;
        else if (base < 50 * 10**18) return 1148044146679896704 + base * FIXED_1 / 69683731441301422080;
        else if (base < 10**20) return 1372846315507892224 + base * FIXED_1 / 291365461291286364160;
        else if (base < 10**21) return 1482756033066718976 + base * FIXED_1 / 539535825287046823936;
        else if (base < 10**22) return 1915053057806118912 + base * FIXED_1 / 4177429950251499782144;
        else if (base < 10**23) return 2473386135295221760 + base * FIXED_1 / 32344322974241632813056;
        else if (base < 10**24) return 3194501034493002240 + base * FIXED_1 / 250430346198641323016192;
        else if (base < 10**27) return 4125856740989136384 + base * FIXED_1 / 1938991221028693825552384;
        else if (base < 10**30) return 8888888888888889344 + base * FIXED_1 / 899999999999999956983218176;
        else return 19150530578061180928 + base * FIXED_1 / 417742995025149503266715860992;
    }

    function _getInitialValue10(uint256 base) internal pure returns (uint256) {
        if (base < 11 * 10**17) return (base + 9 * FIXED_1) / 10;
        else if (base < 12 * 10**17) return 908618924499198336 + base * FIXED_1 / 10895656840359739392;
        else if (base < 13 * 10**17) return 916559438532321664 + base * FIXED_1 / 11783196534742951936;
        else if (base < 14 * 10**17) return 923925268173808768 + base * FIXED_1 / 12663361857313112064;
        else if (base < 15 * 10**17) return 930797724716442240 + base * FIXED_1 / 13536775676840484864;
        else if (base < 16 * 10**17) return 937241769593169536 + base * FIXED_1 / 14403967511883272192;
        else if (base < 17 * 10**17) return 943310150522062080 + base * FIXED_1 / 15265392821258754048;
        else if (base < 18 * 10**17) return 949046302669289728 + base * FIXED_1 / 16121447348740720640;
        else if (base < 19 * 10**17) return 954486433452616832 + base * FIXED_1 / 16972478007257305088;
        else if (base < 2 * 10**18) return 959661052630673152 + base * FIXED_1 / 17818791283781478400;
        else if (base < 5 * 10**18) return 964596116282663680 + base * FIXED_1 / 18660659830736146432;
        else if (base < 10 * 10**18) return 1057157048779217024 + base * FIXED_1 / 42566996126039236608;
        else if (base < 50 * 10**18) return 1133032870614750592 + base * FIXED_1 / 79432823472428154880;
        else if (base < 10**20) return 1330881872965482240 + base * FIXED_1 / 338121668903120732160;
        else if (base < 10**21) return 1426403873215002112 + base * FIXED_1 / 630957344480193282048;
        else if (base < 10**22) return 1795736083471991296 + base * FIXED_1 / 5011872336272724852736;
        else if (base < 10**23) return 2260697788358622464 + base * FIXED_1 / 39810717055349734506496;
        else if (base < 10**24) return 2846049894151541760 + base * FIXED_1 / 316227766016837930713088;
        else if (base < 10**27) return 3582964534981474816 + base * FIXED_1 / 2511886431509581735657472;
        else if (base < 10**30) return 7148954112518534144 + base * FIXED_1 / 1258925411794166132030570496;
        else return 14264038732150018048 + base * FIXED_1 / 630957344480194221089113505792;
    }
}
