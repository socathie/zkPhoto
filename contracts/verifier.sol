//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );

/*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
    }
    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-add-failed");
    }
    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success,"pairing-mul-failed");
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length,"pairing-lengths-failed");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-opcode-failed");
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }
    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            20491192805390485299153009773594534940189261866228447918068658471970481763042,
            9383485363053290200918347156157836566562967994039712273449902621266178545958
        );

        vk.beta2 = Pairing.G2Point(
            [4252822878758300859123897981450591353533073413197771768651442665752259397132,
             6375614351688725206403948262868962793625744043794305715222011528459656738731],
            [21847035105528745403288232691147584728191162732299865338377159692350059136679,
             10505242626370262277552901082094356697409835680220590971873171140371331206856]
        );
        vk.gamma2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.delta2 = Pairing.G2Point(
            [19522617420577800887283636870350000142018532791345516452205893419796067405976,
             14831710641823804505575080137654777449100627108867458924365711741624668656855],
            [5191068743784871961870790322874957664505846258497723493333762038459377779425,
             17925312182272377079332152725681595009067004916298226397429624101847139289452]
        );
        vk.IC = new Pairing.G1Point[](66);
        
        vk.IC[0] = Pairing.G1Point( 
            8157425956816192978171563081988695570652163751185818071314409682760590052642,
            13614089673422423481572378350984554275305143428616427075701565975971124734886
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            5651711042042862760657596505473273390293186526421818168803574965805342777226,
            4003423287829109296540991090551022656503075522347357126896720450897873022370
        );                                      
        
        vk.IC[2] = Pairing.G1Point( 
            13001491745408519691151713075376730544426538217893359480628367172889844914256,
            3093236311839646685924239543726090623503288881712794392489784748294039370252
        );                                      
        
        vk.IC[3] = Pairing.G1Point( 
            12450363179431080691946085750061372781315194987925805299005222951891488552934,
            14533433677627225908879778013800790676398270619069017230016925367601925953404
        );                                      
        
        vk.IC[4] = Pairing.G1Point( 
            4243570469557572721327830667801148532283032778269770660678652071195809710551,
            17387793266847035681897328877047341580996231094276794959910669978233038951992
        );                                      
        
        vk.IC[5] = Pairing.G1Point( 
            12944196520765604796672429719166486173041705443788545158434261114283928025197,
            10558742082947621595119353824771726859023578788779050478297348621153812099755
        );                                      
        
        vk.IC[6] = Pairing.G1Point( 
            9690822159459535703314168085502371024556937242634613513471557895887754328798,
            21701413635446684384643469203735731157639055995156856514241334059790857108654
        );                                      
        
        vk.IC[7] = Pairing.G1Point( 
            5655620934639817572960675617367670770680605581293229817961886394058013354094,
            11725682469525226829134015048013771570061450275887082390715013632563784644998
        );                                      
        
        vk.IC[8] = Pairing.G1Point( 
            1705740132404025936361233565714264759424322297600236122120570019586490240707,
            7611708493404662489179892685634563810487211276800534271815953767267175339705
        );                                      
        
        vk.IC[9] = Pairing.G1Point( 
            10454743026115410635865101237641812588982872347011548209527791021781222803540,
            5268107931910360841842177043462530984092191896448772212785965311768432473360
        );                                      
        
        vk.IC[10] = Pairing.G1Point( 
            14738056046642860718273189153321287033822249774195323566300454742053084980989,
            19324729241649442032560925930826121300651118686954757686880690678927513200043
        );                                      
        
        vk.IC[11] = Pairing.G1Point( 
            18473663098237082091437985544856760646635061671849301627529529360003809349101,
            14730639281761454712219655988969503227476130416996530432096936098797459009284
        );                                      
        
        vk.IC[12] = Pairing.G1Point( 
            3404193217850070469068887126301640702853585225625160711877896654827083473748,
            5290812718740894280813045310828523140209089921550477915687544588051009672659
        );                                      
        
        vk.IC[13] = Pairing.G1Point( 
            9566408877586954476652259186502273817633332899849614692086580786160972737398,
            7789050542609965588882818878835296298789303074820285864363533189810235438603
        );                                      
        
        vk.IC[14] = Pairing.G1Point( 
            12328307788774728625962405546137575624362771785590819097468122048711181463716,
            10497786654635488732068547563340046240960795012275260573130145670340336516516
        );                                      
        
        vk.IC[15] = Pairing.G1Point( 
            2948442084915323527189047965486406756965993718118754319131458535706440780205,
            12081156451623496798211447195222527208982859544469255937336999152972329622001
        );                                      
        
        vk.IC[16] = Pairing.G1Point( 
            14558132357527343247695217228806170547244064004818409406559370093867656226798,
            14266248463326827573506387018665278191724421556619610279488443450478545504575
        );                                      
        
        vk.IC[17] = Pairing.G1Point( 
            1652497366309025806191803373492451100455462312073749296282847762355462653818,
            4761986678705334481461349746237013605397831305308912240019955843874297680561
        );                                      
        
        vk.IC[18] = Pairing.G1Point( 
            9212965888420681425139881500688821172699115283643744247809826250151034687466,
            19685691485744859530606073819007024142842379960919211916428999873208175228966
        );                                      
        
        vk.IC[19] = Pairing.G1Point( 
            6126734402757670955929824787712246299826862807364588106691912202613128667253,
            19308390092453095814933379881797970538328175041096104224310179636921547540384
        );                                      
        
        vk.IC[20] = Pairing.G1Point( 
            11445907046290944107888288287584454292754186678623196766170004009405819962609,
            11690865694696184179798119556145762128757668398329854785127928978025772954889
        );                                      
        
        vk.IC[21] = Pairing.G1Point( 
            1983850667129002314005120098240251484461531866760209550520925129369512515790,
            19300206269775000643361477888911501524290053013836283168122935866607678421583
        );                                      
        
        vk.IC[22] = Pairing.G1Point( 
            18719866673490039760627957665040843673978402675108669037278157044178865894074,
            11183065716352601580915387671262116390467334689778841393328736869598818253587
        );                                      
        
        vk.IC[23] = Pairing.G1Point( 
            1082897557016185697498381614475976115276886187976316969086143354797442721863,
            13132801169133848473039017639379988812554600445652154641565654039599534724887
        );                                      
        
        vk.IC[24] = Pairing.G1Point( 
            10124164525071485852917107079702672099606327095116830011322465269305671945501,
            7517287229769627546464203699219945792725943844882329966924623096963525639396
        );                                      
        
        vk.IC[25] = Pairing.G1Point( 
            1081139582883970056991548325959294858571055080702843991924000701865347327463,
            21122637227770374691915027923949421929393030293063779796217705455429239040665
        );                                      
        
        vk.IC[26] = Pairing.G1Point( 
            13961096053718391958258969681898955416734424910212541153614917057181925225102,
            13139129031990478788204991949518198994441307099661930861827003791702827944085
        );                                      
        
        vk.IC[27] = Pairing.G1Point( 
            818889108013162101379805779083662813096222536338454456800687976427710717428,
            15833500102665756914751173886611094389376432754263741264331737073630172821339
        );                                      
        
        vk.IC[28] = Pairing.G1Point( 
            15016021106870018975584124628663495211337839172251597939412470709931054212140,
            8704769871627245112546601797340473902313666206556436613049488381077400601373
        );                                      
        
        vk.IC[29] = Pairing.G1Point( 
            11251220340227988716734660566382384986491689543463524605592755224468726009374,
            11202720119049891941562748448664726538234232663921512680730990646508002238822
        );                                      
        
        vk.IC[30] = Pairing.G1Point( 
            8029401341865188370427690644322962506305115419647411032156945626077306665596,
            6418350235313375195659744789268909327851438110815512195581171108573553822785
        );                                      
        
        vk.IC[31] = Pairing.G1Point( 
            13981144470627271259370294858639255543441428900769038232103375281105374925217,
            12933402328677010001081071780512459448218168974301560080660849439806442809841
        );                                      
        
        vk.IC[32] = Pairing.G1Point( 
            14204221330600551460840695376585881325365445760278906332131515595472701604922,
            8925414790195317285178886123345507540544912416325447791833774829554976553837
        );                                      
        
        vk.IC[33] = Pairing.G1Point( 
            4180736617360966566814132139573483129961983924042381338403262932777376908284,
            18695845479293797209188585008555284099162838627179043704741423023264630987529
        );                                      
        
        vk.IC[34] = Pairing.G1Point( 
            5741418278797031970138490700823888326739904495795202024163789316279077313729,
            18671264994420988492620277698820069122420462588494105351748762762337913901308
        );                                      
        
        vk.IC[35] = Pairing.G1Point( 
            17441316413435425707727034458435483520634598938193927603592773799895470986678,
            5949130886948741981389696933476567560725461175593461150961987552395236662808
        );                                      
        
        vk.IC[36] = Pairing.G1Point( 
            17860178301303190827551363695456839103483721333899851354116966646423961733301,
            9680576375078345104476068746686950689432541265451400925183929658260022600176
        );                                      
        
        vk.IC[37] = Pairing.G1Point( 
            20951158459414764419451120596216287499399209770640467960222497831597552432029,
            19042124018890746512407215610271748341267172728661302467369860825223411329978
        );                                      
        
        vk.IC[38] = Pairing.G1Point( 
            4115169926447503167824778948839354676568699666073779583204024760528312160904,
            18152250927279384212498429860255596972806335938488505355449898077731168924630
        );                                      
        
        vk.IC[39] = Pairing.G1Point( 
            20076342950053041695228851169245861155317842387933002211057422118761142825424,
            19939978911780974209723428615496350039658316092141506079601519493857844979323
        );                                      
        
        vk.IC[40] = Pairing.G1Point( 
            3474918323967482850160836462857072621798480398024918290420517360261375546632,
            19666929730155538986468964269959467791758978387594045258767158882230360038211
        );                                      
        
        vk.IC[41] = Pairing.G1Point( 
            20047180315132418650075047146356618870411947415951283460971089754376972751683,
            15887292040282067843615335155015077338889732781017874673808445184875849273100
        );                                      
        
        vk.IC[42] = Pairing.G1Point( 
            16309327511876620333222400902094615467016764476260657317950934837591116774283,
            11246918690585907158036378215063184012653610036548458947671072802055967507399
        );                                      
        
        vk.IC[43] = Pairing.G1Point( 
            8975673351625541672355183471713709537532829042381567744043528009855335231383,
            1556897734418734821924074987577649705007528589543445993114018335226727568260
        );                                      
        
        vk.IC[44] = Pairing.G1Point( 
            8665555519485368997915592915440535623041735549375447077554005680456578705640,
            14849673950795099272798662475501763039907930553121258542949681595199633224450
        );                                      
        
        vk.IC[45] = Pairing.G1Point( 
            2417193492381322518582807094177843881483467326243360770325119460200302307797,
            20067550151877575106990462459484988497209522671107617266917525315482179349712
        );                                      
        
        vk.IC[46] = Pairing.G1Point( 
            15375641281441278672481143716147530100544512481830613070880253768359774496120,
            16717259317069999972104114290688278315999040261398833959704848648366765558789
        );                                      
        
        vk.IC[47] = Pairing.G1Point( 
            4049624063419552636891661929874876713177461121242573427596524818916915274854,
            10569762172020449190494279428137771270045169242136410244583961762285721059794
        );                                      
        
        vk.IC[48] = Pairing.G1Point( 
            8362328920638259268140284960411445984274256557004594091462733760933926165502,
            5541178886123927796200000585836652996027377444277924870675395520645366007155
        );                                      
        
        vk.IC[49] = Pairing.G1Point( 
            12998205905009075096407762085454838914220559830340459779749965372521087233770,
            6741781286130804873763132370288142350518224348210591055737070694819763097048
        );                                      
        
        vk.IC[50] = Pairing.G1Point( 
            19448127042999899982741038881147005440578221202117115356352677064094144485776,
            6823175311116567367292361925849133070423941214237952503881043501789831162788
        );                                      
        
        vk.IC[51] = Pairing.G1Point( 
            10580890456568461797538492808734396222055050479205682934214430284865553019577,
            16069976681342330640311422921839690228245021864557024604484244590757961786220
        );                                      
        
        vk.IC[52] = Pairing.G1Point( 
            5828385532906411340003926786346366149833832710651239110307126351328033838683,
            19597718669334691767494326833483788321104502847118146297879388603933951270228
        );                                      
        
        vk.IC[53] = Pairing.G1Point( 
            11553867096903410356620660169317325353677340098463771497992630074731622208005,
            13050787466810287948983049535112313407482217607511984553142933219805891765600
        );                                      
        
        vk.IC[54] = Pairing.G1Point( 
            5813657621746536251811418688204668317115301860583419796541064601510795388334,
            3154166969901704044551621736945958033684946837643396146399732837740782164161
        );                                      
        
        vk.IC[55] = Pairing.G1Point( 
            7016162352971055653549897188554661163718999907260747754590651646339116001516,
            6174622548019291601034066218240509960208804409476991583032551740514117348838
        );                                      
        
        vk.IC[56] = Pairing.G1Point( 
            20620989710362074296326526717374782616962043367851661270246636333597639729041,
            15040799261025586775656370160110666176013502879868787463625263709796307268933
        );                                      
        
        vk.IC[57] = Pairing.G1Point( 
            1009818462365913955237976471897832489308714737003083212876367698393079950309,
            3713295737545853243053562288378040829648070735053396117780914436188327153785
        );                                      
        
        vk.IC[58] = Pairing.G1Point( 
            638795440549923142033981692113746403783556723673246447295958826591611064654,
            4426875831303504721946160004626894687903771697859331350532443181313990888623
        );                                      
        
        vk.IC[59] = Pairing.G1Point( 
            10286319913505151283699951127678133657197450952912739941012328023496380497882,
            7434072168133399776037125180155130419617488086464106709633997918283102390124
        );                                      
        
        vk.IC[60] = Pairing.G1Point( 
            3974538974836646326654180421940805580181022009763277783976931344683780814925,
            13342490469926746281389181271346745181352370541715778471863642541038105039439
        );                                      
        
        vk.IC[61] = Pairing.G1Point( 
            11801247666811439237489864169371285256157816219279587259630007930818003499905,
            6954520523074375285553572878721099470520451777556098069348506308777194667200
        );                                      
        
        vk.IC[62] = Pairing.G1Point( 
            2256642097694322149407462441319154891092656509126559900343804242775542762749,
            12010923860714240251978129994959963140803740281653060244098479852530316469195
        );                                      
        
        vk.IC[63] = Pairing.G1Point( 
            3129356836441531928975177814691304279713239343341037775658451429308787519855,
            1060283333669894251638987827938823273447838888626193530858814962366593952929
        );                                      
        
        vk.IC[64] = Pairing.G1Point( 
            7587124930670862246674100971091111104950734683365773376989177937505566503470,
            20857857069909540244768553109885738826656015619147906190602127812097535793842
        );                                      
        
        vk.IC[65] = Pairing.G1Point( 
            9162410432704533776532768450628611106903150402148502707632849593790064962059,
            12901216338529572693350814200048649805134071854235196629891340027963178058133
        );                                      
        
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length,"verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd4(
            Pairing.negate(proof.A), proof.B,
            vk.alfa1, vk.beta2,
            vk_x, vk.gamma2,
            proof.C, vk.delta2
        )) return 1;
        return 0;
    }
    /// @return r  bool true if proof is valid
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[65] memory input
        ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
