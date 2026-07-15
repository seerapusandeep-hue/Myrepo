/**
 * @description Test class for DummyClass
 * @author Sample Author
 * @created 2026-07-15
 */
@isTest
public class DummyClassTest {

    /**
     * @description Test the greet method
     */
    @isTest
    static void testGreet() {
        String result = DummyClass.greet('John');
        Assert.areEqual('Hello, John!', result, 'Greet method should return correct greeting');
    }

    /**
     * @description Test the greet method with empty string
     */
    @isTest
    static void testGreetEmpty() {
        String result = DummyClass.greet('');
        Assert.areEqual('Hello, !', result, 'Greet method should handle empty string');
    }

    /**
     * @description Test the add method
     */
    @isTest
    static void testAdd() {
        Integer result = DummyClass.add(5, 10);
        Assert.areEqual(15, result, 'Add method should return sum of two numbers');
    }

    /**
     * @description Test the add method with negative numbers
     */
    @isTest
    static void testAddNegative() {
        Integer result = DummyClass.add(-5, 10);
        Assert.areEqual(5, result, 'Add method should handle negative numbers');
    }

    /**
     * @description Test the add method with zero
     */
    @isTest
    static void testAddZero() {
        Integer result = DummyClass.add(0, 0);
        Assert.areEqual(0, result, 'Add method should return zero when adding zeros');
    }

    /**
     * @description Test the getAccounts method
     */
    @isTest
    static void testGetAccounts() {
        List<Account> accounts = DummyClass.getAccounts();
        Assert.isNotNull(accounts, 'GetAccounts should return a list');
        Assert.isTrue(accounts.size() >= 0, 'GetAccounts should return a valid list');
    }

    /**
     * @description Test getAccounts with test data
     */
    @isTest
    static void testGetAccountsWithData() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        List<Account> accounts = DummyClass.getAccounts();
        Assert.isNotNull(accounts, 'GetAccounts should return a list');
        Assert.isTrue(accounts.size() > 0, 'GetAccounts should return at least one account');
    }
}
