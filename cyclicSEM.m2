load("matroidSeparate.m2");
needsPackage("Graphs");

concRing = n -> QQ[apply(n, i -> k_{i, i}) | apply(subsets(n, 2), i -> k_{i_0, i_1})]

gaussPrecParam = {paramRing => null} >> opts -> G -> (

  n := #vertices(G);
  S := if opts.paramRing === null then QQ[{s} | apply(edges(G), e -> l_e)] else opts.paramRing;
  use S;

  L := (0_S)*mutableIdentity(S, n);
  for e in edges(G) do L_(toSequence(e)) = l_e;
  L = matrix L;
  
  I := id_(S^n);
  phi := s*(I-L)*(transpose(I-L));

  print(phi);
  return toList(apply(vertices(G), i -> phi_(i, i)) | apply(subsets(n, 2), i -> phi_(i_0, i_1)));
  )

jac = jac = G -> jacobian matrix {gaussPrecParam(G)}

genGraphs = n -> (set({-1,0,1}))^**(binomial(n, 2)) / deepSplice / toList // toList;

genFixedSizeGraphs = (n, k) -> (

  N = binomial(n, 2);
  edgeSupports = subsets(N, k);
  edgeVecs = (set({-1,1}))^**k / deepSplice / toList // toList;

  out = for S in edgeSupports list(

          for v in edgeVecs list(

            j = 0;

            for i from 0 to N-1 list(

              if isSubset({i}, S) then(
                j = j+1;
                v_(j-1)
                )
              else 0
              )
              
            )
          );
  return flatten out;
  )

out = genFixedSizeGraphs(4,2)

edgeVecToDigraph = (n, v) -> (

  allEdges = subsets(n, 2);

  edgeSet = delete(null, apply(#v, i -> if v_i == -1 then reverse(allEdges_i) else if v_i == 1 then allEdges_i));

  return digraph edgeSet;
  );

G = digraph {{0,1}, {0,2}, {1,3}, {2,3}}
J = jac G
