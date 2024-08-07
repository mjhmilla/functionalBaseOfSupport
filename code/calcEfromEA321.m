function E = calcEfromEA321(ea321)


s1 = sin(ea321(1,3));
c1 = cos(ea321(1,3));    
r1 = [1 0 0; 0 c1 -s1; 0 s1 c1];

s2 = sin(ea321(1,2));
c2 = cos(ea321(1,2));
r2 = [c2 0 s2; 0 1 0; -s2 0 c2];


s3 = sin(ea321(1,1));
c3 = cos(ea321(1,1));
r3 = [c3 -s3 0; s3 c3 0; 0 0 1];

E = r3*r2*r1;