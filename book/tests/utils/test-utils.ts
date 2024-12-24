// tests/utils/test-utils.ts

import { Chain, Account, Tx, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';

export interface AnalysisResult {
    diagnosis: string;
    confidence: number;
    timestamp: number;
    analyst: string;
}

export class TestUtils {
    static readonly MOCK_IMAGE_HASH = '0x1234567890123456789012345678901234567890123456789012345678901234';

    // Helper to create a valid analysis submission
    static createAnalysis(chain: Chain, sender: Account, imageHash: string, diagnosis: string, confidence: number) {
        return Tx.contractCall(
            'medical-analysis',
            'submit-analysis',
            [
                types.buff(imageHash),
                types.utf8(diagnosis),
                types.uint(confidence)
            ],
            sender.address
        );
    }

    // Helper to validate analysis result
    static validateAnalysis(result: any): AnalysisResult {
        if (!result || typeof result !== 'object') {
            throw new Error('Invalid analysis result');
        }

        return {
            diagnosis: result.diagnosis.value,
            confidence: parseInt(result.confidence.value),
            timestamp: parseInt(result.timestamp.value),
            analyst: result.analyst.value
        };
    }

    // Helper to check if an error is of a specific type
    static isError(error: any, code: number): boolean {
        return error && error.value && parseInt(error.value) === code;
    }

    // Helper to generate test image hash
    static generateImageHash(index: number): string {
        const hash = '0x' + index.toString().padStart(64, '0');
        return hash;
    }

    // Helper to simulate time passing
    static async advanceChain(chain: Chain, blocks: number) {
        for (let i = 0; i < blocks; i++) {
            await chain.mineBlock([]);
        }
    }

    // Helper to check contract owner
    static async isContractOwner(chain: Chain, address: string): Promise<boolean> {
        const result = await chain.callReadOnlyFn(
            'medical-analysis',
            'get-contract-owner',
            [],
            address
        );
        return result.value === address;
    }
}

export const ERROR_CODES = {
    ERR_OWNER_ONLY: 100,
    ERR_INVALID_IMAGE: 101,
    ERR_INVALID_DIAGNOSIS: 102,
    ERR_INVALID_CONFIDENCE: 103,
    ERR_INVALID_MINIMUM: 104
};
