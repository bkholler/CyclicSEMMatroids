basisSeparate = {fieldChar => nextPrime(100000), matroidRank => null, trials => 10000} >> opts -> (J1, J2) -> (

	t := opts.trials;
	d := if opts.matroidRank === null then rank(J1) else opts.matroidRank;
	p := opts.fieldChar;
	n := numcols(J1);
	m1 := numrows(J1);
	m2 := numgens ring J2;

  	vals1 := apply(m1, i -> random(ZZ/p));
  	vals2 := apply(m2, i -> random(ZZ/p));
  	numJ1 := sub(J1, apply(m1, i -> (gens ring J1)_i => vals1_i));
  	numJ2 := sub(J2, apply(m2, i -> (gens ring J2)_i => vals2_i));

  	for i from 0 to t do(

  		S := take(random(toList(0..n-1)), d);

  		if rank(numJ1_S) == d and rank(numJ2_S) < d then(

  			if rank(J2_S) < d then return {S, d, rank(numJ2_S)};
  			
  			)
  		else if rank(numJ1_S) < d and rank(numJ1_S) == d then(

  			if rank(J1_S) < d then return {S, rank(numJ1_S), d};
  				
  			);
  		);
	)