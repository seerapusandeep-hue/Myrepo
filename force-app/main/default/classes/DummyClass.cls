/**
 * @description Sample dummy Apex class for demonstration purposes
 * @author Sample Author
 * @created 2026-07-15
 */
public class DummyClass {

    /**
     * @description Sample method that returns a greeting message
     * @param name The name to include in the greeting
     * @return String greeting message
     */
    public static String greet(String name) {
        return 'Hello, ' + name + '!';
    }

    /**
     * @description Sample method that adds two numbers
     * @param a First number
     * @param b Second number
     * @return Integer sum of a and b
     */
    public static Integer add(Integer a, Integer b) {
        return a + b;
    }

    /**
     * @description Sample method that queries accounts
     * @return List<Account> list of accounts
     */
    public static List<Account> getAccounts() {
        return [SELECT Id, Name FROM Account LIMIT 10];
    }
}
