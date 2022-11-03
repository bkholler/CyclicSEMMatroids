rev[list_, perm_] := Module[{temp}, temp = list;
  For[ind = 1, ind <= Length[perm], ind++,
   temp[[perm[[ind]]]] = Reverse[list[[perm[[ind]]]]];];
  temp]

ran[] := Module[{temp}, temp = RandomInteger[{10, 100}];
  temp = temp*(RandomInteger[] - 1/2)*2;
  temp]

rans[] := Module[{temp}, temp = RandomInteger[{1, 50}];
  temp]

ToEdge[x_] := Module[{temp, i},
  temp = {};
  For[i = 1, i <= Length[x], i++,
   temp = Join[temp, {i, #} & /@ x[[i]]]
   ];
  temp]

(*check the matroids numerically with random integers*)
computemat[edgelist_]:=Module[
{Id,W,L,vars,valueset,j,row,col,K,Kvars,m,J,Imax,ss,k},
Id = IdentityMatrix[p];
W = d*IdentityMatrix[p];

L = Id;
vars = {};
valueset = {};
For[j = 1, j <= Length[edgelist], j++,
 row = edgelist[[j]][[1]];
 col = edgelist[[j]][[2]];
 L[[row, col]] = -l[row, col];
 vars = Join[vars, {l[row, col]}];
 valueset = Append[valueset, l[row, col] -> ran[] ];
 ];
valueset = Append[valueset, s -> rans[]];
 
K = L.W.Transpose[L];
Kvars = Diagonal[K];
For[m = 1, m < p, m++,
 Kvars = Join[Kvars, Diagonal[K, m]]
 ];
vars = Join[vars, {d}];
J = Transpose[D[Kvars, {vars, 1}]];
J = J /. valueset;
 
Imax = {};
ss = Subsets[Range[1, p*(p + 1)/2], {Length[vars]}];
For[k = 1, k <= Length[ss], k++,
 If[
  MatrixRank[ J[[All, ss[[k]] ]] ] == Length[ss[[k]]],
  Imax = Join[Imax, {ss[[k]]}];
  ]
 ];
Imax
]


p = 6;
edges = 6;
seqlist = {};
For[k = p - 1, k >= 1, k--,
  stack = {{1, {k}, k}};
  While[Length[stack] > 0,
   cur = stack[[-1]][[1]];
   seq = stack[[-1]][[2]];
   sum = stack[[-1]][[3]];
   stack = Delete[stack, -1];
   
   If[cur <= p,
    If[sum == edges,
      seq = Join[seq, ConstantArray[0, p - cur]];
      seqlist = Append[seqlist, seq],(*else*)
      Module[{i},
        For[i = Min[edges - sum, seq[[cur]], p - cur + 1], i >= 1,
          i--,(*out degree decreasing*)
          sum += i;
          stack = Append[stack, {cur + 1, Append[seq, i], sum}];
          sum -= i;
          ];
        ];
      ];
    ];
   
   ];
  ];
seqlist;
Length[seqlist]

lengthlist = {};

For[ind = 1, ind <= Length[seqlist], ind++,

(*find all simple graphs satisfying ind'th out degree list*)

seq = seqlist[[ind]];
adj = ConstantArray[0, {p, p}];
list = Subsets[Delete[Range[1, p], #], {seq[[#]]}] & /@
   Range[p];(*subsets of size seq[[#]] in [1,p]\#*)

stack = {{1, {}, adj}};
res = {};
While[Length[stack] > 0,
 cur = stack[[-1]][[1]];
 path = stack[[-1]][[2]];
 adj = stack[[-1]][[3]];(*matrix B, i,j entry is j\[Rule]i*)
 
 stack = Delete[stack, -1];
 If[cur == p + 1,
  res = Append[res, path],(*else*)
  If[seq[[cur]] == 0,
    path = Join[path, {} & /@ Range[cur, p]];
    res = Append[res, path],(*else*)
    Module[{i, j},
      For[i = 1, i <= Length[list[[cur]]], i++,(*list[
        cur] is a set of adjacencies list[cur][
        i] is i'th adj children set*)
        
        If[Total[adj[[cur, list[[cur]][[i]] ]] ] ==
           0,(*no edge from xxx to cur, xxx can be children of cur*)
 
                   For[j = 1, j <= Length[list[[cur]][[i]]], j++,
           
           adj[[list[[cur]][[i]][[j]], cur]] =
            1(*cur to children*)
           ];
          
          stack = Append[
            stack, {cur + 1, Append[path, list[[cur]][[i]] ], adj}];
          For[j = 1, j <= Length[list[[cur]][[i]]], j++,
           adj[[list[[cur]][[i]][[j]], cur]] = 0(*cur to children,
           reset to 0*)
           ];
          ];
        ];
      ];
    ];
  ];
 
 ];


(*tranform tail nodes representation to edges representation*)
res = ToEdge /@ res;

(*check the matroids numerically with random integers*)
matroids = Parallelize[Map[computemat,res]];
Print[ind];
lengthlist = Append[lengthlist, {Length[matroids], Length[DeleteDuplicates[matroids]]}];
If[Length[matroids]!=Length[DeleteDuplicates[matroids]], Break[]];
Print[lengthlist];
];

lengthlist
Export["p6d11.wdx",{seqlist, lengthlist},"WDX"];
