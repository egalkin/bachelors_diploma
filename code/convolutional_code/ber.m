codes_number = 2;

codes_memory = cell(codes_number,1);
codes_g_matrices = cell(codes_number,1);
codes_h_row = cell(codes_number,1);

codes_memory{1} = 2;

codes_g_matrices{1} = [
    1 0 0 1, 0 0 0 1, 0 0 0 1;
    0 1 0 1, 0 0 0 0, 0 0 0 1;
    0 0 1 1, 0 0 0 1, 0 0 0 0;
];

codes_h_row{1} = [[1,1,0,0], [1,0,1,0], [1,1,1,1]];

codes_memory{2} = 3;
codes_g_matrices{2} = [ 
    1 0 0 0 0 0 0 1, 0 0 0 0 0 0 0 1, 0 0 0 0 0 0 0 1, 0 0 0 0 0 0 0 1;
    0 1 0 0 0 0 0 1, 0 0 0 0 0 0 0 1, 0 0 0 0 0 0 0 1, 0 0 0 0 0 0 0 0;
    0 0 1 0 0 0 0 1, 0 0 0 0 0 0 0 1, 0 0 0 0 0 0 0 0, 0 0 0 0 0 0 0 1;
    0 0 0 1 0 0 0 1, 0 0 0 0 0 0 0 1, 0 0 0 0 0 0 0 0, 0 0 0 0 0 0 0 0;
    0 0 0 0 1 0 0 1, 0 0 0 0 0 0 0 0, 0 0 0 0 0 0 0 1, 0 0 0 0 0 0 0 1;
    0 0 0 0 0 1 0 1, 0 0 0 0 0 0 0 0, 0 0 0 0 0 0 0 1, 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 1 1, 0 0 0 0 0 0 0 0, 0 0 0 0 0 0 0 0, 0 0 0 0 0 0 0 1;
];

codes_h_row{2} = [[1 0 1 0 1 0 1 0], [1 1 0 0 1 1 0 0], [1 1 1 1 0 0 0 0 ], [1 1 1 1 1 1 1 1]];


blocks_number = 100;
numFrames = 1000;

max_L = 4;

epsilon =  [0.01:0.05:0.25, 0.25];
errRates = zeros(max_L,length(epsilon));

uncErrRate = zeros(1,length(epsilon)); 


for L = 2:max_L
    code = 2;
    n = 2 ^ codes_memory{code};
    k = n - 1;
    for ii = 1:length(epsilon)
        ttlErr = 0;
        ttlErrUnc = 0;
        for counter = 1:numFrames
            message = randi([0, 1], 1 ,blocks_number * k);
            uncoded_recieved_bits = transmit_message(message, epsilon(ii));
            numErrUnc = sum(uncoded_recieved_bits == -1);
            ttlErrUnc = ttlErrUnc + numErrUnc;
            encoded_message = encode(codes_g_matrices{code}, [message, zeros(1, L * k)], codes_memory{code});
            recieved_sig = transmit_message(encoded_message, epsilon(ii));
            recieved_bits = decode(codes_h_row{code}, recieved_sig, L, codes_memory{code}, L);
            numErr = sum(recieved_bits == -1);
            ttlErr = ttlErr + numErr;
        end
        ttlBits = numFrames*length(recieved_bits);
        uncErrRate(ii) = ttlErrUnc/ttlBits;
        errRates(L, ii) = ttlErr/ttlBits;
    end
end

semilogy(epsilon, uncErrRate, epsilon, errRates(2, :), epsilon, errRates(3, :), epsilon, errRates(4, :), epsilon, errRates(5, :))
legend('Uncoded', 'SWML, L=2', 'SWML, L=3', 'SWML, L=4', 'SWML, L=5')
xlabel('Erasure probability')
ylabel('BER')


function encoded_message = transmit_message(encoded_message, eps)
    for i = 1:length(encoded_message)
        if rand <= eps
            encoded_message(i) = -1;
        end
    end
end