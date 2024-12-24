// tests/medical-analysis_test.ts

import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensures that medical analysis can be submitted and retrieved",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const analyst = accounts.get('wallet_1')!;
        
        // Test image hash (32 bytes)
        const imageHash = '0x1234567890123456789012345678901234567890123456789012345678901234';
        
        let block = chain.mineBlock([
            Tx.contractCall(
                'medical-analysis',
                'submit-analysis',
                [
                    types.buff(imageHash),
                    types.utf8('Normal tissue sample'),
                    types.uint(80)
                ],
                analyst.address
            )
        ]);
        
        assertEquals(block.receipts.length, 1);
        assertEquals(block.height, 2);
        
        // Verify analysis can be retrieved
        const receipt = chain.callReadOnlyFn(
            'medical-analysis',
            'get-analysis',
            [types.buff(imageHash)],
            deployer.address
        );
        
        receipt.result.expectSome().expectTuple();
    },
});
