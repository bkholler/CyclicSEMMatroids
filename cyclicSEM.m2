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


  return toList(apply(vertices(G), i -> phi_(i, i)) | apply(subsets(n, 2), i -> phi_(i_0, i_1)));
  )

jac = jac = G -> jacobian matrix {gaussPrecParam(G)}





