function [system, syndrom] = build_system(codeword, h) 
  syndrom = [];
  system = [];
  indexing = 1;
  for r = 1:size(h,1)
    system_indexing = 1;
    bits = 0;
    system_row = [];
    for i = 1:size(codeword,2)
      if codeword(i) >= 0
        bits = bits + codeword(i) * h(r, i);
      else
        system_row(system_indexing) = abs(codeword(i)) * h(r,i);
        system_indexing = system_indexing + 1;
      end
    end
    bits = mod(bits,2);
    system = [system; system_row];
    syndrom(indexing) = bits;
    indexing = indexing + 1;
  end
end
