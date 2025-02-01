/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MakeEmailsInvalidControllerTest {

    @isTest
    static void fetchObjects() {
        

        Test.startTest();
        List<MakeEmailsInvalidController.OptionWrapper> objects = MakeEmailsInvalidController.fetchAllObjects();
        Test.stopTest();

        Assert.isTrue(objects.size() > 0, 'List of Objects');
    }

    @isTest
    static void runBatchClass(){

        Account acct = new Account(Name='Test Account');
        insert acct;

        List<Contact> conts = new List<Contact>();
        for(Integer i=0; i < 99 ;i++ ){
            Contact cont = new Contact( 
                FirstName = 'Johnny'+i,
                LastName = 'Test Contact',
                Email = 'johnny.test.contact@gmail.com',
                AccountId = acct.Id
            );
            conts.add(cont);
        }

        Contact cont2 = new Contact( 
                FirstName = 'Jan',
                LastName = 'Test Contact',
                Email = 'jan.test.email.needs.be.close.to.eightycharacters.to.error.on.update@gmail.com',
                AccountId = acct.Id
            );
        conts.add(cont2);
        insert conts;

        List<String> objects = new List<String>{'Contact'};

        Test.startTest();
        MakeEmailsInvalidController.objectsToAnonymize(objects, '200', true);
        Test.stopTest();

        List<Contact> resultingContacts = [SELECT Id,FirstName, Email FROM Contact];
        Assert.areEqual(99, resultingContacts.size(), 'Should be 99 because one could not be inserted due to length when attempting to update');
        Assert.areEqual(resultingContacts[0].Email, 'johnny.test.contact@gmail.com.invalid', 'new email should have .invalid at end');
    }
}