import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that only owner can register water sources",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const user1 = accounts.get("wallet_1")!;

    let block = chain.mineBlock([
      Tx.contractCall("aqua-chain", "register-water-source",
        [types.ascii("Test Location"), types.uint(1000)],
        deployer.address
      ),
      Tx.contractCall("aqua-chain", "register-water-source",
        [types.ascii("Invalid Location"), types.uint(500)],
        user1.address
      )
    ]);

    assertEquals(block.receipts.length, 2);
    assertEquals(block.height, 2);
    
    // First call should succeed
    assertEquals(block.receipts[0].result, "(ok u1)");
    
    // Second call should fail with unauthorized
    assertEquals(block.receipts[1].result, "(err u100)");
  },
});

Clarinet.test({
  name: "Test water rights transfer functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    // Test implementation
  },
});
